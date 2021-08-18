@tool
extends VBoxContainer

# Node references
@onready var code_input : CodeEdit = $CodeText
@onready var copy_code_button : Button = $CopyCodeButton

# Public variables
var code_text : String = "":
	set = set_code_text

func _ready() -> void:
	# TODO: Make sure the GDScript syntax is actually highlighted
	code_input.syntax_highlighter = EditorSyntaxHighlighter.new()
	# FIXME: Replace with pressed when it is renamed and no longer conflicts with a property
	copy_code_button.button_up.connect(self._on_copy_button_pressed)

# Properties
func set_code_text(value : String) -> void:
	code_input.text = value
	copy_code_button.icon = null

# Handlers
func _on_copy_button_pressed() -> void:
	var copied_text = code_input.text.strip_edges()
	if (copied_text.is_empty()):
		return

	# TODO: Make sure this is the proper new method; docs are empty at the moment
	DisplayServer.clipboard_set(copied_text)
	copy_code_button.icon = get_theme_icon("StatusSuccess", "EditorIcons")
