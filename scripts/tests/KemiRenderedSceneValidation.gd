extends SceneTree

const EXPECTED_BUILD_ID := "OWO TÀ · IKEJA STREETSCAPE-02"
const REQUIRED_CLIPS := ["idle", "walk", "run", "jump"]
const MIN_CENTRAL_TEAL_PIXELS := 150
const MIN_RENDERED_MESH_DIFF_PIXELS := 2000

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	const DISTRICT_SCENE_PATH := "res://scenes/world/first_district.tscn"
	var packed := load(DISTRICT_SCENE_PATH) as PackedScene
	_check(packed != null, "First district gameplay scene loads as a PackedScene")
	if packed == null:
		_finish()
		return

	var district := packed.instantiate()
	root.add_child(district)
	await process_frame
	# Let the 0.1 m spawn offset settle and the non-looping landing clip complete.
	for _frame in range(90):
		await physics_frame
	await process_frame
	await RenderingServer.frame_post_draw

	var player := district.get_node_or_null("Player") as CharacterBody3D
	_check(player != null, "First district contains the playable CharacterBody3D")
	var visual := player.get_node_or_null("Body/CharacterVisual") as Node3D if player else null
	_check(visual != null and visual.visible and visual.is_visible_in_tree(), "Default Kemi CharacterVisual is visible in the running scene")

	var mesh_instance := _find_mesh(visual) if visual else null
	_check(mesh_instance != null and mesh_instance.mesh != null, "Kemi has a loaded mesh resource")
	if mesh_instance and mesh_instance.mesh:
		_check(mesh_instance.is_visible_in_tree(), "Kemi's skinned mesh is visible in the running scene")
		_check(mesh_instance.mesh.get_surface_count() >= 1, "Kemi mesh has renderable surfaces")

	var animation_player := _find_animation_player(visual) if visual else null
	_check(animation_player != null, "Kemi AnimationPlayer is present")
	if animation_player:
		for clip in REQUIRED_CLIPS:
			_check(animation_player.has_animation(clip), "Kemi clip exists: " + clip)
		_check(animation_player.is_playing() and animation_player.current_animation == "idle", "Kemi returns to idle after landing")

	var build_label := district.get_node_or_null("BuildStamp/BuildIdentifier") as Label
	_check(build_label != null and build_label.is_visible_in_tree() and build_label.text == EXPECTED_BUILD_ID, "Visible build identifier matches " + EXPECTED_BUILD_ID)

	var camera := player.get_node_or_null("CameraPivot/SpringArm3D/Camera3D") as Camera3D if player else null
	var spring_arm := player.get_node_or_null("CameraPivot/SpringArm3D") as SpringArm3D if player else null
	_check(camera != null and camera.current, "District camera is current")
	_check(spring_arm != null and spring_arm.spring_length >= 4.0, "District camera has its expected framing distance")

	var image := root.get_texture().get_image()
	_check(image != null and not image.is_empty(), "Rendered viewport image is available")
	if image != null and not image.is_empty():
		var teal_pixels := _count_kemi_shirt_pixels(image)
		_check(teal_pixels >= MIN_CENTRAL_TEAL_PIXELS, "Rendered image contains Kemi's teal clothing in the expected central character region (" + str(teal_pixels) + " pixels)")
		var build_stamp_pixels := _count_build_stamp_pixels(image)
		_check(build_stamp_pixels >= 10, "Rendered image contains visible build-stamp text (" + str(build_stamp_pixels) + " bright pixels)")
		var output_path := OS.get_environment("OWO_RENDERED_SCENE_OUTPUT")
		if output_path.is_empty():
			output_path = "/tmp/owo-ta-kemi-first-district.png"
		DirAccess.make_dir_recursive_absolute(output_path.get_base_dir())
		var image_error := image.save_png(output_path)
		_check(image_error == OK, "Rendered district screenshot saved: " + output_path)
		if mesh_instance:
			mesh_instance.visible = false
			await process_frame
			await RenderingServer.frame_post_draw
			var image_without_mesh := root.get_texture().get_image()
			mesh_instance.visible = true
			var changed_pixels := _count_render_difference_pixels(image, image_without_mesh)
			_check(changed_pixels >= MIN_RENDERED_MESH_DIFF_PIXELS, "Hiding Kemi's mesh changes the rendered character region (" + str(changed_pixels) + " pixels)")
			print("KEMI_RENDERED_PIXEL_COUNTS: teal=", teal_pixels, " build_stamp=", build_stamp_pixels, " mesh_difference=", changed_pixels)

	if failures.is_empty():
		print("KEMI_RENDERED_SCENE: PASS — configured first district rendered Kemi, build stamp, idle/locomotion/jump clips, camera and screenshot.")
	else:
		for failure in failures:
			push_error("KEMI_RENDERED_SCENE: " + failure)
		print("KEMI_RENDERED_SCENE: FAIL — " + str(failures.size()) + " check(s) failed.")
	_finish()

func _count_kemi_shirt_pixels(image: Image) -> int:
	var x_start := int(image.get_width() * 0.40)
	var x_end := int(image.get_width() * 0.60)
	var y_start := int(image.get_height() * 0.48)
	var y_end := int(image.get_height() * 0.59)
	var count := 0
	for y in range(y_start, y_end):
		for x in range(x_start, x_end):
			var color := image.get_pixel(x, y)
			var red := color.r * 255.0
			var green := color.g * 255.0
			var blue := color.b * 255.0
			if red > 10.0 and red < 90.0 and green > 25.0 and green < 120.0 and blue > 20.0 and blue < 110.0 and green > red * 1.15 and blue > red * 0.75:
				count += 1
	return count

func _count_build_stamp_pixels(image: Image) -> int:
	var x_end := int(image.get_width() * 0.55)
	var y_end := int(image.get_height() * 0.07)
	var count := 0
	for y in range(y_end):
		for x in range(x_end):
			var color := image.get_pixel(x, y)
			if color.r * 255.0 > 235.0 and color.g * 255.0 > 235.0 and color.b * 255.0 > 235.0:
				count += 1
	return count

func _count_render_difference_pixels(with_mesh: Image, without_mesh: Image) -> int:
	if with_mesh.is_empty() or without_mesh.is_empty() or with_mesh.get_size() != without_mesh.get_size():
		return 0
	var x_start := int(with_mesh.get_width() * 0.25)
	var x_end := int(with_mesh.get_width() * 0.75)
	var y_start := int(with_mesh.get_height() * 0.30)
	var y_end := int(with_mesh.get_height() * 0.78)
	var count := 0
	for y in range(y_start, y_end):
		for x in range(x_start, x_end):
			var visible_color := with_mesh.get_pixel(x, y)
			var hidden_color := without_mesh.get_pixel(x, y)
			var maximum_delta := maxf(maxf(absf(visible_color.r - hidden_color.r), absf(visible_color.g - hidden_color.g)), absf(visible_color.b - hidden_color.b))
			if maximum_delta > 0.12:
				count += 1
	return count

func _find_mesh(node: Node) -> MeshInstance3D:
	if node is MeshInstance3D and (node as MeshInstance3D).mesh != null:
		return node as MeshInstance3D
	for child in node.get_children():
		var result := _find_mesh(child)
		if result != null:
			return result
	return null

func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer
	for child in node.get_children():
		var result := _find_animation_player(child)
		if result != null:
			return result
	return null

func _check(condition: bool, description: String) -> void:
	if not condition:
		failures.append(description)

func _finish() -> void:
	quit(0 if failures.is_empty() else 1)
