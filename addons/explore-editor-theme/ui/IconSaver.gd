tool
extends VBoxContainer


signal filesystem_changed()

export var icon_name := ''
export var type_name := ''

onready var _save_dialog: FileDialog = $SaveDialog
onready var _message: Label = $Message


func clear_message() -> void:
	_message.text = ''


func show_save_dialog() -> void:
	_save_dialog.popup_centered()


func save_file(path: String) -> void:
	
	if not has_icon(icon_name, type_name):
		_message.text = "Can't load icon. Is a valid icon selected?"
		return
	
	var unique_icon := get_icon(icon_name, type_name).duplicate(true)
	if ResourceSaver.save(path, unique_icon) != OK:
		_message.text = "Error while saving icon."
		return
	
	_message.text = "Successfully saved as '%s'." % path
	emit_signal("filesystem_changed")
