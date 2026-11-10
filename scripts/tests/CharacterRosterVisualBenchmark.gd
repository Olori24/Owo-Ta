extends SceneTree

const CHARACTER_DEFINITION_PATHS := [
	"res://assets/characters/kemi_adebayo/kemi_adebayo.tres",
	"res://assets/characters/tunde_balogun/tunde_balogun.tres",
	"res://assets/characters/amara_okonkwo/amara_okonkwo.tres"
]

const VIEW_DEFINITIONS := [
	{"name": "front_idle", "clip": "idle", "fraction": 0.35, "camera": Vector3(0.0, 1.25, -3.6), "target": Vector3(0.0, 0.95, 0.0)},
	{"name": "threequarter_idle", "clip": "idle", "fraction": 0.55, "camera": Vector3(2.5, 1.35, -3.2), "target": Vector3(0.0, 0.95, 0.0)},
	{"name": "side_idle", "clip": "idle", "fraction": 0.45, "camera": Vector3(3.7, 1.25, 0.0), "target": Vector3(0.0, 0.95, 0.0)},
	{"name": "rear_idle", "clip": "idle", "fraction": 0.65, "camera": Vector3(0.0, 1.25, 3.6), "target": Vector3(0.0, 0.95, 0.0)},
	{"name": "gameplay_idle", "clip": "idle", "fraction": 0.4, "camera": Vector3(0.0, 2.15, 4.8), "target": Vector3(0.0, 0.95, 0.0)},
	{"name": "face_closeup", "clip": "idle", "fraction": 0.5, "camera": Vector3(0.0, 1.55, -1.65), "target": Vector3(0.0, 1.48, 0.0)},
	{"name": "front_walk", "clip": "walk", "fraction": 0.42, "camera": Vector3(0.0, 1.25, -3.6), "target": Vector3(0.0, 0.95, 0.0)},
	{"name": "front_run", "clip": "run", "fraction": 0.38, "camera": Vector3(0.0, 1.25, -3.6), "target": Vector3(0.0, 0.95, 0.0)},
	{"name": "front_jump", "clip": "jump", "fraction": 0.48, "camera": Vector3(0.0, 1.25, -3.6), "target": Vector3(0.0, 0.95, 0.0)},
	{"name": "front_landing", "clip": "landing", "fraction": 0.48, "camera": Vector3(0.0, 1.25, -3.6), "target": Vector3(0.0, 0.95, 0.0)}
]

var failures: Array[String] = []
var output_dir := ""
var camera: Camera3D
var character_anchor: Node3D
var report_text := "# OWO TÀ Character Visual Benchmark\n\n"

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	output_dir = OS.get_environment("OWO_CHARACTER_BENCHMARK_OUTPUT")
	if output_dir.is_empty():
		output_dir = "/tmp/owo-ta-character-visual-benchmark"
	DirAccess.make_dir_recursive_absolute(output_dir)
	_build_benchmark_stage()
	await process_frame
	await RenderingServer.frame_post_draw

	report_text += "Godot Forward Mobile · 1280×720 · neutral studio lighting\n\n"
	report_text += "Each contact sheet is 5 columns × 2 rows. Column order: front idle, three-quarter idle, side idle, rear idle, gameplay idle, face close-up, front walk, front run, front jump, front landing.\n\n"

	for definition_path in CHARACTER_DEFINITION_PATHS:
		await _render_character(definition_path)

	_write_report()
	if failures.is_empty():
		print("CHARACTER_VISUAL_BENCHMARK: PASS — rendered all roster views and contact sheets.")
	else:
		for failure in failures:
			push_error("CHARACTER_VISUAL_BENCHMARK: " + failure)
		print("CHARACTER_VISUAL_BENCHMARK: FAIL — " + str(failures.size()) + " check(s) failed.")
	quit(0 if failures.is_empty() else 1)

func _build_benchmark_stage() -> void:
	var stage := Node3D.new()
	stage.name = "CharacterVisualBenchmarkStage"
	root.add_child(stage)

	var world := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.055, 0.07, 0.085, 1.0)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.76, 0.81, 0.87, 1.0)
	environment.ambient_light_energy = 0.72
	world.environment = environment
	stage.add_child(world)

	var key_light := DirectionalLight3D.new()
	key_light.name = "NeutralKeyLight"
	key_light.rotation_degrees = Vector3(-34.0, -28.0, 0.0)
	key_light.light_color = Color(1.0, 0.94, 0.86, 1.0)
	key_light.light_energy = 1.25
	key_light.shadow_enabled = true
	stage.add_child(key_light)

	var fill_light := DirectionalLight3D.new()
	fill_light.name = "CoolFillLight"
	fill_light.rotation_degrees = Vector3(-18.0, 142.0, 0.0)
	fill_light.light_color = Color(0.76, 0.85, 1.0, 1.0)
	fill_light.light_energy = 0.48
	stage.add_child(fill_light)

	var rim_light := DirectionalLight3D.new()
	rim_light.name = "TealRimLight"
	rim_light.rotation_degrees = Vector3(-12.0, 178.0, 0.0)
	rim_light.light_color = Color(0.58, 0.88, 0.84, 1.0)
	rim_light.light_energy = 0.32
	stage.add_child(rim_light)

	var ground := MeshInstance3D.new()
	ground.name = "NeutralGround"
	var ground_mesh := PlaneMesh.new()
	ground_mesh.size = Vector2(10.0, 10.0)
	ground.mesh = ground_mesh
	var ground_material := StandardMaterial3D.new()
	ground_material.albedo_color = Color(0.16, 0.18, 0.21, 1.0)
	ground_material.roughness = 0.92
	ground.material_override = ground_material
	stage.add_child(ground)

	_add_scale_marker(stage)

	character_anchor = Node3D.new()
	character_anchor.name = "CharacterAnchor"
	stage.add_child(character_anchor)

	camera = Camera3D.new()
	camera.name = "BenchmarkCamera"
	camera.current = true
	camera.fov = 38.0
	stage.add_child(camera)
	_set_camera_view(Vector3(0.0, 1.25, -3.6), Vector3(0.0, 0.95, 0.0))

func _add_scale_marker(parent: Node3D) -> void:
	var marker_material := StandardMaterial3D.new()
	marker_material.albedo_color = Color(0.72, 0.75, 0.78, 1.0)
	marker_material.roughness = 0.8
	var post := MeshInstance3D.new()
	var post_mesh := BoxMesh.new()
	post_mesh.size = Vector3(0.035, 1.8, 0.035)
	post.mesh = post_mesh
	post.material_override = marker_material
	post.position = Vector3(-1.15, 0.9, 0.0)
	parent.add_child(post)
	for tick_index in range(8):
		var tick := MeshInstance3D.new()
		var tick_mesh := BoxMesh.new()
		tick_mesh.size = Vector3(0.18 if tick_index % 2 == 0 else 0.11, 0.018, 0.025)
		tick.mesh = tick_mesh
		tick.material_override = marker_material
		tick.position = Vector3(-1.07, 0.12 + float(tick_index) * 0.2, 0.0)
		parent.add_child(tick)

func _render_character(definition_path: String) -> void:
	var definition := load(definition_path) as CharacterDefinition
	_check(definition != null, "CharacterDefinition loads: " + definition_path)
	if definition == null or definition.visual_scene == null:
		return
	var visual := definition.visual_scene.instantiate() as Node3D
	_check(visual != null, "GLB visual instantiates: " + String(definition.character_id))
	if visual == null:
		return
	var animation_player := _find_animation_player(visual)
	_check(animation_player != null, "AnimationPlayer exists: " + String(definition.character_id))
	if animation_player != null:
		animation_player.autoplay = ""
	visual.position = Vector3.ZERO
	character_anchor.add_child(visual)
	await process_frame
	await physics_frame
	animation_player = _find_animation_player(visual)
	if animation_player == null:
		visual.queue_free()
		return

	var character_id := String(definition.character_id)
	var image_paths: Array[String] = []
	var clip_report := ""
	for view in VIEW_DEFINITIONS:
		var clip_name := _clip_for(definition, String(view["clip"]))
		_check(animation_player.has_animation(clip_name), character_id + " exposes clip " + clip_name)
		if not animation_player.has_animation(clip_name):
			continue
		var animation := animation_player.get_animation(clip_name)
		clip_report += "- %s: %.2f seconds\n" % [clip_name, animation.length]
		animation_player.stop()
		animation_player.play(clip_name)
		animation_player.seek(animation.length * float(view["fraction"]), true)
		animation_player.pause()
		_set_camera_view(view["camera"], view["target"])
		await process_frame
		await RenderingServer.frame_post_draw
		var image := root.get_texture().get_image()
		_check(image != null and not image.is_empty(), character_id + " render is non-empty: " + String(view["name"]))
		if image == null or image.is_empty():
			continue
		var file_name := character_id + "-" + String(view["name"]) + ".png"
		var image_path := output_dir.path_join(file_name)
		var save_error := image.save_png(image_path)
		_check(save_error == OK, "Saved " + file_name)
		if save_error == OK:
			image_paths.append(image_path)

	var contact_sheet := _create_contact_sheet(character_id, image_paths)
	_check(not contact_sheet.is_empty(), "Created contact sheet for " + character_id)
	report_text += "## %s\n\n" % definition.display_name
	report_text += "- Character ID: `%s`\n- Role: %s\n- Visual source: `%s`\n- Captured views: %d/%d\n- Contact sheet: `%s`\n\n" % [character_id, definition.role, definition.visual_scene.resource_path, image_paths.size(), VIEW_DEFINITIONS.size(), contact_sheet]
	report_text += "### Animation clip lengths\n\n%s\n" % clip_report
	visual.queue_free()
	await process_frame

func _clip_for(definition: CharacterDefinition, key: String) -> String:
	match key:
		"idle": return String(definition.idle_clip)
		"walk": return String(definition.walk_clip)
		"run": return String(definition.run_clip)
		"jump": return String(definition.jump_clip)
		"landing": return String(definition.landing_clip)
	return key

func _set_camera_view(position: Vector3, target: Vector3) -> void:
	camera.global_position = position
	camera.look_at(target, Vector3.UP)

func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer
	for child in node.get_children():
		var found := _find_animation_player(child)
		if found != null:
			return found
	return null

func _create_contact_sheet(character_id: String, image_paths: Array[String]) -> String:
	if image_paths.size() != VIEW_DEFINITIONS.size():
		return ""
	var sheet := Image.create(1600, 360, false, Image.FORMAT_RGBA8)
	sheet.fill(Color(0.055, 0.07, 0.085, 1.0))
	for index in range(image_paths.size()):
		var thumbnail := Image.load_from_file(image_paths[index])
		if thumbnail == null or thumbnail.is_empty():
			return ""
		thumbnail.resize(320, 180, Image.INTERPOLATE_LANCZOS)
		var destination := Vector2i((index % 5) * 320, int(index / 5) * 180)
		sheet.blit_rect(thumbnail, Rect2i(Vector2i.ZERO, thumbnail.get_size()), destination)
	var sheet_path := output_dir.path_join(character_id + "-contact-sheet.png")
	if sheet.save_png(sheet_path) != OK:
		return ""
	return sheet_path.get_file()

func _write_report() -> void:
	var report_path := output_dir.path_join("README.md")
	var report := FileAccess.open(report_path, FileAccess.WRITE)
	_check(report != null, "Benchmark report can be written")
	if report != null:
		report.store_string(report_text)

func _check(condition: bool, description: String) -> void:
	if not condition:
		failures.append(description)
