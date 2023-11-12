@tool
extends PanelContainer

# Utils
const _PluginUtils := preload("res://addons/explore-editor-theme/utils/PluginUtils.gd")

# Node references
@onready var font_title : Label = $Layout/FontName
@onready var font_sample : Label = $Layout/FontSample
@onready var background_panel : Panel = $BackgroundPanel

# Public properties
var font_name : String = "":
	set = set_font_name
var type_name : String = "":
	set = set_type_name
var sample_text : String = "Sample Text":
	set = set_sample_text
var selected : bool = false:
	set = set_selected

signal item_selected()

func _ready() -> void:
	_update_theme()
	
	font_title.text = font_name
	font_sample.text = sample_text

	_update_sample_font()
	_update_background()

func _gui_input(event : InputEvent) -> void:
	if (event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && !event.is_pressed() && !event.is_echo()):
		set_selected(true)
		item_selected.emit()

func _update_theme() -> void:
	if (!_PluginUtils.get_plugin_instance(self)):
		return
	
	var panel_style := get_theme_stylebox("panel", "Panel").duplicate()
	panel_style.set_content_margin_all(0)
	add_theme_stylebox_override("panel", panel_style)

# Properties
func set_font_name(value : String) -> void:
	font_name = value
	_update_sample_font()

	if (is_inside_tree()):
		font_title.text = font_name

func set_type_name(value : String) -> void:
	type_name = value
	_update_sample_font()

func set_sample_text(value : String) -> void:
	sample_text = "Sample Text" if value.is_empty() else value

	if (is_inside_tree()):
		font_sample.text = sample_text

func set_selected(value : bool) -> void:
	if (selected == value):
		return
	selected = value

	_update_background()

	if (selected):
		var items = get_tree().get_nodes_in_group("ETE_FontItems")
		for item in items:
			if (item == self):
				continue

			item.selected = false

# Helpers
func _update_sample_font() -> void:
	if (font_name.is_empty() || type_name.is_empty() || !_PluginUtils.get_plugin_instance(self)):
		return

	var sample_font = get_theme_font(font_name, type_name)
	font_sample.add_theme_font_override("font", sample_font)
	font_sample.add_theme_color_override("font_color", get_theme_color("accent_color", "Editor"))

	custom_minimum_size.y = 40.0 + sample_font.get_height()

func _update_background() -> void:
	if (!_PluginUtils.get_plugin_instance(self)):
		return

	var label_stylebox = get_theme_stylebox("panel", "Panel").duplicate() as StyleBoxFlat
	if (selected):
		label_stylebox.bg_color = get_theme_color("highlight_color", "Editor")
	else:
		label_stylebox.bg_color = Color(0, 0, 0, 0)
	background_panel.add_theme_stylebox_override("panel", label_stylebox)
