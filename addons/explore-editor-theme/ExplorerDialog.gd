@tool
extends Window

signal filesystem_changed()

# Public properties
var editor_plugin : EditorPlugin
var editor_theme : Theme:
	set = set_editor_theme

# Utils
const _PluginUtils := preload("res://addons/explore-editor-theme/utils/PluginUtils.gd")

# Node references
@onready var background_panel : ColorRect = $Panel

@onready var icon_explorer : Control = $Layout/TabContainer/Icons
@onready var color_explorer : Control = $Layout/TabContainer/Colors
@onready var font_explorer : Control = $Layout/TabContainer/Fonts
@onready var styleboxes_explorer : Control = $Layout/TabContainer/Styleboxes
@onready var constant_explorer : Control = $Layout/TabContainer/Constants

func _ready() -> void:
	_update_theme()

	icon_explorer.filesystem_changed.connect(self.emit_signal.bind("filesystem_changed"))

func _notification(what : int) -> void:
	if (what == NOTIFICATION_WM_CLOSE_REQUEST):
		hide()

func _update_theme() -> void:
	if (!_PluginUtils.get_plugin_instance(self)):
		return

	background_panel.color = get_theme_color("dark_color_2", "Editor")

func set_editor_theme(value : Theme) -> void:
	editor_theme = value

	var theme_types = Array(editor_theme.get_type_list())
	theme_types.sort()

	for type in theme_types:
		icon_explorer.add_icon_set(editor_theme.get_icon_list(type), type)
		color_explorer.add_color_set(editor_theme.get_color_list(type), type)
		font_explorer.add_font_set(editor_theme.get_font_list(type), type)
		font_explorer.add_font_size_set(editor_theme.get_font_size_list(type), type)
		styleboxes_explorer.add_stylebox_set(editor_theme.get_stylebox_list(type), type)
		constant_explorer.add_constant_set(editor_theme.get_constant_list(type), type)
