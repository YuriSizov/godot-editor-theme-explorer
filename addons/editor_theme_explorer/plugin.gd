@tool
extends EditorPlugin

const ExplorerWindow := preload("./gui/ExplorerWindow.gd")
const TOOL_MENU_NAME := "Open Editor Theme Explorer..."

var _explorer_window: ExplorerWindow = null


func _enter_tree():
	add_tool_menu_item(TOOL_MENU_NAME, _show_explorer_window)

	if not is_instance_valid(_explorer_window):
		_explorer_window = ExplorerWindow.new()
		_explorer_window.close_requested.connect(_hide_explorer_window)

	add_child(_explorer_window)


func _exit_tree():
	remove_tool_menu_item(TOOL_MENU_NAME)

	if not is_instance_valid(_explorer_window):
		return

	_explorer_window.close_requested.disconnect(_hide_explorer_window)
	remove_child(_explorer_window)
	_explorer_window.queue_free()
	_explorer_window = null


func _show_explorer_window() -> void:
	if not is_instance_valid(_explorer_window):
		return

	_explorer_window.popup_centered()


func _hide_explorer_window() -> void:
	if not is_instance_valid(_explorer_window):
		return

	_explorer_window.hide()
