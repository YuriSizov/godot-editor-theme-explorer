@tool
extends MarginContainer

# Public properties
@export var color_icon_background : Texture

# Private properties
var _color_map : Dictionary = {}
var _default_type_name : String = "Editor"

# Utils
const _PluginUtils := preload("res://addons/explore-editor-theme/utils/PluginUtils.gd")

# Node references
@onready var layout_root : BoxContainer = $Layout
@onready var filter_tool : Control = $Layout/Toolbar/Filter
@onready var type_tool : Control = $Layout/Toolbar/Type
@onready var color_list : ItemList = $Layout/ColorView/ColorList

@onready var empty_panel : Control = $Layout/ColorView/EmptyPanel
@onready var color_panel : Control = $Layout/ColorView/ColorPanel
@onready var color_preview : TextureRect = $Layout/ColorView/ColorPanel/ColorPreview
@onready var color_preview_info : Label = $Layout/ColorView/ColorPanel/ColorPreview/ColorPreviewInfo
@onready var color_preview_info2 : Label = $Layout/ColorView/ColorPanel/ColorPreview/ColorPreviewInfo2
@onready var color_title : Label = $Layout/ColorView/ColorPanel/ColorName
@onready var color_code : Control = $Layout/ColorView/ColorPanel/ColorCode

func _ready() -> void:
	_update_theme()

	_color_map[_default_type_name] = []
	type_tool.add_text_item(_default_type_name)

	filter_tool.text_changed.connect(self._on_filter_text_changed)
	type_tool.item_selected.connect(self._on_type_item_selected)
	color_list.item_selected.connect(self._on_color_item_selected)

func _update_theme() -> void:
	if (!_PluginUtils.get_plugin_instance(self)):
		return

	layout_root.add_theme_constant_override("separation", 8 * EditorInterface.get_editor_scale())
	color_preview_info.add_theme_color_override("font_color", get_theme_color("contrast_color_2", "Editor"))
	color_preview_info2.add_theme_color_override("font_color", get_theme_color("contrast_color_2", "Editor"))
	color_title.add_theme_font_override("font", get_theme_font("title", "EditorFonts"))

func add_color_set(color_names : PackedStringArray, type_name : String) -> void:
	if (color_names.size() == 0 || type_name.is_empty()):
		return

	if (!_color_map.has(type_name)):
		type_tool.add_text_item(type_name)

	var sorted_color_names = Array(color_names)
	sorted_color_names.sort()
	_color_map[type_name] = sorted_color_names

	_refresh_color_list()

func _refresh_color_list() -> void:
	color_list.clear()

	var prefix = filter_tool.filter_text
	var type_name = type_tool.get_selected_text()
	var item_index = 0
	for color in _color_map[type_name]:
		if (!prefix.is_empty() && color.findn(prefix) < 0):
			continue

		color_list.add_item(color, color_icon_background)
		color_list.set_item_icon_modulate(item_index, get_theme_color(color, type_name))
		item_index += 1

# Events
func _on_filter_text_changed(value : String) -> void:
	_refresh_color_list()

func _on_type_item_selected(value : int) -> void:
	_refresh_color_list()

func _on_color_item_selected(item_index : int) -> void:
	var color_texture = color_list.get_item_icon(item_index)
	var color_modulate = color_list.get_item_icon_modulate(item_index)
	var color_name = color_list.get_item_text(item_index)
	var type_name = type_tool.get_selected_text()

	color_preview.texture = color_texture
	color_preview.self_modulate = color_modulate
	color_preview_info.text  = "R: %.5f\n" % [ color_modulate.r ]
	color_preview_info.text += "G: %.5f\n" % [ color_modulate.g ]
	color_preview_info.text += "B: %.5f\n" % [ color_modulate.b ]
	color_preview_info.text += "A: %.5f"   % [ color_modulate.a ]
	color_preview_info2.text = "# %s\n" % [ color_modulate.to_html(!is_equal_approx(color_modulate.a, 1.0)) ]
	color_title.text = color_name
	color_code.code_text = "get_theme_color(\"" + color_name + "\", \"" + type_name + "\")"

	if (!color_panel.visible):
		empty_panel.hide()
		color_panel.show()
