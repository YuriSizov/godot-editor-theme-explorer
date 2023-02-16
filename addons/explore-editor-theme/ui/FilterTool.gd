@tool
extends HBoxContainer

var _label_text : String = "Filter"
@export var label_text : String:
	set(value):
		_label_text = value
		_update_label()
	get:
		return _label_text

# Node references
@onready var label : Label = $Label
@onready var input : LineEdit = $Input

# Public properties
var filter_text : String = ""

signal text_changed(value)

func _ready() -> void:
	_update_label()
	
	input.text_changed.connect(self._on_input_text_changed)

func _update_label() -> void:
	if (!is_inside_tree()):
		return
	
	label.text = _label_text

func _on_input_text_changed(value : String) -> void:
	filter_text = value
	text_changed.emit(value)
