@tool
extends Panel

# Public properties
@export var preview_background_texture : Texture

var stylebox_name : String = "":
	set = set_stylebox_name
var type_name : String = "":
	set = set_type_name
var selected : bool = false:
	set = set_selected

# Utils
const _PluginUtils := preload("res://addons/explore-editor-theme/utils/PluginUtils.gd")

# Node references
@onready var stylebox_title : Label = $Layout/StyleboxName
@onready var stylebox_preview : Panel = $Layout/PreviewContainer/PreviewPanel
@onready var preview_background : TextureRect = $Layout/PreviewContainer/PreviewBackground

signal item_selected()

func _ready() -> void:
	stylebox_title.text = stylebox_name
	hint_tooltip = stylebox_name

	_update_preview_background()
	_update_preview()
	_update_background()

func _gui_input(event : InputEvent) -> void:
	if (event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && !event.is_pressed() && !event.is_echo()):
		set_selected(true)
		item_selected.emit()

# Properties
func set_stylebox_name(value : String) -> void:
	stylebox_name = value
	_update_preview()

	if (is_inside_tree()):
		stylebox_title.text = stylebox_name
		hint_tooltip = stylebox_name

func set_type_name(value : String) -> void:
	type_name = value
	_update_preview()

func set_selected(value : bool) -> void:
	if (selected == value):
		return
	selected = value

	_update_background()

	if (selected):
		var items = get_tree().get_nodes_in_group("ETE_StyleBoxItems")
		for item in items:
			if (item == self):
				continue

			item.selected = false

# Helpers
func _update_preview() -> void:
	if (stylebox_name.is_empty() || type_name.is_empty() || !_PluginUtils.get_plugin_instance(self)):
		return

	var stylebox = get_theme_stylebox(stylebox_name, type_name)
	stylebox_preview.add_theme_stylebox_override("panel", stylebox)

func _update_preview_background() -> void:
	if !_PluginUtils.get_plugin_instance(self):
		return
	
	var bg_image = preview_background_texture.get_image()
	# FIXME: Find out why the method was removed and what's the workaround
	#bg_image.expand_x2_hq2x()
	var bg_texture = ImageTexture.new()
	bg_texture.create_from_image(bg_image)
	preview_background.texture = preview_background_texture

func _update_background() -> void:
	if (!_PluginUtils.get_plugin_instance(self)):
		return

	var label_stylebox = StyleBoxFlat.new()
	if (selected):
		label_stylebox.bg_color = get_theme_color("highlight_color", "Editor")
	else:
		label_stylebox.bg_color = Color(0, 0, 0, 0)
	stylebox_title.add_theme_stylebox_override("normal", label_stylebox)
