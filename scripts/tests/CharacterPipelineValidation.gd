extends SceneTree

const GLB_PATH := "res://assets/characters/kemi_adebayo/kemi_adebayo.glb"
const BUDGET_PATH := "res://assets/characters/kemi_adebayo/asset_budget.json"
const SELECTION_SCRIPT_PATH := "res://scripts/characters/character_selection.gd"
const DEFINITION_SCRIPT_PATH := "res://scripts/characters/character_definition.gd"

var failures: Array[String] = []
var passes := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var budget := _read_json(BUDGET_PATH)
	_check(not budget.is_empty(), "Character budget manifest parses")
	var glb_bytes := FileAccess.get_file_as_bytes(GLB_PATH)
	_check(glb_bytes.size() > 20, "Character GLB exists and is nonempty")
	if glb_bytes.size() < 20:
		_finish()
		return
	_check(glb_bytes.slice(0, 4).get_string_from_ascii() == "glTF", "Character GLB has the glTF binary signature")
	_check(glb_bytes.decode_u32(4) == 2, "Character GLB uses glTF 2.0")
	_check(glb_bytes.size() <= int(budget.limits.glb_bytes_max), "Character GLB is within the project package-size estimate")
	var json_length := int(glb_bytes.decode_u32(12))
	var gltf_json := JSON.parse_string(glb_bytes.slice(20, 20 + json_length).get_string_from_utf8().strip_edges()) as Dictionary
	_check(not gltf_json.is_empty(), "GLB JSON manifest parses")
	if gltf_json.is_empty():
		_finish()
		return

	var primitive_count := 0
	var material_slots := 0
	var triangle_count := 0
	var vertex_count := 0
	for mesh_data in gltf_json.get("meshes", []):
		for primitive in mesh_data.get("primitives", []):
			primitive_count += 1
			if primitive.has("material"):
				material_slots = maxi(material_slots, int(primitive.material) + 1)
			var attributes: Dictionary = primitive.get("attributes", {})
			vertex_count += int(gltf_json.accessors[int(attributes.get("POSITION", -1))].count) if attributes.has("POSITION") else 0
			_check(attributes.has("POSITION"), "Every exported primitive includes positions")
			_check(attributes.has("NORMAL"), "Every exported primitive includes normals")
			_check(attributes.has("TEXCOORD_0"), "Every exported primitive includes UVs")
			_check(attributes.has("JOINTS_0") and attributes.has("WEIGHTS_0"), "Every exported primitive includes skeletal skinning data")
			_check(attributes.has("COLOR_0"), "Every exported primitive includes authored vertex-colour regions")
			if primitive.has("indices"):
				triangle_count += int(int(gltf_json.accessors[int(primitive.indices)].count) / 3)
			else:
				triangle_count += int(int(gltf_json.accessors[int(attributes.POSITION)].count) / 3)
	_check(primitive_count > 0, "Character GLB contains mesh primitives")
	_check(primitive_count <= int(budget.limits.material_surfaces_max), "Character materials/surfaces are within the project draw-surface estimate")
	_check(triangle_count <= int(budget.limits.triangles_max), "Character triangulated mesh is within the project hero-mesh estimate")
	_check(triangle_count > 0, "Character triangulated mesh has nonzero geometry")
	_check(gltf_json.get("materials", []).size() <= int(budget.limits.material_surfaces_max), "Exported PBR material count is within the project estimate")
	_check(gltf_json.get("skins", []).size() > 0, "Character GLB contains a deforming skin")
	var joint_count := 0
	if not gltf_json.get("skins", []).is_empty():
		joint_count = gltf_json.skins[0].get("joints", []).size()
	_check(joint_count > 0 and joint_count <= int(budget.limits.deforming_bones_max), "Character skeleton bone count is within the project estimate")
	var animation_names: Array[String] = []
	for animation in gltf_json.get("animations", []):
		animation_names.append(String(animation.get("name", "")))
	var required_clips: Array = budget.get("required_animation_clips", [])
	for clip in required_clips:
		_check(animation_names.has(String(clip)), "Required animation clip is exported: " + String(clip))
	_check(animation_names.size() >= int(budget.limits.animation_clips_min), "Animation clip count meets the project exploration target")
	_check(animation_names.size() <= int(budget.limits.animation_clips_max), "Animation clip count stays within the project exploration range")
	for material in gltf_json.get("materials", []):
		_check(material.get("pbrMetallicRoughness", {}).has("baseColorTexture"), "PBR material has an authored base-colour texture")
	_check(gltf_json.get("images", []).size() <= int(budget.limits.texture_files_max), "Embedded texture count is within the project estimate")

	var texture_dir := DirAccess.open("res://assets/characters/kemi_adebayo/textures")
	var texture_files: Array[String] = []
	var texture_bytes := 0
	if texture_dir != null:
		for file_name in texture_dir.get_files():
			if file_name.ends_with(".png"):
				texture_files.append(file_name)
				texture_bytes += FileAccess.get_file_as_bytes("res://assets/characters/kemi_adebayo/textures/" + file_name).size()
	_check(texture_files.size() == gltf_json.get("images", []).size(), "Source texture files correspond to embedded GLB images")
	_check(texture_files.size() <= int(budget.limits.texture_files_max), "Source texture count is within the project estimate")
	_check(texture_bytes <= int(budget.limits.texture_total_bytes_max), "Encoded texture byte total is within the project estimate")
	print("CHARACTER_ASSET_METRICS: glb_bytes=%d vertices=%d triangles=%d surfaces=%d material_slots=%d bones=%d clips=%d source_texture_bytes=%d" % [glb_bytes.size(), vertex_count, triangle_count, primitive_count, material_slots, joint_count, animation_names.size(), texture_bytes])
	for file_name in texture_files:
		var image := Image.new()
		var image_error := image.load("res://assets/characters/kemi_adebayo/textures/" + file_name)
		_check(image_error == OK, "Source texture decodes: " + file_name)
		if image_error == OK:
			_check(maxi(image.get_width(), image.get_height()) <= int(budget.limits.texture_dimension_max), "Source texture dimensions are within the project estimate: " + file_name)
	var blend_path := "res://assets/characters/kemi_adebayo/source/kemi_adebayo.blend"
	_check(FileAccess.file_exists(blend_path) and FileAccess.get_file_as_bytes(blend_path).slice(0, 7).get_string_from_ascii() == "BLENDER", "Editable Blender source is present and has a Blender file signature")
	_check(FileAccess.file_exists("res://assets/characters/kemi_adebayo/source/.gdignore"), "Godot excludes native Blender source from runtime import")
	_check(FileAccess.file_exists("res://tools/blender/build_kemi_character.py"), "Reproducible Blender authoring script is present")

	# Use Godot's native glTF importer directly so this test can also run in a
	# clean headless checkout without relying on a pre-existing editor cache.
	var document := GLTFDocument.new()
	var state := GLTFState.new()
	var import_error := document.append_from_file(GLB_PATH, state)
	_check(import_error == OK, "Pinned Godot GLTFDocument imports the committed GLB")
	if import_error != OK:
		_finish()
		return
	var visual_root := document.generate_scene(state)
	_check(visual_root is Node3D, "Godot generates a Node3D character scene from the actual GLB")
	if not visual_root is Node3D:
		_finish()
		return
	var generated_visual := visual_root as Node3D
	_assign_scene_owner(generated_visual, generated_visual)
	var visual_pack := PackedScene.new()
	var pack_error := visual_pack.pack(generated_visual)
	_check(pack_error == OK, "Imported GLB can be packed as a reusable visual scene")
	if pack_error != OK:
		_finish()
		return
	var model_instance := visual_pack.instantiate()
	root.add_child(model_instance)
	await process_frame

	var skeletons := _collect_skeletons(model_instance)
	var mesh_instances := _collect_meshes(model_instance)
	var animation_players := _collect_animation_players(model_instance)
	_check(not skeletons.is_empty(), "Godot scene contains a Skeleton3D")
	_check(not mesh_instances.is_empty(), "Godot scene contains a visible MeshInstance3D")
	_check(not animation_players.is_empty(), "Godot scene contains an AnimationPlayer")
	var runtime_surfaces := 0
	var max_influences := 0
	var runtime_triangles := 0
	for mesh_instance in mesh_instances:
		_check(mesh_instance.mesh != null, "Every mesh instance has a mesh resource")
		_check(mesh_instance.skin != null, "Visible mesh instance has a Godot Skin resource")
		_check(not mesh_instance.skeleton.is_empty(), "Skinned mesh instance references a Skeleton3D path")
		if mesh_instance.mesh == null:
			continue
		for surface in range(mesh_instance.mesh.get_surface_count()):
			runtime_surfaces += 1
			var arrays := mesh_instance.mesh.surface_get_arrays(surface)
			var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
			runtime_triangles += int(indices.size() / 3) if not indices.is_empty() else int(vertices.size() / 3)
			var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
			var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
			_check(not weights.is_empty() and weights.size() == bones.size(), "Imported surface retains aligned bone/weight arrays")
			if not weights.is_empty():
				var surface_weights_normalized := true
				var weighted_vertex_count := 0
				for vertex_index in range(int(weights.size() / 4)):
					var influence_count := 0
					var weight_sum := 0.0
					for influence in range(4):
						var weight := weights[vertex_index * 4 + influence]
						if weight > 0.0001:
							influence_count += 1
							weight_sum += weight
					max_influences = maxi(max_influences, influence_count)
					if weight_sum > 0.01:
						weighted_vertex_count += 1
						if absf(weight_sum - 1.0) >= 0.04:
							surface_weights_normalized = false
				_check(weighted_vertex_count > 0 and surface_weights_normalized, "All weighted vertices on a surface have normalized skin weights")
	_check(runtime_triangles == triangle_count, "Godot runtime triangle count matches the GLB index data")
	_check(runtime_surfaces <= int(budget.limits.material_surfaces_max), "Godot runtime surfaces are within the project estimate")
	_check(max_influences > 0 and max_influences <= int(budget.limits.vertex_influences_max), "Skin weights use the project interoperability influence budget")
	if not skeletons.is_empty():
		_check(skeletons[0].get_bone_count() == joint_count, "Godot Skeleton3D bone count matches exported skin joints")
		_check(skeletons[0].find_bone("upper_leg.L") >= 0, "Humanoid semantic leg bone imports by name")

	var player: AnimationPlayer = animation_players[0] if not animation_players.is_empty() else null
	if player != null:
		for clip in required_clips:
			var clip_name := String(clip)
			_check(player.has_animation(clip_name), "Godot AnimationPlayer exposes clip: " + clip_name)
			if player.has_animation(clip_name):
				var animation := player.get_animation(clip_name)
				_check(animation.length > 0.0 and animation.get_track_count() > 0, "Imported clip has keyed motion data: " + clip_name)
		if not skeletons.is_empty() and player.has_animation("walk"):
			var bone_index := skeletons[0].find_bone("upper_leg.L")
			_check(bone_index >= 0, "Walk-motion probe finds the articulated leg bone")
			if bone_index >= 0:
				player.play("walk")
				player.advance(0.0)
				skeletons[0].force_update_all_bone_transforms()
				var pose_start := skeletons[0].get_bone_pose_rotation(bone_index)
				player.advance(0.22)
				skeletons[0].force_update_all_bone_transforms()
				var pose_end := skeletons[0].get_bone_pose_rotation(bone_index)
				_check(not pose_start.is_equal_approx(pose_end), "Walk clip changes the live Godot skeleton pose")

	var imported_selection_available := FileAccess.file_exists(GLB_PATH + ".import")
	var require_imported_scene := OS.get_environment("OWO_REQUIRE_IMPORTED_CHARACTER_SCENE") == "1"
	if not imported_selection_available:
		if require_imported_scene:
			_check(false, "Godot editor import metadata exists for the character GLB")
		else:
			print("SKIP: actual .tscn import check requires Godot editor import metadata")
	else:
		var authored_selection_scene := load("res://scenes/characters/character_selection.tscn") as PackedScene
		_check(authored_selection_scene != null, "Authored character-selection .tscn loads through Godot's normal resource importer")
		if authored_selection_scene != null:
			var authored_selection := authored_selection_scene.instantiate()
			root.add_child(authored_selection)
			await process_frame
			_check(authored_selection is CharacterSelection, "Authored selection scene uses the reusable CharacterSelection controller")
			_check(authored_selection.get_current_definition() != null and authored_selection.get_current_definition().character_id == &"kemi_adebayo", "Authored selection scene loads Kemi's data resource")
			_check(authored_selection.current_visual != null and not _collect_meshes(authored_selection.current_visual).is_empty(), "Authored selection scene instances the imported character mesh")
			_check(authored_selection.camera.current, "Authored selection scene activates its inspection camera")
			_check(authored_selection.find_child("WorldEnvironment", true, false) is WorldEnvironment, "Authored selection scene includes its WorldEnvironment")
			authored_selection.free()
			await process_frame

	# Exercise the same selection controller against the exact imported character,
	# without coupling it to the Phase 002 player, district, or mobile controls.
	var definition_script := load(DEFINITION_SCRIPT_PATH) as Script
	var selection_script := load(SELECTION_SCRIPT_PATH) as Script
	_check(definition_script != null and selection_script != null, "Character data and selection scripts load")
	if definition_script == null or selection_script == null:
		_finish()
		return
	var definition = definition_script.new()
	definition.character_id = &"kemi_adebayo"
	definition.display_name = "Kemi Adebayo"
	definition.bio = "Vehicle electrical and audio technician."
	definition.role = "Technician · driver"
	definition.accent_color = Color(0.035, 0.48, 0.43, 1)
	definition.visual_scene = visual_pack
	definition.idle_clip = &"idle"
	var selection := _build_selection_probe(selection_script, definition)
	root.add_child(selection)
	await process_frame
	_check(selection.get_current_definition() == definition, "Selection scene instantiates the active data-driven character")
	_check(selection.current_visual != null and not _collect_meshes(selection.current_visual).is_empty(), "Selection preview instantiates the real imported character mesh")
	_check(selection.name_label.text == "Kemi Adebayo", "Selection UI shows character identity metadata")
	_check(selection.previous_button.disabled and selection.next_button.disabled, "Single-character roster disables unavailable navigation")
	selection.show_character(-1)
	_check(selection.selected_index == 0, "Character roster wraps safely at its current boundary")
	var chosen: Array[StringName] = []
	selection.character_selected.connect(func(selected_definition: Resource) -> void:
		chosen.append(selected_definition.character_id)
	)
	selection.select_button.pressed.emit()
	_check(chosen == [&"kemi_adebayo"], "Select button emits the chosen character definition")
	_check(selection.status_label.text == "Kemi Adebayo selected", "Selection confirmation state is visible")
	var selection_pivot: Node3D = selection.get("orbit_pivot") as Node3D
	var selection_camera: Camera3D = selection.get("camera") as Camera3D
	var prior_yaw: float = selection_pivot.rotation.y
	selection._orbit(Vector2(30, 200), 0.01)
	_check(not is_equal_approx(selection.orbit_pivot.rotation.y, prior_yaw), "Inspection orbit changes camera yaw")
	_check(absf(selection.orbit_pivot.rotation.x) <= deg_to_rad(24.1), "Inspection orbit clamps camera pitch")
	var camera_distance: float = selection_camera.position.z
	var touch_a := InputEventScreenTouch.new()
	touch_a.index = 0
	touch_a.pressed = true
	touch_a.position = Vector2(100, 100)
	selection._unhandled_input(touch_a)
	var touch_b := InputEventScreenTouch.new()
	touch_b.index = 1
	touch_b.pressed = true
	touch_b.position = Vector2(200, 100)
	selection._unhandled_input(touch_b)
	var pinch := InputEventScreenDrag.new()
	pinch.index = 1
	pinch.position = Vector2(250, 100)
	pinch.relative = Vector2(50, 0)
	selection._unhandled_input(pinch)
	_check(selection_camera.position.z < camera_distance, "Two-finger pinch zooms toward the model")
	touch_a.pressed = false
	selection._unhandled_input(touch_a)
	touch_b.pressed = false
	selection._unhandled_input(touch_b)
	_check(selection.touch_points.is_empty() and selection.screen_drag_index == -1, "Touch release clears character-inspection drag state")

	model_instance.free()
	selection.free()
	generated_visual.free()
	definition = null
	visual_pack = null
	state = null
	document = null
	await process_frame
	await process_frame
	_finish()

func _build_selection_probe(selection_script: Script, definition: Resource) -> Node3D:
	var selection := Node3D.new()
	selection.name = "SelectionProbe"
	selection.set_script(selection_script)
	var orbit := Node3D.new()
	orbit.name = "OrbitPivot"
	selection.add_child(orbit)
	var anchor := Node3D.new()
	anchor.name = "ModelAnchor"
	anchor.position.y = -0.9
	orbit.add_child(anchor)
	var camera := Camera3D.new()
	camera.name = "Camera3D"
	orbit.add_child(camera)
	var interface := CanvasLayer.new()
	interface.name = "Interface"
	selection.add_child(interface)
	var root_control := Control.new()
	root_control.name = "Root"
	interface.add_child(root_control)
	var panel := PanelContainer.new()
	panel.name = "Panel"
	root_control.add_child(panel)
	var content := VBoxContainer.new()
	content.name = "Content"
	panel.add_child(content)
	for label_name in ["NameLabel", "RoleLabel", "BioLabel", "StatusLabel"]:
		var label := Label.new()
		label.name = label_name
		content.add_child(label)
	var buttons := HBoxContainer.new()
	buttons.name = "RosterButtons"
	content.add_child(buttons)
	var previous := Button.new()
	previous.name = "PreviousButton"
	buttons.add_child(previous)
	var next := Button.new()
	next.name = "NextButton"
	buttons.add_child(next)
	var select := Button.new()
	select.name = "SelectButton"
	content.add_child(select)
	var roster: Array[CharacterDefinition] = [definition as CharacterDefinition]
	selection.set("characters", roster)
	return selection

func _assign_scene_owner(root_node: Node, node: Node) -> void:
	for child in node.get_children():
		child.owner = root_node
		_assign_scene_owner(root_node, child)

func _collect_skeletons(node: Node) -> Array[Skeleton3D]:
	var found: Array[Skeleton3D] = []
	if node is Skeleton3D:
		found.append(node as Skeleton3D)
	for child in node.get_children():
		found.append_array(_collect_skeletons(child))
	return found

func _collect_meshes(node: Node) -> Array[MeshInstance3D]:
	var found: Array[MeshInstance3D] = []
	if node is MeshInstance3D:
		found.append(node as MeshInstance3D)
	for child in node.get_children():
		found.append_array(_collect_meshes(child))
	return found

func _collect_animation_players(node: Node) -> Array[AnimationPlayer]:
	var found: Array[AnimationPlayer] = []
	if node is AnimationPlayer:
		found.append(node as AnimationPlayer)
	for child in node.get_children():
		found.append_array(_collect_animation_players(child))
	return found

func _read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed as Dictionary if parsed is Dictionary else {}

func _check(condition: bool, message: String) -> void:
	if condition:
		passes += 1
		print("PASS: " + message)
	else:
		failures.append(message)
		push_error("FAIL: " + message)

func _finish() -> void:
	print("CHARACTER_PIPELINE: %d passed, %d failed" % [passes, failures.size()])
	if not failures.is_empty():
		for failure in failures:
			push_error("CHARACTER_PIPELINE_FAILURE: " + failure)
		quit(1)
	else:
		quit(0)
