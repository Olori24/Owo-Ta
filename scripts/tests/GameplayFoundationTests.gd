extends SceneTree

const TEST_VIEW_SIZE := Vector2(1080.0, 1920.0)

func _initialize() -> void:
	call_deferred("_run_tests")

func _run_tests() -> void:
	var main_scene_path := str(ProjectSettings.get_setting("application/run/main_scene", ""))
	if main_scene_path.is_empty():
		_fail("The configured main scene path is empty.")
		return
	var packed_scene := load(main_scene_path) as PackedScene
	if packed_scene == null:
		_fail("The configured main scene could not be loaded: " + main_scene_path)
		return
	var world := packed_scene.instantiate() as Node3D
	if world == null:
		_fail("The configured main scene did not instantiate as Node3D.")
		return
	root.add_child(world)
	await process_frame

	var player := world.get_node_or_null("Player") as CharacterBody3D
	var controls := world.get_node_or_null("MobileControls/TouchOverlay") as Control
	if player == null or controls == null:
		_fail("The configured scene must provide a player and touch overlay for gameplay tests.")
		return
	controls.size = TEST_VIEW_SIZE

	if not _test_touch_controls(player, controls):
		quit(1)
		return
	if not await _test_player_physics(player, controls):
		quit(1)
		return

	print("OWO TÀ gameplay behavior tests passed: mobile touch routing/release, focus/pause/removal cleanup, camera-relative movement, rotation, gravity, jumping, and building collision.")
	world.queue_free()
	quit(0)

func _test_touch_controls(player: CharacterBody3D, controls: Control) -> bool:
	_release_test_actions()
	player.call("cancel_jump")

	_send_touch(controls, 1, Vector2(150.0, 500.0), true)
	_send_drag(controls, 1, Vector2(230.0, 500.0))
	if not _expect(Input.is_action_pressed("move_right"), "joystick drag should press move_right"):
		return false
	_send_touch(controls, 1, Vector2(230.0, 500.0), false)
	if not _expect(not Input.is_action_pressed("move_right"), "releasing the joystick must release movement"):
		return false
	if not _expect(int(controls.get("active_move_touch")) == -1, "joystick release must clear its active touch id"):
		return false

	var jump_center := TEST_VIEW_SIZE - Vector2(82.0, 92.0)
	_send_touch(controls, 2, jump_center, true)
	if not _expect(Input.is_action_pressed("jump"), "touching the visible jump button should press jump"):
		return false
	_send_touch(controls, 2, jump_center, false)
	if not _expect(not Input.is_action_pressed("jump"), "releasing the jump button must release the jump action"):
		return false
	if not _expect(bool(player.get("jump_requested")), "a short jump tap must remain buffered after touch release until the next physics tick"):
		return false
	player.call("cancel_jump")

	var look_start := Vector2(720.0, 1690.0)
	var camera_pivot := player.get_node_or_null("CameraPivot") as Node3D
	if not _expect(camera_pivot != null, "camera pivot must be available to receive look input"):
		return false
	var yaw_before_look := camera_pivot.global_rotation.y
	_send_touch(controls, 3, look_start, true)
	if not _expect(int(controls.get("active_look_touch")) == 3, "a right-side touch outside the jump button should begin camera look"):
		return false
	if not _expect(int(controls.get("jump_touch")) == -1 and not Input.is_action_pressed("jump"), "touches outside the jump button must not trigger jump"):
		return false
	_send_drag(controls, 3, look_start + Vector2(30.0, -12.0))
	var look_yaw_delta := wrapf(camera_pivot.global_rotation.y - yaw_before_look, -PI, PI)
	if not _expect(absf(look_yaw_delta) > 0.05, "camera-look drag should change the camera yaw"):
		return false
	_send_touch(controls, 3, look_start + Vector2(30.0, -12.0), false)
	if not _expect(int(controls.get("active_look_touch")) == -1, "releasing camera-look touch must clear its id"):
		return false

	_send_touch(controls, 4, Vector2(150.0, 500.0), true)
	_send_drag(controls, 4, Vector2(230.0, 500.0))
	_send_touch(controls, 5, jump_center, true)
	if not _expect(Input.is_action_pressed("move_right") and Input.is_action_pressed("jump"), "simultaneous joystick and jump touches should be active"):
		return false
	controls.notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	if not _expect(_all_virtual_actions_released(), "application focus loss must release every virtual action"):
		return false
	if not _expect(_all_touch_ids_cleared(controls), "application focus loss must clear all touch ids"):
		return false
	if not _expect(not bool(player.get("jump_requested")), "application focus loss must cancel an unconsumed jump request"):
		return false

	_send_touch(controls, 6, Vector2(150.0, 500.0), true)
	_send_drag(controls, 6, Vector2(230.0, 500.0))
	_send_touch(controls, 7, jump_center, true)
	_send_touch(controls, 7, jump_center, false)
	if not _expect(bool(player.get("jump_requested")), "jump tap should be pending before app-pause cleanup"):
		return false
	controls.notification(Node.NOTIFICATION_APPLICATION_PAUSED)
	if not _expect(_all_virtual_actions_released() and not bool(player.get("jump_requested")), "application pause must release controls and cancel a pending jump"):
		return false
	if not _expect(_all_touch_ids_cleared(controls), "application pause must clear all touch ids"):
		return false

	_send_touch(controls, 8, Vector2(150.0, 500.0), true)
	_send_drag(controls, 8, Vector2(230.0, 500.0))
	_send_touch(controls, 9, jump_center, true)
	_send_touch(controls, 9, jump_center, false)
	var controls_layer := controls.get_parent() as CanvasLayer
	if not _expect(controls_layer != null and bool(player.get("jump_requested")), "touch overlay removal test requires a pending jump and parent layer"):
		return false
	controls_layer.remove_child(controls)
	if not _expect(_all_virtual_actions_released() and not bool(player.get("jump_requested")), "removing the touch overlay must release controls and cancel a pending jump"):
		return false
	if not _expect(_all_touch_ids_cleared(controls), "removing the touch overlay must clear all touch ids"):
		return false
	controls_layer.add_child(controls)
	if not _expect(controls.is_inside_tree(), "touch overlay must be restored after removal testing"):
		return false
	_release_test_actions()
	return true

func _test_player_physics(player: CharacterBody3D, controls: Control) -> bool:
	_release_test_actions()
	player.global_position = Vector3(0.0, 8.0, 0.0)
	player.velocity = Vector3.ZERO
	for _frame in range(4):
		await physics_frame
	if not _expect(player.velocity.y < -0.1 and player.global_position.y < 8.0, "gravity should accelerate the player downward"):
		return false

	player.global_position = Vector3(0.0, 0.1, 3.0)
	player.velocity = Vector3.ZERO
	for _frame in range(18):
		await physics_frame
	if not _expect(player.is_on_floor(), "player should land on the district ground before jump testing"):
		return false
	var jump_start_height := player.global_position.y
	var jump_center := TEST_VIEW_SIZE - Vector2(82.0, 92.0)
	_send_touch(controls, 10, jump_center, true)
	_send_touch(controls, 10, jump_center, false)
	await physics_frame
	var jumped := player.velocity.y > 0.1 and player.global_position.y > jump_start_height
	if not _expect(jumped, "grounded jump input should produce upward velocity and displacement"):
		return false

	player.global_position = Vector3(0.0, 0.1, 3.0)
	player.velocity = Vector3.ZERO
	player.rotation.y = 0.0
	var camera_pivot := player.get_node_or_null("CameraPivot") as Node3D
	var visual_body := player.get_node_or_null("Body") as Node3D
	if not _expect(camera_pivot != null and visual_body != null, "camera pivot and visible body must remain present"):
		return false
	camera_pivot.rotation = Vector3(0.0, PI / 2.0, 0.0)
	for _frame in range(18):
		await physics_frame
	if not _expect(player.is_on_floor(), "player should be grounded before camera-relative movement testing"):
		return false
	var start_position := player.global_position
	Input.action_press("move_forward")
	for _frame in range(24):
		await physics_frame
	Input.action_release("move_forward")
	var displacement := player.global_position - start_position
	if not _expect(absf(displacement.x) > 0.25 and absf(displacement.x) > absf(displacement.z) * 2.0, "forward movement should follow the camera yaw rather than the initial body heading"):
		return false
	var expected_body_yaw := PI / 2.0
	var body_yaw_error := absf(wrapf(visual_body.rotation.y - expected_body_yaw, -PI, PI))
	if not _expect(body_yaw_error < 0.2, "visible player body should rotate toward its camera-relative movement direction"):
		return false
	var player_root_yaw_error := absf(wrapf(player.rotation.y, -PI, PI))
	if not _expect(player_root_yaw_error < 0.02, "player root should not turn and feed facing back into the camera"):
		return false
	var camera_yaw_error := absf(wrapf(camera_pivot.global_rotation.y - PI / 2.0, -PI, PI))
	if not _expect(camera_yaw_error < 0.02, "player movement must not rotate the camera heading away from its look direction"):
		return false
	if not _expect(not Input.is_action_pressed("move_forward"), "movement test must release its input action"):
		return false

	player.global_position = Vector3(-20.0, 0.1, -13.0)
	player.velocity = Vector3.ZERO
	player.rotation = Vector3.ZERO
	camera_pivot.rotation = Vector3.ZERO
	visual_body.rotation = Vector3.ZERO
	for _frame in range(18):
		await physics_frame
	if not _expect(player.is_on_floor(), "player should be grounded before building collision testing"):
		return false
	var building_collision := player.get_parent().get_node_or_null("BuildingACollision") as StaticBody3D
	if not _expect(building_collision != null, "BuildingA must have its expected StaticBody3D collision body"):
		return false
	var building_test_start_x := player.global_position.x
	var hit_building_a := false
	Input.action_press("move_right")
	for _frame in range(60):
		await physics_frame
		for collision_index in range(player.get_slide_collision_count()):
			var slide_collision := player.get_slide_collision(collision_index)
			if slide_collision.get_collider() == building_collision:
				hit_building_a = true
	Input.action_release("move_right")
	var building_displacement_x := player.global_position.x - building_test_start_x
	if not _expect(building_displacement_x > 1.0, "player should move toward BuildingA during the collision test"):
		return false
	if not _expect(hit_building_a, "player must physically register a slide collision with BuildingACollision"):
		return false
	if not _expect(player.global_position.x < -16.6, "player must stop at BuildingA rather than pass through its collision box"):
		return false
	if not _expect(not Input.is_action_pressed("move_right"), "BuildingA collision test must release its movement action"):
		return false

	if not await _test_building_collision(player, "BuildingB", Vector3(14.0, 0.1, -30.0), "move_back", "z", -24.5, true):
		return false
	if not await _test_building_collision(player, "BuildingC", Vector3(-17.0, 0.1, 18.0), "move_forward", "z", 15.5, false):
		return false
	return true

func _test_building_collision(player: CharacterBody3D, building_name: String, start_position: Vector3, action: String, axis: String, stop_boundary: float, less_than: bool) -> bool:
	player.global_position = start_position
	player.velocity = Vector3.ZERO
	player.rotation = Vector3.ZERO
	var camera_pivot := player.get_node_or_null("CameraPivot") as Node3D
	if camera_pivot == null:
		return _expect(false, "Camera pivot must remain available for " + building_name + " collision testing.")
	camera_pivot.rotation = Vector3.ZERO
	for _frame in range(18):
		await physics_frame
	if not _expect(player.is_on_floor(), "Player should be grounded before " + building_name + " collision testing."):
		return false
	var building_collision := player.get_parent().get_node_or_null(building_name + "Collision") as StaticBody3D
	if not _expect(building_collision != null, building_name + " must have its expected StaticBody3D collision body."):
		return false
	var start_axis_position := player.global_position.x if axis == "x" else player.global_position.z
	var hit_building := false
	Input.action_press(action)
	# Start positions are deliberately outside the collider; allow enough frames
	# for acceleration and a full approach before asserting physical contact.
	for _frame in range(120):
		await physics_frame
		for collision_index in range(player.get_slide_collision_count()):
			if player.get_slide_collision(collision_index).get_collider() == building_collision:
				hit_building = true
	Input.action_release(action)
	var final_axis_position := player.global_position.x if axis == "x" else player.global_position.z
	print("COLLISION_DIAGNOSTIC: %s start=%s final=%s velocity=%s hit=%s" % [building_name, start_position, player.global_position, player.velocity, hit_building])
	var displacement := absf(final_axis_position - start_axis_position)
	if not _expect(displacement > 1.0, "Player should move toward " + building_name + " during its collision test."):
		return false
	if not _expect(hit_building, "Player must physically register a slide collision with " + building_name + "Collision."):
		return false
	var stopped_before_building := final_axis_position < stop_boundary if less_than else final_axis_position > stop_boundary
	if not _expect(stopped_before_building, "Player must stop against " + building_name + " rather than pass through its collision box."):
		return false
	if not _expect(not Input.is_action_pressed(action), building_name + " collision test must release its movement action."):
		return false
	return true

func _send_touch(controls: Control, finger: int, position: Vector2, pressed: bool) -> void:
	var event := InputEventScreenTouch.new()
	event.index = finger
	event.position = position
	event.pressed = pressed
	controls.call("_input", event)

func _send_drag(controls: Control, finger: int, position: Vector2) -> void:
	var event := InputEventScreenDrag.new()
	event.index = finger
	event.position = position
	controls.call("_input", event)

func _all_virtual_actions_released() -> bool:
	for action in ["move_left", "move_right", "move_forward", "move_back", "jump"]:
		if InputMap.has_action(action) and Input.is_action_pressed(action):
			return false
	return true

func _all_touch_ids_cleared(controls: Control) -> bool:
	return int(controls.get("active_move_touch")) == -1 and int(controls.get("active_look_touch")) == -1 and int(controls.get("jump_touch")) == -1

func _release_test_actions() -> void:
	for action in ["move_left", "move_right", "move_forward", "move_back", "jump"]:
		if InputMap.has_action(action):
			Input.action_release(action)

func _expect(condition: bool, message: String) -> bool:
	if condition:
		return true
	_fail(message)
	return false

func _fail(message: String) -> void:
	push_error("OWO TÀ gameplay test failed: " + message)
	quit(1)
