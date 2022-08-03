@tool
extends HBoxContainer

# Node references
@onready var label : Label = $Label
@onready var input : LineEdit = $Input

# Public properties
var sample_text : String = ""

signal text_changed(value)

func _ready() -> void:
	input.text_changed.connect(self._on_input_text_changed)

func _on_input_text_changed(value : String) -> void:
	sample_text = value
	text_changed.emit(value)
