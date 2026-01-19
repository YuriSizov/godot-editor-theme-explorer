@tool
extends VBoxContainer

signal value_changed(value: String)

var font_style: Font = null:
	set = set_font_style
var font_size: int = 0:
	set = set_font_size

@onready var _sample_label: Label = %Label
@onready var _sample_value: LineEdit = %Value
@onready var _preview_label: Label = %Preview


func _ready() -> void:
	_update_theme()
	_update_preview_font()
	_update_preview_sample()

	_sample_value.text_changed.connect(_update_preview_sample.unbind(1))


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		_update_theme()


func _update_theme() -> void:
	if not Engine.is_editor_hint() || not is_node_ready() || get_tree().edited_scene_root == self:
		return

	_preview_label.add_theme_color_override("font_color", get_theme_color("accent_color", "Editor"))
	_preview_label.add_theme_stylebox_override("normal", get_theme_stylebox("panel", "Panel"))


# Properties.

func set_font_style(value: Font) -> void:
	if font_style == value:
		return

	font_style = value
	_update_preview_font()


func set_font_size(value: int) -> void:
	if font_size == value:
		return

	font_size = value
	_update_preview_font()


func get_sample_text() -> String:
	return _sample_value.text


# Helpers.

func _update_preview_font() -> void:
	if not is_node_ready():
		return

	if font_style:
		_preview_label.add_theme_font_override("font", font_style)
	else:
		_preview_label.remove_theme_font_override("font")

	if font_size > 0:
		_preview_label.add_theme_font_size_override("font_size", font_size)
	else:
		_preview_label.remove_theme_font_size_override("font_size")


func _update_preview_sample() -> void:
	if not is_node_ready():
		return

	var sample_text := _sample_value.text.strip_edges()
	if sample_text.is_empty():
		sample_text = "Sample Text"

	_preview_label.text = sample_text
	value_changed.emit(sample_text)
