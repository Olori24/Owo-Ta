extends CharacterBody3D
class_name OwoTaPlayer

@export var move_speed: float = 5.5
@export var acceleration: float = 18.0
@export var jump_velocity: float = 5.0
@export var look_sensitivity: float = 0.004

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera_pivot: Node3D = $CameraPivot

func _ready() -> void:
	add_to_group("player")
	_register_actions()

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
		InputMap.action_add_event(action, event)

func _physics_process(delta: float) -> void:
	var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var camera_basis := camera_pivot.global_transform.basis
	var camera_forward := -camera_basis.z
	var camera_right := camera_basis.x
	camera_forward.y = 0.0
	camera_right.y = 0.0
	camera_forward = camera_forward.normalized()
	camera_right = camera_right.normalized()
	var direction := (camera_right * input_vector.x - camera_forward * input_vector.y).normalized()

	velocity.x = move_toward(velocity.x, direction.x * move_speed, acceleration * delta)
	velocity.z = move_toward(velocity.z, direction.z * move_speed, acceleration * delta)

	if not is_on_floor():
		velocity.y -= gravity * delta
	elif Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity

	move_and_slide()

	if direction.length() > 0.1:
		rotation.y = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), 10.0 * delta)

func apply_look(delta_pixels: Vector2) -> void:
	camera_pivot.rotate_y(-delta_pixels.x * look_sensitivity)
	camera_pivot.rotation.x = clamp(
		camera_pivot.rotation.x - delta_pixels.y * look_sensitivity,
		deg_to_rad(-35.0),
		deg_to_rad(25.0)
	)
