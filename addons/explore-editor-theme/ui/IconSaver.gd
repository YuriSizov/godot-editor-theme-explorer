tool
extends VBoxContainer


signal filesystem_changed()

export var icon_name: String = ""
export var type_name: String = ""

onready var save_button: Button = $SaveButton
onready var save_dialog: FileDialog = $SaveDialog
onready var message: Label = $Message


func _ready() -> void:
	connect("visibility_changed", self, "_on_visibility_changed")
	save_button.connect("pressed", self, "_on_save_button_pressed")
	save_dialog.connect("file_selected", self, "_on_file_selected")


func _on_visibility_changed() -> void:
	message.text = ""


func _on_save_button_pressed() -> void:
	save_dialog.popup_centered()


func _on_file_selected(path: String) -> void:
	
	if not has_icon(icon_name, type_name):
		message.text = "Can't load icon. Is a valid icon selected?"
		return
	
	var unique_icon := get_icon(icon_name, type_name).duplicate(true)
	if ResourceSaver.save(path, unique_icon) != OK:
		message.text = "Error while saving icon."
		return
	
	message.text = "Successfully saved as '%s'." % path
	emit_signal("filesystem_changed")
