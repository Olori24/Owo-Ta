extends Resource
class_name CharacterDefinition

@export var character_id: StringName
@export var display_name: String
@export_multiline var bio: String
@export var role: String
@export var accent_color: Color = Color.WHITE
@export var visual_scene: PackedScene
@export var idle_clip: StringName = &"idle"
@export var walk_clip: StringName = &"walk"
@export var run_clip: StringName = &"run"
@export var jump_clip: StringName = &"jump"
@export var landing_clip: StringName = &"landing"
@export var turn_clip: StringName = &"turn"
@export var stop_clip: StringName = &"stop"
