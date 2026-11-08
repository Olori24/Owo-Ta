extends SceneTree

func _initialize() -> void:
	call_deferred("_run_validation")

func _run_validation() -> void:
	var main_scene_path := str(ProjectSettings.get_setting("application/run/main_scene", ""))
	if main_scene_path.is_empty():
		_fail("The project has no configured main scene.")
		return

	var main_packed_scene := load(main_scene_path) as PackedScene
	if main_packed_scene == null:
		_fail("Could not load configured main scene: " + main_scene_path)
		return

	var main_instance := main_packed_scene.instantiate() as Node3D
	if main_instance == null:
		_fail("Configured main scene must instantiate a Node3D: " + main_scene_path)
		return

	root.add_child(main_instance)
	await process_frame
	if not _validate_gameplay_scene(main_instance):
		return

	print("OWO TÀ configured main scene and 3D gameplay foundation validation passed: " + main_scene_path)
	main_instance.queue_free()
	quit(0)

func _validate_gameplay_scene(world: Node3D) -> bool:
	if ProjectSettings.get_setting("rendering/renderer/rendering_method", "") != "mobile":
		return _fail("Mobile rendering must remain enabled.")

	var player := world.get_node_or_null("Player") as CharacterBody3D
	if player == null:
		return _fail("Playable CharacterBody3D player is missing from the configured main scene.")
	for required_method in ["apply_look", "_camera_relative_direction", "request_jump", "cancel_jump"]:
		if not player.has_method(required_method):
			return _fail("Player controller is missing required behavior: " + required_method)

	var body_mesh := player.get_node_or_null("Body") as MeshInstance3D
	if body_mesh == null or body_mesh.mesh == null:
		return _fail("Player body mesh is missing.")
	var player_collision := player.get_node_or_null("CollisionShape3D") as CollisionShape3D
	if player_collision == null or player_collision.shape == null:
		return _fail("Player collision shape is missing.")

	var camera_pivot := player.get_node_or_null("CameraPivot") as Node3D
	var spring_arm := player.get_node_or_null("CameraPivot/SpringArm3D") as SpringArm3D
	var camera := player.get_node_or_null("CameraPivot/SpringArm3D/Camera3D") as Camera3D
	if camera_pivot == null or spring_arm == null or camera == null:
		return _fail("Third-person camera pivot, spring arm, and camera must all load.")
	if not camera.current or spring_arm.spring_length <= 0.0:
		return _fail("Third-person camera must be current and the spring arm must have positive length.")

	var world_environment := world.get_node_or_null("WorldEnvironment") as WorldEnvironment
	if world_environment == null or world_environment.environment == null:
		return _fail("World environment and its Environment resource are required.")
	var directional_light := world.get_node_or_null("DirectionalLight3D") as DirectionalLight3D
	if directional_light == null:
		return _fail("Directional world lighting is missing.")

	var ground := world.get_node_or_null("Ground") as StaticBody3D
	if ground == null:
		return _fail("Static ground body is missing.")
	var ground_visual := ground.get_node_or_null("GroundMesh") as MeshInstance3D
	if ground_visual == null or ground_visual.mesh == null:
		return _fail("Ground visual mesh is missing.")
	var ground_collision := ground.get_node_or_null("GroundCollision") as CollisionShape3D
	if ground_collision == null or ground_collision.shape == null:
		return _fail("Ground collision shape is missing.")

	for building_name in ["BuildingA", "BuildingB", "BuildingC"]:
		var building_visual := world.get_node_or_null(building_name) as MeshInstance3D
		if building_visual == null or building_visual.mesh == null:
			return _fail(building_name + " visual mesh is missing.")
		var building_mesh := building_visual.mesh as BoxMesh
		if building_mesh == null:
			return _fail(building_name + " must use a BoxMesh that can be matched to its collider.")
		var building_body := world.get_node_or_null(building_name + "Collision") as StaticBody3D
		if building_body == null:
			return _fail(building_name + " StaticBody3D collision body is missing.")
		var building_shape := building_body.get_node_or_null("CollisionShape3D") as CollisionShape3D
		if building_shape == null or building_shape.shape == null:
			return _fail(building_name + " collision shape is missing.")
		var building_box := building_shape.shape as BoxShape3D
		if building_box == null or not building_box.size.is_equal_approx(building_mesh.size):
			return _fail(building_name + " collision dimensions must match the visible blockout mesh.")
		if building_body.global_position.distance_to(building_visual.global_position) > 0.01:
			return _fail(building_name + " collision body must align with its visible mesh.")

	var controls_layer := world.get_node_or_null("MobileControls") as CanvasLayer
	var touch_overlay := world.get_node_or_null("MobileControls/TouchOverlay") as Control
	if controls_layer == null or touch_overlay == null:
		return _fail("Mobile controls layer and touch overlay are required in the configured main scene.")
	if not touch_overlay.has_method("_input") or not touch_overlay.has_method("_release_all_controls"):
		return _fail("Touch overlay is missing its input and release handlers.")
	return true

func _fail(message: String) -> bool:
	push_error("OWO TÀ validation failed: " + message)
	quit(1)
	return false
