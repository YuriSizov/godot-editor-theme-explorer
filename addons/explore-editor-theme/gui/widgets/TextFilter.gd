@tool
extends HBoxContainer

signal value_changed(value: String)

@export var filter_label: String = "":
	set = set_filter_label

@onready var _filter_label: Label = %Label
@onready var _filter_value: LineEdit = %Value


func _ready() -> void:
	_update_label()

	_filter_value.text_changed.connect(value_changed.emit)


# Properties.

func set_filter_label(value: String) -> void:
	if filter_label == value:
		return

	filter_label = value
	_update_label()


func get_filter_value() -> String:
	return _filter_value.text


# Helpers.

func _update_label() -> void:
	if not is_node_ready():
		return

	_filter_label.text = filter_label
