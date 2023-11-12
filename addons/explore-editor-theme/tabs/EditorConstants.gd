@tool
extends MarginContainer

# Private properties
var _constant_map : Dictionary = {}
var _default_type_name : String = "Editor"

# Utils
const _PluginUtils := preload("res://addons/explore-editor-theme/utils/PluginUtils.gd")

# Node references
@onready var layout_root : BoxContainer = $Layout
@onready var filter_tool : Control = $Layout/Toolbar/Filter
@onready var type_tool : Control = $Layout/Toolbar/Type
@onready var constant_list : ItemList = $Layout/ConstantView/ConstantList

@onready var empty_panel : Control = $Layout/ConstantView/EmptyPanel
@onready var constant_panel : Control = $Layout/ConstantView/ConstantPanel
@onready var constant_title : Label = $Layout/ConstantView/ConstantPanel/ConstantName
@onready var constant_value : Label = $Layout/ConstantView/ConstantPanel/ConstantValue
@onready var constant_code : Control = $Layout/ConstantView/ConstantPanel/ConstantCode

func _ready() -> void:
	_update_theme()

	_constant_map[_default_type_name] = []
	type_tool.add_text_item(_default_type_name)

	filter_tool.text_changed.connect(self._on_filter_text_changed)
	type_tool.item_selected.connect(self._on_type_item_selected)
	constant_list.item_selected.connect(self._on_constant_item_selected)

func _update_theme() -> void:
	if (!_PluginUtils.get_plugin_instance(self)):
		return

	layout_root.add_theme_constant_override("separation", 8 * EditorInterface.get_editor_scale())
	constant_title.add_theme_font_override("font", get_theme_font("title", "EditorFonts"))
	constant_value.add_theme_font_override("font", get_theme_font("source", "EditorFonts"))
	constant_value.add_theme_color_override("font_color", get_theme_color("accent_color", "Editor"))

func add_constant_set(constant_names : PackedStringArray, type_name : String) -> void:
	if (constant_names.size() == 0 || type_name.is_empty()):
		return

	if (!_constant_map.has(type_name)):
		type_tool.add_text_item(type_name)

	var sorted_constant_names = Array(constant_names)
	sorted_constant_names.sort()
	_constant_map[type_name] = sorted_constant_names

	_refresh_constant_list()

func _refresh_constant_list() -> void:
	constant_list.clear()

	var prefix = filter_tool.filter_text
	var type_name = type_tool.get_selected_text()
	for constant in _constant_map[type_name]:
		if (!prefix.is_empty() && constant.findn(prefix) < 0):
			continue

		constant_list.add_item(constant)

# Events
func _on_filter_text_changed(value : String) -> void:
	_refresh_constant_list()

func _on_type_item_selected(value : int) -> void:
	_refresh_constant_list()

func _on_constant_item_selected(item_index : int) -> void:
	var constant_name = constant_list.get_item_text(item_index)
	var type_name = type_tool.get_selected_text()

	constant_title.text = constant_name
	var raw_value = get_theme_constant(constant_name, type_name)
	constant_value.text = str(raw_value) + " (" + str(bool(raw_value)) + ")"
	constant_code.code_text = "get_theme_constant(\"" + constant_name + "\", \"" + type_name + "\")"

	if (!constant_panel.visible):
		empty_panel.hide()
		constant_panel.show()
