extends SceneTree

const SCENE_PATH := "res://scenes/benchmarks/ikeja_street_corner.tscn"
var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed := load(SCENE_PATH) as PackedScene
	_check(packed != null, "Ikeja benchmark scene loads")
	if packed == null:
		_finish()
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	await process_frame
	for _frame in range(90):
		await physics_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var player := scene.get_node_or_null("Player") as CharacterBody3D
	_check(player != null, "Playable Kemi controller is instantiated")
	var visual := player.get_node_or_null("Body/CharacterVisual") as Node3D if player else null
	_check(visual != null and visual.is_visible_in_tree(), "Kemi is visible in the street-corner scene")
	var camera := player.get_node_or_null("CameraPivot/SpringArm3D/Camera3D") as Camera3D if player else null
	_check(camera != null and camera.current, "Gameplay camera is active")
	var image := root.get_texture().get_image()
	_check(image != null and not image.is_empty(), "Rendered street-corner viewport is available")
	if image != null and not image.is_empty():
		var output := OS.get_environment("OWO_IKEJA_BENCHMARK_RENDER_OUTPUT")
		if output.is_empty():
			output = "/tmp/owo-ta-ikeja-street-corner.png"
		DirAccess.make_dir_recursive_absolute(output.get_base_dir())
		_check(image.save_png(output) == OK, "Street-corner render saved: " + output)
		print("IKEJA_BENCHMARK_RENDER: ", image.get_width(), "x", image.get_height(), " output=", output)
	if failures.is_empty():
		print("IKEJA_BENCHMARK_RENDER: PASS")
	else:
		for failure in failures:
			push_error("IKEJA_BENCHMARK_RENDER: " + failure)
	_finish()

func _check(condition: bool, description: String) -> void:
	if not condition:
		failures.append(description)

func _finish() -> void:
	quit(0 if failures.is_empty() else 1)
