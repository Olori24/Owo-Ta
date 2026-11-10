extends Node3D
class_name CharacterSelection

signal character_selected(definition: CharacterDefinition)

@export var characters: Array[CharacterDefinition] = []
@export var start_adventure_on_select: bool = true

@onready var orbit_pivot: Node3D = $OrbitPivot
@onready var camera: Camera3D = $OrbitPivot/Camera3D
@onready var model_anchor: Node3D = $OrbitPivot/ModelAnchor
@onready var name_label: Label = $Interface/Root/Panel/Content/NameLabel
@onready var role_label: Label = $Interface/Root/Panel/Content/RoleLabel
@onready var bio_label: Label = $Interface/Root/Panel/Content/BioLabel
@onready var status_label: Label = $Interface/Root/Panel/Content/StatusLabel
@onready var previous_button: Button = $Interface/Root/Panel/Content/RosterButtons/PreviousButton
@onready var next_button: Button = $Interface/Root/Panel/Content/RosterButtons/NextButton
@onready var select_button: Button = $Interface/Root/Panel/Content/SelectButton

var selected_index := 0
var current_definition: CharacterDefinition
var current_visual: Node3D
var orbit_dragging := false
var screen_drag_index := -1
var touch_points: Dictionary = {}
var previous_pinch_distance := 0.0

func _ready() -> void:
	camera.position = Vector3(0.0, 1.05, 3.2)
	camera.look_at(Vector3(0.0, 0.93, 0.0), Vector3.UP)
	previous_button.pressed.connect(_step_character.bind(-1))
	next_button.pressed.connect(_step_character.bind(1))
	select_button.pressed.connect(_select_current)
	if characters.is_empty():
		push_error("CharacterSelection needs at least one CharacterDefinition.")
		select_button.disabled = true
		return
	show_character(0)

func show_character(index: int) -> void:
	if characters.is_empty():
		return
	selected_index = posmod(index, characters.size())
	current_definition = characters[selected_index]
	if current_visual != null:
		model_anchor.remove_child(current_visual)
		current_visual.queue_free()
	if current_definition.visual_scene == null:
		push_error("CharacterDefinition has no visual scene: " + str(current_definition.character_id))
		return
	var instance := current_definition.visual_scene.instantiate()
	if not instance is Node3D:
		push_error("Character visual root must be Node3D: " + str(current_definition.character_id))
		instance.free()
		return
	current_visual = instance as Node3D
	model_anchor.add_child(current_visual)
	current_visual.name = "SelectedCharacterVisual"
	name_label.text = current_definition.display_name
	role_label.text = current_definition.role
	bio_label.text = current_definition.bio
	status_label.text = "Character %d of %d" % [selected_index + 1, characters.size()]
	select_button.text = "Select %s" % current_definition.display_name
	select_button.modulate = current_definition.accent_color
	previous_button.disabled = characters.size() < 2
	next_button.disabled = characters.size() < 2
	_play_idle_if_available()

func get_current_definition() -> CharacterDefinition:
	return current_definition

func _play_idle_if_available() -> void:
	if current_visual == null:
		return
	var player := _find_animation_player(current_visual)
	if player == null:
		return
	var clip := String(current_definition.idle_clip)
	if player.has_animation(clip):
		player.autoplay = ""
		player.stop()
		player.play(clip)

func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer
	for child in node.get_children():
		var found := _find_animation_player(child)
		if found != null:
			return found
	return null

func _step_character(direction: int) -> void:
	show_character(selected_index + direction)

func _select_current() -> void:
	if current_definition == null:
		return
	status_label.text = "%s selected" % current_definition.display_name
	var game_session := get_node_or_null("/root/GameSession")
	if game_session == null:
		push_error("GameSession autoload is unavailable; cannot launch the selected character.")
		return
	game_session.call("set_selected_character", current_definition)
	character_selected.emit(current_definition)
	if start_adventure_on_select:
		var change_error := get_tree().change_scene_to_file("res://scenes/world/first_district.tscn")
		if change_error != OK:
			push_error("Could not enter the first district: " + str(change_error))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			orbit_dragging = mouse_event.pressed
			get_viewport().set_input_as_handled()
		elif mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.position.z = maxf(2.2, camera.position.z - 0.25)
			get_viewport().set_input_as_handled()
		elif mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.position.z = minf(5.5, camera.position.z + 0.25)
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and orbit_dragging:
		_orbit((event as InputEventMouseMotion).relative, 0.008)
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			touch_points[touch.index] = touch.position
			if touch_points.size() == 1:
				screen_drag_index = touch.index
			elif touch_points.size() == 2:
				var points: Array = touch_points.values()
				previous_pinch_distance = (points[0] as Vector2).distance_to(points[1] as Vector2)
		else:
			touch_points.erase(touch.index)
			if touch_points.size() < 2:
				previous_pinch_distance = 0.0
			if touch.index == screen_drag_index:
				screen_drag_index = int(touch_points.keys()[0]) if not touch_points.is_empty() else -1
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if touch_points.has(drag.index):
			touch_points[drag.index] = drag.position
		if touch_points.size() >= 2:
			var points: Array = touch_points.values()
			var pinch_distance := (points[0] as Vector2).distance_to(points[1] as Vector2)
			if previous_pinch_distance > 0.0:
				camera.position.z = clampf(camera.position.z - (pinch_distance - previous_pinch_distance) * 0.008, 2.2, 5.5)
			previous_pinch_distance = pinch_distance
			get_viewport().set_input_as_handled()
		elif screen_drag_index < 0 or drag.index == screen_drag_index:
			_orbit(drag.relative, 0.006)
			get_viewport().set_input_as_handled()

func _orbit(relative: Vector2, sensitivity: float) -> void:
	orbit_pivot.rotation.y -= relative.x * sensitivity
	orbit_pivot.rotation.x = clampf(orbit_pivot.rotation.x - relative.y * sensitivity, deg_to_rad(-24.0), deg_to_rad(24.0))
