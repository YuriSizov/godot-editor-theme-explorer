tool
extends WindowDialog

# Node references
onready var icon_explorer : Control = $VBoxContainer/TabContainer/Icons
onready var color_explorer : Control = $VBoxContainer/TabContainer/Colors
onready var font_explorer : Control = $VBoxContainer/TabContainer/Fonts
onready var styleboxes_explorer : Control = $VBoxContainer/TabContainer/Styleboxes
onready var constant_explorer : Control = $VBoxContainer/TabContainer/Constants

var editor_theme : Theme setget set_editor_theme

func set_editor_theme(value : Theme) -> void:
	editor_theme = value
	
	var theme_types = Array(editor_theme.get_type_list(""))
	theme_types.sort()
	
	for type in theme_types:
		icon_explorer.add_icon_set(editor_theme.get_icon_list(type), type)
		color_explorer.add_color_set(editor_theme.get_color_list(type), type)
		font_explorer.add_font_set(editor_theme.get_font_list(type), type)
		styleboxes_explorer.add_stylebox_set(editor_theme.get_stylebox_list(type), type)
		constant_explorer.add_constant_set(editor_theme.get_constant_list(type), type)
