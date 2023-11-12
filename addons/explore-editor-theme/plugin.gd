@tool
extends EditorPlugin

var plugin_name : String = "Editor Theme Explorer"
var dialog_instance : Window

func get_plugin_name() -> String:
	return plugin_name

func _enter_tree():
	dialog_instance = preload("res://addons/explore-editor-theme/ExplorerDialog.tscn").instantiate()
	dialog_instance.editor_plugin = self
	EditorInterface.get_base_control().add_child(dialog_instance)

	dialog_instance.editor_theme = EditorInterface.get_editor_theme()
	dialog_instance.filesystem_changed.connect(self._rescan_filesystem)

	add_tool_menu_item(get_plugin_name(), self._show_window)

func _exit_tree():
	remove_tool_menu_item(get_plugin_name())
	dialog_instance.queue_free()

func _show_window() -> void:
	dialog_instance.popup_centered()

func _rescan_filesystem() -> void:
	EditorInterface.get_resource_filesystem().scan()
