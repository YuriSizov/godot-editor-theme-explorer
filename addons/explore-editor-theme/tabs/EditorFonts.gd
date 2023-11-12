@tool
extends MarginContainer

# Private properties
var _font_map : Dictionary = {}
var _default_style_type_name : String = "EditorFonts"
var _font_size_map : Dictionary = {}
var _default_size_type_name : String = "EditorFonts"

# Utils
const _PluginUtils := preload("res://addons/explore-editor-theme/utils/PluginUtils.gd")

# Node references
@onready var layout_root : BoxContainer = $Layout
@onready var sample_tool : Control = $Layout/Sample
@onready var font_preview : Label = $Layout/FontPreview

@onready var style_filter_tool : Control = $Layout/StyleToolbar/Filter
@onready var style_type_tool : Control = $Layout/StyleToolbar/Type
@onready var font_style_list : Control = $Layout/FontStyleView/ScrollContainer/FontList

@onready var style_empty_panel : Control = $Layout/FontStyleView/EmptyPanel
@onready var style_font_panel : Control = $Layout/FontStyleView/FontPanel
@onready var style_font_title : Label = $Layout/FontStyleView/FontPanel/FontName
@onready var style_font_code : Control = $Layout/FontStyleView/FontPanel/FontCode
@onready var style_font_inspector : Control = $Layout/FontStyleView/FontPanel/FontInspector

@onready var size_filter_tool : Control = $Layout/SizeToolbar/Filter
@onready var size_type_tool : Control = $Layout/SizeToolbar/Type
@onready var font_size_list : ItemList = $Layout/FontSizeView/FontSizeList

@onready var size_empty_panel : Control = $Layout/FontSizeView/EmptyPanel
@onready var size_font_panel : Control = $Layout/FontSizeView/FontSizePanel
@onready var size_font_title : Label = $Layout/FontSizeView/FontSizePanel/FontSizeName
@onready var size_font_value : Label = $Layout/FontSizeView/FontSizePanel/FontSizeValue
@onready var size_font_code : Control = $Layout/FontSizeView/FontSizePanel/FontSizeCode

# Scene references
var font_item_scene := preload("res://addons/explore-editor-theme/lists/FontListItem.tscn")

func _ready() -> void:
	_update_theme()

	_font_map[_default_style_type_name] = []
	style_type_tool.add_text_item(_default_style_type_name)

	_font_size_map[_default_size_type_name] = []
	size_type_tool.add_text_item(_default_size_type_name)

	style_filter_tool.text_changed.connect(self._on_style_filter_text_changed)
	style_type_tool.item_selected.connect(self._on_style_type_item_selected)
	size_filter_tool.text_changed.connect(self._on_size_filter_text_changed)
	size_type_tool.item_selected.connect(self._on_size_type_item_selected)
	font_size_list.item_selected.connect(self._on_font_size_item_selected)
	sample_tool.text_changed.connect(self._on_sample_text_changed)

func _update_theme() -> void:
	if (!_PluginUtils.get_plugin_instance(self)):
		return

	layout_root.add_theme_constant_override("separation", 8 * EditorInterface.get_editor_scale())
	font_preview.add_theme_color_override("font_color", get_theme_color("accent_color", "Editor"))
	font_preview.add_theme_stylebox_override("normal", get_theme_stylebox("CanvasItemInfoOverlay", "EditorStyles"))
	style_font_title.add_theme_font_override("font", get_theme_font("title", "EditorFonts"))
	size_font_title.add_theme_font_override("font", get_theme_font("title", "EditorFonts"))
	size_font_value.add_theme_font_override("font", get_theme_font("source", "EditorFonts"))
	size_font_value.add_theme_color_override("font_color", get_theme_color("accent_color", "Editor"))

func add_font_set(font_names : PackedStringArray, type_name : String) -> void:
	if (font_names.size() == 0 || type_name.is_empty()):
		return

	if (!_font_map.has(type_name)):
		style_type_tool.add_text_item(type_name)

	var sorted_font_names = Array(font_names)
	sorted_font_names.sort()
	_font_map[type_name] = sorted_font_names

	_refresh_font_style_list()

func add_font_size_set(font_size_names : PackedStringArray, type_name : String) -> void:
	if (font_size_names.size() == 0 || type_name.is_empty()):
		return

	if (!_font_size_map.has(type_name)):
		size_type_tool.add_text_item(type_name)

	var sorted_constant_names = Array(font_size_names)
	sorted_constant_names.sort()
	_font_size_map[type_name] = sorted_constant_names

	_refresh_font_size_list()

func _refresh_font_style_list() -> void:
	var font_list_items = font_style_list.get_children()
	for font_item in font_list_items:
		font_style_list.remove_child(font_item)
		font_item.item_selected.disconnect(self._on_font_style_item_selected)
		font_item.queue_free()

	var prefix = style_filter_tool.filter_text
	var type_name = style_type_tool.get_selected_text()
	var sample = sample_tool.sample_text
	for font in _font_map[type_name]:
		if (!prefix.is_empty() && font.findn(prefix) < 0):
			continue

		var font_item = font_item_scene.instantiate()
		font_item.font_name = font
		font_item.type_name = type_name
		font_item.sample_text = sample
		font_style_list.add_child(font_item)
		font_item.item_selected.connect(self._on_font_style_item_selected.bind(font_item))

func _refresh_font_size_list() -> void:
	font_size_list.clear()

	var prefix = size_filter_tool.filter_text
	var type_name = size_type_tool.get_selected_text()
	for font_size in _font_size_map[type_name]:
		if (!prefix.is_empty() && font_size.findn(prefix) < 0):
			continue

		font_size_list.add_item(font_size)

# Events
func _on_style_filter_text_changed(value : String) -> void:
	_refresh_font_style_list()

func _on_style_type_item_selected(value : int) -> void:
	_refresh_font_style_list()

func _on_font_style_item_selected(font_item : Control) -> void:
	var font_name = font_item.font_name
	var type_name = style_type_tool.get_selected_text()

	font_preview.add_theme_font_override("font", get_theme_font(font_name, type_name))
	style_font_title.text = font_name
	style_font_code.code_text = "get_theme_font(\"" + font_name + "\", \"" + type_name + "\")"
	style_font_inspector.inspected_resource = get_theme_font(font_name, type_name)

	if (!style_font_panel.visible):
		style_empty_panel.hide()
		style_font_panel.show()

func _on_size_filter_text_changed(value : String) -> void:
	_refresh_font_size_list()

func _on_size_type_item_selected(value : int) -> void:
	_refresh_font_size_list()

func _on_font_size_item_selected(item_index : int) -> void:
	var font_size_name = font_size_list.get_item_text(item_index)
	var type_name = size_type_tool.get_selected_text()

	font_preview.add_theme_font_size_override("font_size", get_theme_font_size(font_size_name, type_name))
	size_font_title.text = font_size_name
	var raw_value = get_theme_font_size(font_size_name, type_name)
	size_font_value.text = str(raw_value)
	size_font_code.code_text = "get_theme_font_size(\"" + font_size_name + "\", \"" + type_name + "\")"

	if (!size_font_panel.visible):
		size_empty_panel.hide()
		size_font_panel.show()

func _on_sample_text_changed(value : String) -> void:
	font_preview.text = "Sample Text" if value.is_empty() else value

	var font_list_items = font_style_list.get_children()
	for font_item in font_list_items:
		font_item.sample_text = value
