tool
extends Panel

# Node references
onready var stylebox_title : Label = $Layout/StyleboxName
onready var stylebox_preview : Panel = $Layout/PreviewContainer/PreviewPanel

var stylebox_name : String = "" setget set_stylebox_name
var type_name : String = "" setget set_type_name

signal item_selected()

func _ready() -> void:
	stylebox_title.text = stylebox_name
	_update_preview()

func _gui_input(event : InputEvent) -> void:
	if (event is InputEventMouseButton && event.button_index == BUTTON_LEFT && !event.is_pressed() && !event.is_echo()):
		emit_signal("item_selected")

func set_stylebox_name(value : String) -> void:
	stylebox_name = value
	_update_preview()
	
	if (is_inside_tree()):
		stylebox_title.text = stylebox_name

func set_type_name(value : String) -> void:
	type_name = value
	_update_preview()

func _update_preview() -> void:
	if (stylebox_name.empty() || type_name.empty() || !is_inside_tree()):
		return
	
	var stylebox = get_stylebox(stylebox_name, type_name)
	stylebox_preview.add_stylebox_override("panel", stylebox)
