extends CharacterBody3D
class_name OwoTaPlayer

@export var move_speed: float = 5.5
@export var acceleration: float = 18.0
@export var jump_velocity: float = 5.0
@export var look_sensitivity: float = 0.004

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var jump_requested := false
var character_animation_player: AnimationPlayer
var current_animation := ""
var landing_animation_active := false
var selected_character_definition: CharacterDefinition
var animation_clip_names: Dictionary = {"idle": "idle", "walk": "walk", "run": "run", "jump": "jump", "landing": "landing"}

@onready var camera_pivot: Node3D = $CameraPivot
@onready var visual_body: Node3D = $Body

func _ready() -> void:
	add_to_group("player")
	_register_actions()
	_install_selected_character_visual()
	character_animation_player = _find_animation_player($Body/CharacterVisual)
	if character_animation_player != null:
		character_animation_player.stop()
		character_animation_player.animation_finished.connect(_on_character_animation_finished)
		_configure_character_animation_loops()
	_play_character_animation("idle")

func _install_selected_character_visual() -> void:
	var game_session := get_node_or_null("/root/GameSession")
	if game_session == null:
		push_error("GameSession autoload is unavailable; using the default Kemi visual.")
		return
	selected_character_definition = game_session.call("get_selected_character") as CharacterDefinition
	if selected_character_definition == null or selected_character_definition.visual_scene == null:
		return
	animation_clip_names = {
		"idle": String(selected_character_definition.idle_clip),
		"walk": String(selected_character_definition.walk_clip),
		"run": String(selected_character_definition.run_clip),
		"jump": String(selected_character_definition.jump_clip),
		"landing": String(selected_character_definition.landing_clip)
	}
	var existing_visual := visual_body.get_node_or_null("CharacterVisual")
	if existing_visual != null:
		visual_body.remove_child(existing_visual)
		existing_visual.queue_free()
	var instance := selected_character_definition.visual_scene.instantiate()
	if not instance is Node3D:
		push_error("Selected character visual root must be Node3D: " + String(selected_character_definition.character_id))
		instance.free()
		return
	instance.name = "CharacterVisual"
	var imported_player := _find_animation_player(instance)
	if imported_player != null:
		imported_player.autoplay = ""
	visual_body.add_child(instance)

func _character_clip(animation_key: String) -> String:
	return String(animation_clip_names.get(animation_key, animation_key))

func _register_actions() -> void:
	var bindings := {
		"move_left": KEY_A,
		"move_right": KEY_D,
		"move_forward": KEY_W,
		"move_back": KEY_S,
		"jump": KEY_SPACE
	}
	for action in bindings:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		var event := InputEventKey.new()
		event.physical_keycode = bindings[action]
		if not InputMap.action_has_event(action, event):
			InputMap.action_add_event(action, event)

func _camera_relative_direction(input_vector: Vector2) -> Vector3:
	var camera_basis := camera_pivot.global_transform.basis
	var camera_forward := -camera_basis.z
	var camera_right := camera_basis.x
	camera_forward.y = 0.0
	camera_right.y = 0.0
	camera_forward = camera_forward.normalized()
	camera_right = camera_right.normalized()
	return (camera_right * input_vector.x - camera_forward * input_vector.y).normalized()

func request_jump() -> void:
	jump_requested = true

func cancel_jump() -> void:
	jump_requested = false

func _physics_process(delta: float) -> void:
	var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := _camera_relative_direction(input_vector)

	velocity.x = move_toward(velocity.x, direction.x * move_speed, acceleration * delta)
	velocity.z = move_toward(velocity.z, direction.z * move_speed, acceleration * delta)

	var jump_pressed := jump_requested or Input.is_action_just_pressed("jump")
	jump_requested = false
	if not is_on_floor():
		velocity.y -= gravity * delta
	elif jump_pressed:
		velocity.y = jump_velocity

	var was_on_floor := is_on_floor()
	move_and_slide()
	_update_character_animation(direction, was_on_floor)

	# Rotate only the visible mesh. Rotating CharacterBody3D would also rotate
	# CameraPivot and feed the character's facing back into camera-relative movement.
	if direction.length() > 0.1:
		visual_body.rotation.y = lerp_angle(
			visual_body.rotation.y,
			atan2(-direction.x, -direction.z),
			10.0 * delta
		)

func apply_look(delta_pixels: Vector2) -> void:
	camera_pivot.rotate_y(-delta_pixels.x * look_sensitivity)
	camera_pivot.rotation.x = clamp(
		camera_pivot.rotation.x - delta_pixels.y * look_sensitivity,
		deg_to_rad(-35.0),
		deg_to_rad(25.0)
	)

func get_character_animation_player() -> AnimationPlayer:
	return character_animation_player

func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer
	for child in node.get_children():
		var found := _find_animation_player(child)
		if found != null:
			return found
	return null

func _configure_character_animation_loops() -> void:
	for animation_key in ["idle", "walk", "run"]:
		var animation_name := _character_clip(animation_key)
		if character_animation_player.has_animation(animation_name):
			character_animation_player.get_animation(animation_name).loop_mode = Animation.LOOP_LINEAR
	var landing_clip := _character_clip("landing")
	if character_animation_player.has_animation(landing_clip):
		character_animation_player.get_animation(landing_clip).loop_mode = Animation.LOOP_NONE

func _on_character_animation_finished(animation_name: StringName) -> void:
	if String(animation_name) == _character_clip("landing"):
		landing_animation_active = false
		current_animation = ""

func _play_character_animation(animation_key: String) -> void:
	var animation_name := _character_clip(animation_key)
	if character_animation_player == null or not character_animation_player.has_animation(animation_name):
		return
	if current_animation == animation_name and character_animation_player.is_playing():
		return
	current_animation = animation_name
	landing_animation_active = animation_key == "landing"
	character_animation_player.play(animation_name)

func _update_character_animation(direction: Vector3, was_on_floor: bool) -> void:
	if not is_on_floor():
		landing_animation_active = false
		_play_character_animation("jump")
	elif not was_on_floor:
		_play_character_animation("landing")
	elif landing_animation_active and character_animation_player != null and character_animation_player.is_playing():
		return
	elif direction.length() > 0.1:
		_play_character_animation("run" if Vector2(velocity.x, velocity.z).length() > 4.5 else "walk")
	else:
		_play_character_animation("idle")
