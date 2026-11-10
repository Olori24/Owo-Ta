extends Node

var selected_character: CharacterDefinition

func set_selected_character(definition: CharacterDefinition) -> void:
	if definition == null:
		push_error("Cannot select an empty CharacterDefinition.")
		return
	selected_character = definition

func get_selected_character() -> CharacterDefinition:
	return selected_character

func clear_selected_character() -> void:
	selected_character = null
