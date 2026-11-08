extends Control
class_name OwoTaMobileControls

var active_move_touch := -1
var active_look_touch := -1
var move_origin := Vector2.ZERO
var move_vector := Vector2.ZERO
var last_look_position := Vector2.ZERO
var jump_touch := -1

const JOYSTICK_RADIUS := 78.0
const JUMP_RADIUS := 48.0
const JUMP_BUTTON_OFFSET := Vector2(82.0, 92.0)

func _ready() -> void:
	set_process(true)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_ensure_input_actions()

func _ensure_input_actions() -> void:
	for action in ["move_left", "move_right", "move_forward", "move_back", "jump"]:
		if not InputMap.has_action(action):
			InputMap.add_action(action)

func _process(_delta: float) -> void:
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		_release_all_controls()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if event.position.x < size.x * 0.48 and active_move_touch == -1:
				active_move_touch = event.index
				move_origin = event.position
				move_vector = Vector2.ZERO
			elif _is_jump_button_position(event.position) and jump_touch == -1:
				jump_touch = event.index
				Input.action_press("jump")
			elif event.position.x >= size.x * 0.48 and active_look_touch == -1:
				active_look_touch = event.index
				last_look_position = event.position
		else:
			if event.index == active_move_touch:
				active_move_touch = -1
				move_vector = Vector2.ZERO
				_update_move_actions()
			if event.index == active_look_touch:
				active_look_touch = -1
			if event.index == jump_touch:
				jump_touch = -1
				Input.action_release("jump")
	elif event is InputEventScreenDrag:
		if event.index == active_move_touch:
			move_vector = (event.position - move_origin).limit_length(JOYSTICK_RADIUS) / JOYSTICK_RADIUS
			_update_move_actions()
		elif event.index == active_look_touch:
			var player := get_tree().get_first_node_in_group("player")
			if player and player.has_method("apply_look"):
				player.apply_look(event.position - last_look_position)
			last_look_position = event.position

func _jump_button_center() -> Vector2:
	return Vector2(size.x - JUMP_BUTTON_OFFSET.x, size.y - JUMP_BUTTON_OFFSET.y)

func _is_jump_button_position(position: Vector2) -> bool:
	return position.distance_to(_jump_button_center()) <= JUMP_RADIUS

func _update_move_actions() -> void:
	_set_action("move_left", move_vector.x < -0.2)
	_set_action("move_right", move_vector.x > 0.2)
	_set_action("move_forward", move_vector.y < -0.2)
	_set_action("move_back", move_vector.y > 0.2)

func _set_action(action: String, pressed: bool) -> void:
	if pressed:
		Input.action_press(action)
	else:
		Input.action_release(action)

func _release_all_controls() -> void:
	for action in ["move_left", "move_right", "move_forward", "move_back", "jump"]:
		Input.action_release(action)
	active_move_touch = -1
	active_look_touch = -1
	jump_touch = -1
	move_origin = Vector2.ZERO
	move_vector = Vector2.ZERO
	last_look_position = Vector2.ZERO

func _draw() -> void:
	if active_move_touch != -1:
		draw_circle(move_origin, JOYSTICK_RADIUS, Color(0.1, 0.15, 0.18, 0.35))
		draw_circle(move_origin + move_vector * JOYSTICK_RADIUS, 28.0, Color(0.35, 0.85, 0.75, 0.8))
	draw_circle(_jump_button_center(), JUMP_RADIUS, Color(0.95, 0.72, 0.25, 0.45))
	draw_string(
		ThemeDB.fallback_font,
		_jump_button_center() + Vector2(-26.0, 5.0),
		"JUMP",
		HORIZONTAL_ALIGNMENT_LEFT,
		64.0,
		16,
		Color.WHITE
	)
