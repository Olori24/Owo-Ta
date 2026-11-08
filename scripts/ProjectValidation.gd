extends SceneTree

func _initialize() -> void:
	call_deferred("_validate_project")

func _validate_project() -> void:
	var scene_path := str(ProjectSettings.get_setting("application/run/main_scene"))
	if scene_path.is_empty():
		push_error("The project has no configured main scene.")
		quit(1)
		return
	var packed_scene := load(scene_path) as PackedScene
	if packed_scene == null:
		push_error("Could not load configured main scene: " + scene_path)
		quit(1)
		return
	var instance := packed_scene.instantiate()
	if instance == null:
		push_error("Could not instantiate configured main scene: " + scene_path)
		quit(1)
		return
	root.add_child(instance)
	await process_frame
	print("OWO TÀ foundation validation passed: " + scene_path)
	instance.queue_free()
	quit()
