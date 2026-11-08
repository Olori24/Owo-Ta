extends SceneTree

const DISTRICT_SCENE_PATH := "res://scenes/world/first_district.tscn"

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

	var main_instance := main_packed_scene.instantiate()
	if main_instance == null or not main_instance is Node3D:
		_fail("Configured main scene must instantiate a Node3D: " + main_scene_path)
		return
	root.add_child(main_instance)
	await process_frame

	var district_instance: Node3D = main_instance
	if main_scene_path != DISTRICT_SCENE_PATH:
		var district_packed_scene := load(DISTRICT_SCENE_PATH) as PackedScene
		if district_packed_scene == null:
			_fail("First district scene could not be loaded: " + DISTRICT_SCENE_PATH)
			return
		var loaded_district := district_packed_scene.instantiate()
		if loaded_district == null or not loaded_district is Node3D:
			_fail("First district scene must instantiate a Node3D.")
			return
		district_instance = loaded_district
		root.add_child(district_instance)
		await process_frame

	if not _validate_district(district_instance):
		return

	print("OWO TÀ configured main scene and 3D gameplay foundation validation passed: " + main_scene_path)
	main_instance.queue_free()
	if district_instance != main_instance:
		district_instance.queue_free()
	quit()

func _validate_district(world: Node3D) -> bool:
	if ProjectSettings.get_setting("rendering/renderer/rendering_method", "") != "mobile":
		return _fail("Mobile rendering must remain enabled.")

	var player := world.get_node_or_null("Player")
	if not player is CharacterBody3D:
		return _fail("Playable CharacterBody3D player is missing.")
	if not player.has_method("apply_look") or not player.has_method("_camera_relative_direction") or not player.has_method("request_jump") or not player.has_method("cancel_jump"):
		return _fail("Player controller is missing camera-look, camera-relative movement, or buffered jump behavior.")

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

	var controls_layer := world.get_node_or_null("MobileControls") as CanvasLayer
	var touch_overlay := world.get_node_or_null("MobileControls/TouchOverlay") as Control
	if controls_layer == null or touch_overlay == null:
		return _fail("Mobile controls layer and touch overlay are required.")
	if not touch_overlay.has_method("_input") or not touch_overlay.has_method("_release_all_controls"):
		return _fail("Touch overlay is missing its input and release handlers.")
	return true

func _fail(message: String) -> bool:
	push_error("OWO TÀ validation failed: " + message)
	quit(1)
	return false
