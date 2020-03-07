tool
extends EditorPlugin

var plugin_name : String = "Editor Theme Explorer"
var dialog_instance : Control

func get_plugin_name() -> String:
	return plugin_name

func _enter_tree():
	dialog_instance = preload("res://addons/explore-editor-theme/ExplorerDialog.tscn").instance()
	get_editor_interface().get_base_control().add_child(dialog_instance)
	
	var godot_theme = get_editor_interface().get_base_control().theme
	dialog_instance.editor_theme = godot_theme
	
	add_tool_menu_item(get_plugin_name(), self, "_show_window")

func _exit_tree():
	remove_tool_menu_item(get_plugin_name())
	dialog_instance.queue_free()

func _show_window(param : Object) -> void:
	dialog_instance.popup_centered()

### Functions of Theme:
#
#	Color get_color(name: String, type: String) const
#	PoolStringArray get_color_list(type: String) const
#
#	int get_constant(name: String, type: String) const
#	PoolStringArray get_constant_list(type: String) const
#
#	Font get_font(name: String, type: String) const
#	PoolStringArray get_font_list(type: String) const
#
#	Texture get_icon(name: String, type: String) const
#	PoolStringArray get_icon_list(type: String) const
#
#	StyleBox get_stylebox(name: String, type: String) const
#	PoolStringArray get_stylebox_list(type: String) const
#
#	PoolStringArray get_stylebox_types() const
#	PoolStringArray get_type_list(type: String) const
