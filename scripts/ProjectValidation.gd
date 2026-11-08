extends SceneTree

func _initialize() -> void:
	call_deferred("_run_validation")

func _run_validation() -> void:
	var packed_scene: PackedScene = load("res://scenes/world/first_district.tscn")
	if packed_scene == null:
		push_error("First district scene could not be loaded.")
		quit(1)
		return

	var world: Node = packed_scene.instantiate()
	if not world is Node3D:
		push_error("First district root must be Node3D.")
		quit(1)
		return

	root.add_child(world)
	await process_frame

	var player := world.get_node_or_null("Player")
	if player == null or not player is CharacterBody3D:
		push_error("Playable CharacterBody3D player is missing.")
		quit(1)
		return

	if player.get_node_or_null("CameraPivot/SpringArm3D/Camera3D") == null:
		push_error("Third-person camera rig is missing.")
		quit(1)
		return

	if world.get_node_or_null("MobileControls/TouchOverlay") == null:
		push_error("Mobile touch controls are missing.")
		quit(1)
		return

	print("OWO TÀ 3D district validation passed.")
	world.queue_free()
	quit()
