@tool
extends MarginContainer

# Public properties
@export var preview_background_texture : Texture

# Private properties
var _stylebox_map : Dictionary = {}
var _default_type_name : String = "EditorStyles"

# Utils
const _PluginUtils := preload("res://addons/explore-editor-theme/utils/PluginUtils.gd")

# Node references
@onready var layout_root : BoxContainer = $Layout
@onready var filter_tool : Control = $Layout/Toolbar/Filter
@onready var type_tool : Control = $Layout/Toolbar/Type
@onready var stylebox_list : Control = $Layout/StyleboxView/ScrollContainer/StyleboxList

@onready var empty_panel : Control = $Layout/StyleboxView/EmptyPanel
@onready var stylebox_panel : Control = $Layout/StyleboxView/StyleboxPanel
@onready var stylebox_preview : Panel = $Layout/StyleboxView/StyleboxPanel/StyleboxPreview/StyleboxPreviewPanel
@onready var preview_background : TextureRect = $Layout/StyleboxView/StyleboxPanel/StyleboxPreview/PreviewBackground
@onready var stylebox_title : Label = $Layout/StyleboxView/StyleboxPanel/StyleboxName
@onready var stylebox_code : Control = $Layout/StyleboxView/StyleboxPanel/StyleboxCode
@onready var stylebox_inspector : Control = $Layout/StyleboxView/StyleboxPanel/StyleboxInspector

# Scene references
var stylebox_item_scene := preload("res://addons/explore-editor-theme/lists/StyleboxListItem.tscn")

func _ready() -> void:
	_update_theme()
	_update_preview_background()

	_stylebox_map[_default_type_name] = []
	type_tool.add_text_item(_default_type_name)

	filter_tool.text_changed.connect(self._on_filter_text_changed)
	type_tool.item_selected.connect(self._on_type_item_selected)

func _update_theme() -> void:
	if (!_PluginUtils.get_plugin_instance(self)):
		return

	layout_root.add_theme_constant_override("separation", 8 * EditorInterface.get_editor_scale())
	stylebox_preview.add_theme_color_override("font_color", get_theme_color("accent_color", "Editor"))
	stylebox_title.add_theme_font_override("font", get_theme_font("title", "EditorFonts"))

func _update_preview_background() -> void:
	if !_PluginUtils.get_plugin_instance(self):
		return

	var bg_image : Image = preview_background_texture.get_image().duplicate()
	bg_image.resize(bg_image.get_width() * 2, bg_image.get_height() * 2, Image.INTERPOLATE_NEAREST)
	preview_background.texture = ImageTexture.create_from_image(bg_image)

func add_stylebox_set(stylebox_names : PackedStringArray, type_name : String) -> void:
	if (stylebox_names.size() == 0 || type_name.is_empty()):
		return

	if (!_stylebox_map.has(type_name)):
		type_tool.add_text_item(type_name)

	var sorted_stylebox_names = Array(stylebox_names)
	sorted_stylebox_names.sort()
	_stylebox_map[type_name] = sorted_stylebox_names

	_refresh_stylebox_list()

func _refresh_stylebox_list() -> void:
	var stylebox_list_rows = stylebox_list.get_children()
	for stylebox_row in stylebox_list_rows:
		stylebox_list.remove_child(stylebox_row)

		var stylebox_list_items = stylebox_row.get_children()
		for stylebox_item in stylebox_list_items:
			stylebox_item.item_selected.disconnect(self._on_stylebox_item_selected)

		stylebox_row.queue_free()

	var prefix = filter_tool.filter_text
	var type_name = type_tool.get_selected_text()
	var item_index = 0
	var horizontal_container = HBoxContainer.new()
	for stylebox in _stylebox_map[type_name]:
		if (!prefix.is_empty() && stylebox.findn(prefix) < 0):
			continue

		var stylebox_item = stylebox_item_scene.instantiate()
		stylebox_item.stylebox_name = stylebox
		stylebox_item.type_name = type_name
		stylebox_item.size_flags_horizontal = SIZE_EXPAND_FILL
		horizontal_container.add_child(stylebox_item)

		stylebox_item.item_selected.connect(self._on_stylebox_item_selected.bind(stylebox_item))
		item_index += 1
		if (item_index % 4 == 0):
			stylebox_list.add_child(horizontal_container)
			horizontal_container = HBoxContainer.new()

	if (horizontal_container.get_child_count() > 0):
		stylebox_list.add_child(horizontal_container)
	else:
		horizontal_container.queue_free()

# Handlers
func _on_filter_text_changed(value : String) -> void:
	_refresh_stylebox_list()

func _on_type_item_selected(value : int) -> void:
	_refresh_stylebox_list()

func _on_stylebox_item_selected(stylebox_item : Control) -> void:
	var stylebox_name = stylebox_item.stylebox_name
	var type_name = type_tool.get_selected_text()

	stylebox_title.text = stylebox_name
	stylebox_preview.add_theme_stylebox_override("panel", get_theme_stylebox(stylebox_name, type_name))
	stylebox_code.code_text = "get_theme_stylebox(\"" + stylebox_name + "\", \"" + type_name + "\")"
	stylebox_inspector.inspected_resource = get_theme_stylebox(stylebox_name, type_name)

	if (!stylebox_panel.visible):
		empty_panel.hide()
		stylebox_panel.show()
