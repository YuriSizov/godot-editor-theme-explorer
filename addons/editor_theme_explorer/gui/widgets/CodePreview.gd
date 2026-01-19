@tool
extends VBoxContainer

var code_text: String = "":
	set = set_code_text

var _success_icon: Texture2D = null

@onready var _code_edit: CodeEdit = %CodeEdit
@onready var _copy_button: Button = %CopyButton


func _ready() -> void:
	_update_theme()
	_update_controls()

	_copy_button.pressed.connect(_copy_code_to_clipboard)


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		_update_theme()


func _update_theme() -> void:
	_success_icon = get_theme_icon("StatusSuccess", "EditorIcons")


# Properties.

func set_code_text(value: String) -> void:
	if code_text == value:
		return

	code_text =  value
	_update_controls()


# Helpers.

func _update_controls() -> void:
	if not is_node_ready():
		return

	_code_edit.text = code_text
	_copy_button.icon = null


# Interactions.

func _copy_code_to_clipboard() -> void:
	var copied_text = _code_edit.text.strip_edges()
	if copied_text.is_empty():
		return

	DisplayServer.clipboard_set(copied_text)
	_copy_button.icon = _success_icon
