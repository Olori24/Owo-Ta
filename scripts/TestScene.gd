extends Control

@onready var title_label: Label = $Title
@onready var status_label: Label = $Status

func _ready() -> void:
    print("OWO TÀ foundation loaded successfully.")
    if title_label:
        title_label.text = "OWO TÀ"
    if status_label:
        status_label.text = "Foundation status: ready"
