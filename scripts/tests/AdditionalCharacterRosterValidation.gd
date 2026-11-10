extends SceneTree

const ROSTER_PATH := "res://assets/characters/phase003b_roster.json"
const PROJECT_LIMITS := {
	"glb_bytes_max": 10485760,
	"triangles_max": 30000,
	"material_surfaces_max": 5,
	"texture_files_max": 4,
	"texture_dimension_max": 2048,
	"texture_total_bytes_max": 2097152,
	"deforming_bones_max": 65,
	"vertex_influences_max": 4,
}

var failures: Array[String] = []
var passes := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var roster := _read_json(ROSTER_PATH)
	_check(not roster.is_empty(), "Phase 003B roster manifest parses")
	var rows: Array = roster.get("characters", [])
	_check(rows.size() == 3, "Roster contains exactly Kemi and the two new characters")
	var ids: Array[String] = []
	var gender_pair: Dictionary = {}
	var definitions: Array[CharacterDefinition] = []
	for row_value in rows:
		if not row_value is Dictionary:
			_check(false, "Roster entry is an object")
			continue
		var row: Dictionary = row_value
		var character_id := String(row.get("character_id", ""))
		var definition_path := String(row.get("definition", ""))
		ids.append(character_id)
		gender_pair[String(row.get("gender_presentation", "unspecified"))] = true
		_check(FileAccess.file_exists(definition_path), "Character definition exists: " + character_id)
		if not FileAccess.file_exists(definition_path):
			continue
		var definition := load(definition_path) as CharacterDefinition
		_check(definition != null, "Definition loads as CharacterDefinition: " + character_id)
		if definition == null:
			continue
		_check(definition.character_id == StringName(character_id), "Definition ID matches manifest: " + character_id)
		_check(not definition.display_name.is_empty() and not definition.role.is_empty() and not definition.bio.is_empty(), "Definition has identity metadata: " + character_id)
		_check(definition.visual_scene != null, "Definition references an imported visual scene: " + character_id)
		if definition.visual_scene == null:
			continue
		definitions.append(definition)
		if character_id == "kemi_adebayo":
			_check(String(row.get("authored_in_phase", "")) == "003", "Existing Kemi entry is referenced without copying her source")
			continue
		await _validate_character(character_id, definition, definition_path)

	_check(ids.has("kemi_adebayo") and ids.has("tunde_balogun") and ids.has("amara_okonkwo"), "Roster IDs are the unchanged Kemi plus Tunde and Amara")
	_check(gender_pair.has("male") and gender_pair.has("female"), "The new pair includes male and female representation")
	_check(definitions.size() == 3, "All three typed character definitions are available to the selector")
	if definitions.size() == 3:
		await _exercise_selection(definitions)
	_finish()

func _validate_character(character_id: String, definition: CharacterDefinition, definition_path: String) -> void:
	var base := "res://assets/characters/" + character_id + "/"
	var glb_path := base + character_id + ".glb"
	var budget := _read_json(base + "asset_budget.json")
	_check(not budget.is_empty(), character_id + " budget manifest parses")
	_check(String(budget.get("character_id", "")) == character_id, character_id + " budget ID matches")
	_check(FileAccess.file_exists(base + "PROVENANCE.md"), character_id + " has provenance and license documentation")
	_check(FileAccess.file_exists(base + "source/.gdignore"), character_id + " editable Blender source is excluded from runtime imports")
	var generation_script_path := String(budget.get("toolchain", {}).get("generation_script", ""))
	if not generation_script_path.begins_with("res://"):
		generation_script_path = "res://" + generation_script_path
	_check(FileAccess.file_exists(generation_script_path), character_id + " deterministic Blender build script exists")
	var blend_path := base + "source/" + character_id + ".blend"
	var blend_bytes := FileAccess.get_file_as_bytes(blend_path) if FileAccess.file_exists(blend_path) else PackedByteArray()
	_check(blend_bytes.size() > 8 and blend_bytes.slice(0, 7).get_string_from_ascii() == "BLENDER", character_id + " editable Blender source exists and has a valid signature")

	var bytes := FileAccess.get_file_as_bytes(glb_path)
	_check(bytes.size() > 20, character_id + " GLB exists and is nonempty")
	if bytes.size() < 20:
		return
	_check(bytes.slice(0, 4).get_string_from_ascii() == "glTF" and bytes.decode_u32(4) == 2, character_id + " uses binary glTF 2.0")
	var limits: Dictionary = budget.get("limits", {})
	var measured: Dictionary = budget.get("measured_export", {})
	_check(bytes.size() <= int(limits.get("glb_bytes_max", PROJECT_LIMITS.glb_bytes_max)), character_id + " GLB is inside the project package budget")
	var hash_context := HashingContext.new()
	hash_context.start(HashingContext.HASH_SHA256)
	hash_context.update(bytes)
	_check(bytes.size() == int(measured.get("glb_bytes", -1)), character_id + " GLB size matches its measured export record")
	_check(hash_context.finish().hex_encode() == String(measured.get("glb_sha256", "")), character_id + " GLB SHA-256 matches its reproducible export record")
	_check(blend_bytes.size() == int(measured.get("editable_blend_bytes", -1)), character_id + " editable source size matches its measured record")
	var json_length := int(bytes.decode_u32(12))
	_check(json_length >= 0 and json_length <= bytes.size() - 20, character_id + " GLB JSON chunk stays within file bounds")
	if json_length < 0 or json_length > bytes.size() - 20:
		return
	var gltf := JSON.parse_string(bytes.slice(20, 20 + json_length).get_string_from_utf8().strip_edges()) as Dictionary
	_check(not gltf.is_empty(), character_id + " embedded GLB manifest parses")
	if gltf.is_empty():
		return

	var vertices := 0
	var triangles := 0
	var surfaces := 0
	for mesh_data in gltf.get("meshes", []):
		for primitive_value in mesh_data.get("primitives", []):
			surfaces += 1
			var primitive: Dictionary = primitive_value
			var attributes: Dictionary = primitive.get("attributes", {})
			for attribute_name in ["POSITION", "NORMAL", "TEXCOORD_0", "JOINTS_0", "WEIGHTS_0"]:
				_check(attributes.has(attribute_name), character_id + " primitive has " + attribute_name)
			if attributes.has("POSITION"):
				vertices += int(gltf.accessors[int(attributes.POSITION)].count)
			if primitive.has("indices"):
				triangles += int(int(gltf.accessors[int(primitive.indices)].count) / 3)
	_check(vertices > 0, character_id + " has nonempty skinned geometry")
	_check(triangles > 0 and triangles <= int(limits.get("triangles_max", PROJECT_LIMITS.triangles_max)), character_id + " triangles fit the project budget")
	_check(surfaces > 0 and surfaces <= int(limits.get("material_surfaces_max", PROJECT_LIMITS.material_surfaces_max)), character_id + " draw surfaces fit the project budget")
	_check(vertices == int(measured.get("vertices", -1)) and triangles == int(measured.get("triangles", -1)), character_id + " vertex and triangle counts match the measured export")
	_check(surfaces == int(measured.get("material_surfaces", -1)), character_id + " surface count matches the measured export")

	var skins: Array = gltf.get("skins", [])
	_check(not skins.is_empty(), character_id + " has a deforming skin")
	var bone_count := 0
	if not skins.is_empty():
		bone_count = skins[0].get("joints", []).size()
	_check(bone_count >= 20 and bone_count <= int(limits.get("deforming_bones_max", PROJECT_LIMITS.deforming_bones_max)), character_id + " skeleton has a usable humanoid joint count")
	_check(bone_count == int(measured.get("skeleton_joints", -1)), character_id + " joint count matches the measured export")
	var materials: Array = gltf.get("materials", [])
	_check(materials.size() == 4 and materials.size() == int(measured.get("materials", -1)), character_id + " exports four measured PBR materials")
	for material in materials:
		_check(material.get("pbrMetallicRoughness", {}).has("baseColorTexture"), character_id + " PBR material includes authored base colour")
	var embedded_images: Array = gltf.get("images", [])
	_check(embedded_images.size() == 4 and embedded_images.size() == int(measured.get("embedded_images", -1)), character_id + " embeds four measured authored base-colour images")

	var texture_dir := DirAccess.open(base + "textures")
	var texture_paths: Array[String] = []
	var texture_bytes := 0
	if texture_dir != null:
		for file_name in texture_dir.get_files():
			if file_name.ends_with(".png"):
				var texture_path := base + "textures/" + file_name
				texture_paths.append(texture_path)
				texture_bytes += FileAccess.get_file_as_bytes(texture_path).size()
	_check(texture_paths.size() == 4 and texture_paths.size() <= int(limits.get("texture_files_max", PROJECT_LIMITS.texture_files_max)), character_id + " has four source textures within count budget")
	_check(texture_bytes <= int(limits.get("texture_total_bytes_max", PROJECT_LIMITS.texture_total_bytes_max)), character_id + " source texture bytes fit the project budget")
	_check(texture_bytes == int(measured.get("source_texture_bytes", -1)), character_id + " source texture bytes match the measured export record")
	for texture_path in texture_paths:
		var image := Image.new()
		var image_error := image.load(texture_path)
		_check(image_error == OK, character_id + " source texture decodes: " + texture_path.get_file())
		_check(image_error == OK and maxi(image.get_width(), image.get_height()) <= int(limits.get("texture_dimension_max", PROJECT_LIMITS.texture_dimension_max)), character_id + " texture dimensions fit the project budget")

	var required_clips: Array = budget.get("required_animation_clips", [])
	var expected_action := String(budget.get("expressive_action", ""))
	_check(required_clips.size() == 8 and required_clips.has(expected_action), character_id + " has seven locomotion clips and its named expressive action")
	var exported_names: Array[String] = []
	for animation in gltf.get("animations", []):
		exported_names.append(String(animation.get("name", "")))
	for clip in required_clips:
		_check(exported_names.has(String(clip)), character_id + " exports required clip " + String(clip))
	_check(exported_names.size() == 8 and exported_names.size() == int(measured.get("animation_clip_count", -1)), character_id + " exports exactly eight measured animation clips")

	var imported_scene := load(glb_path) as PackedScene
	_check(imported_scene != null, character_id + " normal Godot resource importer loads the GLB")
	if imported_scene == null:
		return
	var model := imported_scene.instantiate() as Node3D
	_check(model != null, character_id + " imported scene root is Node3D")
	if model == null:
		return
	root.add_child(model)
	await process_frame
	var skeletons := _collect_skeletons(model)
	var meshes := _collect_meshes(model)
	var players := _collect_animation_players(model)
	_check(not skeletons.is_empty(), character_id + " imported scene contains Skeleton3D")
	_check(not meshes.is_empty(), character_id + " imported scene contains visible skinned mesh instances")
	_check(not players.is_empty(), character_id + " imported scene contains AnimationPlayer")
	if skeletons.is_empty() or players.is_empty():
		model.free()
		return
	var skeleton := skeletons[0]
	_check(skeleton.get_bone_count() == bone_count, character_id + " Godot skeleton matches GLB skin joints")
	_check(skeleton.find_bone("upper_leg.L") >= 0 and skeleton.find_bone("head") >= 0 and skeleton.find_bone("hand.R") >= 0, character_id + " retains semantic humanoid bones")
	var maximum_influences := 0
	for mesh_instance in meshes:
		_check(mesh_instance.mesh != null and mesh_instance.skin != null and not mesh_instance.skeleton.is_empty(), character_id + " visible mesh has valid skin/skeleton references")
		if mesh_instance.mesh == null:
			continue
		for surface_index in range(mesh_instance.mesh.get_surface_count()):
			var arrays := mesh_instance.mesh.surface_get_arrays(surface_index)
			var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
			var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
			_check(not weights.is_empty() and weights.size() == bones.size(), character_id + " imported weight and bone arrays align")
			if weights.is_empty() or weights.size() != bones.size():
				continue
			var invalid_normalized_weights := 0
			for vertex_index in range(int(weights.size() / 4)):
				var weight_sum := 0.0
				var influences := 0
				for influence in range(4):
					var weight := weights[vertex_index * 4 + influence]
					if weight > 0.0001:
						influences += 1
						weight_sum += weight
				maximum_influences = maxi(maximum_influences, influences)
				if weight_sum > 0.01 and absf(weight_sum - 1.0) >= 0.04:
					invalid_normalized_weights += 1
			_check(invalid_normalized_weights == 0, character_id + " imported vertex weights are normalized")
	_check(maximum_influences > 0 and maximum_influences <= int(limits.get("vertex_influences_max", PROJECT_LIMITS.vertex_influences_max)), character_id + " skin influence count fits mobile project guardrail")

	var player := players[0]
	for clip_value in required_clips:
		var clip := String(clip_value)
		_check(player.has_animation(clip), character_id + " AnimationPlayer exposes " + clip)
		if not player.has_animation(clip):
			continue
		var animation := player.get_animation(clip)
		_check(animation.length > 0.0 and animation.get_track_count() > 0, character_id + " " + clip + " contains keyed motion")
		if clip == "idle":
			_check(animation.length >= 1.5, character_id + " idle clip preserves the authored 48-frame range at 30 FPS")
		player.stop()
		skeleton.reset_bone_poses()
		var before := _pose_signature(skeleton)
		player.play(clip)
		player.advance(0.0)
		player.advance(maxf(0.08, animation.length * 0.37))
		skeleton.force_update_all_bone_transforms()
		_check(before != _pose_signature(skeleton), character_id + " " + clip + " changes the imported skeleton pose")
	player.stop()
	model.free()
	await process_frame
	var resource := load(definition_path) as CharacterDefinition
	_check(resource != null and resource.character_id == StringName(character_id), character_id + " CharacterDefinition remains loadable")

func _exercise_selection(definitions: Array[CharacterDefinition]) -> void:
	var scene := load("res://scenes/characters/character_selection.tscn") as PackedScene
	_check(scene != null, "Existing character selector scene loads without modification")
	if scene == null:
		return
	var selector := scene.instantiate() as CharacterSelection
	_check(selector != null, "Existing selection controller instantiates")
	if selector == null:
		return
	selector.start_adventure_on_select = false
	var scene_roster_ids: Array[StringName] = []
	for scene_definition in selector.characters:
		scene_roster_ids.append(scene_definition.character_id)
	_check(scene_roster_ids == [&"kemi_adebayo", &"tunde_balogun", &"amara_okonkwo"], "Authored selection scene contains the complete three-character roster")
	selector.characters = definitions
	root.add_child(selector)
	await process_frame
	var selected_ids: Array[StringName] = []
	selector.character_selected.connect(func(definition: CharacterDefinition) -> void:
		selected_ids.append(definition.character_id)
	)
	for index in range(definitions.size()):
		selector.show_character(index)
		await process_frame
		var expected := definitions[index]
		_check(selector.get_current_definition() == expected, "Selector displays roster entry " + String(expected.character_id))
		_check(selector.current_visual != null, "Selector previews imported visual " + String(expected.character_id))
		_check(selector.name_label.text == expected.display_name, "Selector displays identity " + String(expected.character_id))
		_check(not selector.previous_button.disabled and not selector.next_button.disabled, "Three-character roster enables navigation")
		selector._select_current()
		_check(not selected_ids.is_empty() and selected_ids.back() == expected.character_id, "Selector emits selected definition " + String(expected.character_id))
		var game_session := root.get_node_or_null("GameSession")
		_check(game_session != null, "GameSession autoload is available to the selector")
		if game_session != null:
			_check(game_session.call("get_selected_character") == expected, "Game session stores selected definition " + String(expected.character_id))
	selector.free()
	await process_frame
	await _exercise_playable_visuals(definitions)

func _exercise_playable_visuals(definitions: Array[CharacterDefinition]) -> void:
	var player_scene := load("res://scenes/characters/player.tscn") as PackedScene
	_check(player_scene != null, "Playable player scene loads for roster integration")
	if player_scene == null:
		return
	# Give every roster player a real floor so the first physics tick does not
	# incorrectly classify the initial idle pose as a falling/jump animation.
	var test_ground := StaticBody3D.new()
	test_ground.name = "RosterTestGround"
	test_ground.position = Vector3(0, -0.5, 0)
	var ground_collision := CollisionShape3D.new()
	var ground_shape := BoxShape3D.new()
	ground_shape.size = Vector3(100, 1, 100)
	ground_collision.shape = ground_shape
	test_ground.add_child(ground_collision)
	root.add_child(test_ground)
	await physics_frame
	for definition in definitions:
		var game_session := root.get_node_or_null("GameSession")
		_check(game_session != null, "GameSession autoload is available to the playable roster test")
		if game_session == null:
			return
		game_session.call("set_selected_character", definition)
		var player := player_scene.instantiate() as CharacterBody3D
		_check(player != null, "Player scene instantiates for " + String(definition.character_id))
		if player == null:
			continue
		player.position = Vector3.ZERO
		root.add_child(player)
		await process_frame
		await physics_frame
		_check(player.is_on_floor(), "Roster player is grounded before initial animation check: " + String(definition.character_id))
		var visual := player.get_node_or_null("Body/CharacterVisual") as Node3D
		_check(visual != null, "Player mounts selected visual " + String(definition.character_id))
		if visual != null:
			_check(visual.scene_file_path == definition.visual_scene.resource_path, "Player mounts the correct GLB scene for " + String(definition.character_id))
			var animation_players := _collect_animation_players(visual)
			_check(not animation_players.is_empty(), "Selected visual exposes AnimationPlayer for " + String(definition.character_id))
			if not animation_players.is_empty():
				var animation_player := player.call("get_character_animation_player") as AnimationPlayer
				_check(animation_player != null and animation_players.has(animation_player), "Player controller owns an AnimationPlayer inside " + String(definition.character_id))
				if animation_player != null:
					for clip in [String(definition.idle_clip), String(definition.walk_clip), String(definition.run_clip), String(definition.jump_clip), String(definition.landing_clip)]:
						_check(animation_player.has_animation(clip), "Selected visual exposes " + clip + " for " + String(definition.character_id))
					_check(animation_player.autoplay.is_empty(), "Selected visual disables imported autoplay for " + String(definition.character_id))
					var active_clip := String(animation_player.current_animation)
					print("ROSTER_ANIMATION_STATE: " + String(definition.character_id) + " active=" + active_clip + " playing=" + str(animation_player.is_playing()))
					_check(active_clip == String(definition.idle_clip), "Selected visual starts in idle for " + String(definition.character_id) + " (active: " + active_clip + ")")
		player.queue_free()
		await process_frame
	var game_session := root.get_node_or_null("GameSession")
	if game_session != null:
		game_session.call("clear_selected_character")
	test_ground.queue_free()
	await process_frame

func _pose_signature(skeleton: Skeleton3D) -> String:
	var values := PackedFloat32Array()
	for bone_index in range(skeleton.get_bone_count()):
		var pose := skeleton.get_bone_pose(bone_index)
		var rotation := skeleton.get_bone_pose_rotation(bone_index)
		values.append_array([pose.origin.x, pose.origin.y, pose.origin.z, rotation.x, rotation.y, rotation.z, rotation.w])
	return var_to_str(values)

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
	print("ADDITIONAL_CHARACTER_ROSTER: %d passed, %d failed" % [passes, failures.size()])
	if not failures.is_empty():
		for failure in failures:
			push_error("ADDITIONAL_CHARACTER_ROSTER_FAILURE: " + failure)
		quit(1)
	else:
		quit(0)
