@tool
extends MarginContainer

signal item_clicked()

var font_name: String = "":
	set = set_font_name
var font_resource: Font = null:
	set = set_font_resource
var sample_text: String = "Sample Text":
	set = set_sample_text
var selected: bool = false:
	set = set_selected

var _highlight_active_style: StyleBoxFlat = null
var _highlight_inactive_style: StyleBoxFlat = null

@onready var _background_panel: PanelContainer = %BackgroundPanel
@onready var _highlight_panel: Panel = %HighlightPanel

@onready var _font_title: Label = %FontName
@onready var _font_sample: Label = %FontSample


func _ready() -> void:
	_update_theme()

	_update_labels()
	_update_sample_font()
	_update_background()


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		_update_theme()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton

		if mb.button_index == MOUSE_BUTTON_LEFT && not mb.pressed:
			item_clicked.emit()


func _update_theme() -> void:
	if not Engine.is_editor_hint() || not is_node_ready() || get_tree().edited_scene_root == self:
		return

	var panel_style := get_theme_stylebox("panel", "Panel").duplicate()
	panel_style.set_content_margin_all(0)
	_background_panel.add_theme_stylebox_override("panel", panel_style)

	_font_sample.add_theme_color_override("font_color", get_theme_color("accent_color", "Editor"))

	_highlight_active_style = get_theme_stylebox("panel", "Panel").duplicate()
	_highlight_inactive_style = _highlight_active_style.duplicate()
	_highlight_active_style.bg_color = get_theme_color("highlight_color", "Editor")
	_highlight_inactive_style.bg_color = Color(0, 0, 0, 0)


# Properties.

func set_font_name(value: String) -> void:
	if font_name == value:
		return

	font_name = value
	_update_sample_font()
	_update_labels()


func set_font_resource(value: Font) -> void:
	if font_resource == value:
		return

	font_resource = value
	_update_sample_font()


func set_sample_text(value: String) -> void:
	var clean_value := "Sample Text" if value.is_empty() else value
	if sample_text == clean_value:
		return

	sample_text = clean_value
	_update_labels()


func set_selected(value: bool) -> void:
	if selected == value:
		return

	selected = value
	_update_background()


# Helpers.

func _update_labels() -> void:
	if not is_node_ready():
		return

	_font_title.text = font_name
	_font_sample.text = sample_text


func _update_sample_font() -> void:
	if not is_node_ready() || font_name.is_empty() || not font_resource:
		return

	_font_sample.add_theme_font_override("font", font_resource)
	custom_minimum_size.y = 40.0 + font_resource.get_height()


func _update_background() -> void:
	if not Engine.is_editor_hint() || not is_node_ready() || (is_inside_tree() && get_tree().edited_scene_root == self):
		return

	if selected:
		_highlight_panel.add_theme_stylebox_override("panel", _highlight_active_style)
	else:
		_highlight_panel.add_theme_stylebox_override("panel", _highlight_inactive_style)
