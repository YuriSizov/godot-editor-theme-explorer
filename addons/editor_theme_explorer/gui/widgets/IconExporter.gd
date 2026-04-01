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
	if not has_theme_icon(icon_name, type_name):
		_show_status(false, "Failed to export icon '%s' from '%s' because it doesn't exist." % [ icon_name, type_name ])
		return

	var filters := PackedStringArray()
	var default_extension := "png"
	_export_dialog.clear_filters()
	_export_dialog.option_count = 0

	var source_icon := get_theme_icon(icon_name, type_name)
	if ClassDB.is_parent_class(source_icon.get_class(), "DPITexture"):
		default_extension = "svg"
		filters.append("*.svg ; SVG File")
		_export_dialog.add_option("Scale (PNG only)", [ "1x", "2x", "3x", "4x" ], 0)

	filters.append("*.png ; PNG Image") # Always available.
	_export_dialog.filters = filters

	if not icon_name.is_empty():
		_export_dialog.current_file = "%s.%s" % [ icon_name, default_extension ]

	_export_dialog.popup_centered()


func _export_icon_confirmed(file_path: String) -> void:
	var source_icon := get_theme_icon(icon_name, type_name)
	var target_extension := file_path.get_extension()

	# DPITextures are handled differently from rasterized textures due to incompatibilities.
	# They also support exporting as SVG natively.

	if ClassDB.is_parent_class(source_icon.get_class(), "DPITexture"):
		match target_extension:
			"svg":
				var fs := FileAccess.open(file_path, FileAccess.WRITE)
				var error := FileAccess.get_open_error()
				if error != OK:
					_show_status(false, "Failed to open file at '%s' for writing (code %d)." % [ file_path, error ])
					return

				fs.store_string(source_icon.get_source())
				error = fs.get_error()
				if error != OK:
					_show_status(false, "Failed to export icon '%s' from '%s' to '%s' (code %d)." % [ icon_name, type_name, file_path, error ])
					return

			"png":
				var export_options := _export_dialog.get_selected_options()
				var target_scale := int(export_options["Scale (PNG only)"]) + 1
				var target_image := Image.new()
				target_image.load_svg_from_string(source_icon.get_source(), target_scale)

				var target_icon := ImageTexture.create_from_image(target_image)
				var error := ResourceSaver.save(target_icon, file_path)
				if error != OK:
					_show_status(false, "Failed to export icon '%s' from '%s' to '%s' (code %d)." % [ icon_name, type_name, file_path, error ])
					return

			_:
				_show_status(false, "Failed to export icon '%s' from '%s', unknown extension '%s'." % [ icon_name, type_name, target_extension ])
				return

	else:
		match target_extension:
			"png":
				var target_icon := source_icon.duplicate(true) # Avoid taking over a path.
				var error := ResourceSaver.save(target_icon, file_path)
				if error != OK:
					_show_status(false, "Failed to export icon '%s' from '%s' to '%s' (code %d)." % [ icon_name, type_name, file_path, error ])
					return

			_:
				_show_status(false, "Failed to export icon '%s' from '%s', unknown extension '%s'." % [ icon_name, type_name, target_extension ])
				return

	_show_status(true)
	EditorInterface.get_resource_filesystem().scan.call_deferred()
