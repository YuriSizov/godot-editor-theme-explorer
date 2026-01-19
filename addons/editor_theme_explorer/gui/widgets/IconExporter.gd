@tool
extends VBoxContainer

var icon_name: String = "":
	set = set_icon_name
var type_name: String = "":
	set = set_type_name

var _success_icon: Texture2D = null
var _failure_icon: Texture2D = null
var _failure_color: Color = Color.WHITE

@onready var _export_button: Button = %ExportButton
@onready var _export_dialog: FileDialog = %ExportDialog
@onready var _status_message: Label = %Message


func _ready() -> void:
	_update_theme()
	_clear_status()

	visibility_changed.connect(_clear_status)
	_export_button.pressed.connect(_export_icon)
	_export_dialog.file_selected.connect(_export_icon_confirmed)


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		_update_theme()


func _update_theme() -> void:
	_success_icon = get_theme_icon("StatusSuccess", "EditorIcons")
	_failure_icon = get_theme_icon("StatusError", "EditorIcons")
	_failure_color = get_theme_color("error_color", "Editor")


# Properties.

func set_icon_name(value: String) -> void:
	if icon_name == value:
		return

	icon_name = value
	_clear_status()


func set_type_name(value: String) -> void:
	if type_name == value:
		return

	type_name = value
	_clear_status()


# Helpers.

func _show_status(success: bool, message: String = "") -> void:
	if not is_node_ready():
		return

	if success:
		_export_button.icon = _success_icon
		_status_message.remove_theme_color_override("font_color")
	else:
		_export_button.icon = _failure_icon
		_status_message.add_theme_color_override("font_color", _failure_color)

	if message.is_empty():
		_status_message.text = ""
		_status_message.visible = false
	else:
		_status_message.text = message
		_status_message.visible = true


func _clear_status() -> void:
	if not is_node_ready():
		return

	_export_button.icon = null
	_status_message.text = ""
	_status_message.visible = false
	_status_message.remove_theme_color_override("font_color")


# Export management.

func _export_icon() -> void:
	if not icon_name.is_empty():
		_export_dialog.current_file = "%s.png" % [ icon_name ]

	_export_dialog.popup_centered()


func _export_icon_confirmed(file_path: String) -> void:
	if not has_theme_icon(icon_name, type_name):
		_show_status(false, "Failed to export icon '%s' from '%s' because it doesn't exist." % [ icon_name, type_name ])
		return

	var unique_icon := get_theme_icon(icon_name, type_name).duplicate(true)
	var error := ResourceSaver.save(unique_icon, file_path)
	if error != OK:
		_show_status(false, "Failed to export icon '%s' from '%s' (code %d)." % [ icon_name, type_name, error ])
		return

	_show_status(true)
	EditorInterface.get_resource_filesystem().scan()
