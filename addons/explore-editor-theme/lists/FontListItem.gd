tool
extends Panel

# Node references
onready var font_title : Label = $Layout/FontName
onready var font_sample : Label = $Layout/FontSample

var font_name : String = "" setget set_font_name
var type_name : String = "" setget set_type_name
var sample_text : String = "Sample Text" setget set_sample_text

signal item_selected()

func _ready() -> void:
	font_title.text = font_name
	font_sample.text = sample_text
	_update_sample_font()

func _gui_input(event : InputEvent) -> void:
	if (event is InputEventMouseButton && event.button_index == BUTTON_LEFT && !event.is_pressed() && !event.is_echo()):
		emit_signal("item_selected")

func set_font_name(value : String) -> void:
	font_name = value
	_update_sample_font()
	
	if (is_inside_tree()):
		font_title.text = font_name

func set_type_name(value : String) -> void:
	type_name = value
	_update_sample_font()

func set_sample_text(value : String) -> void:
	sample_text = "Sample Text" if value.empty() else value
	
	if (is_inside_tree()):
		font_sample.text = sample_text

func _update_sample_font() -> void:
	if (font_name.empty() || type_name.empty() || !is_inside_tree()):
		return
	
	var sample_font = get_font(font_name, type_name)
	font_sample.add_font_override("font", sample_font)
	font_sample.add_color_override("font_color", get_color("accent_color", "Editor"))
	
	rect_min_size.y = 40.0 + sample_font.get_height()
