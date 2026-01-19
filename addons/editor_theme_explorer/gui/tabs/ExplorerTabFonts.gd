@tool
extends "./ExplorerTab.gd"

const TextFilter := preload("../widgets/TextFilter.gd")
const TypeSelector := preload("../widgets/TypeSelector.gd")
const CodePreview := preload("../widgets/CodePreview.gd")
const ResourceInspector := preload("../widgets/ResourceInspector.gd")

const FontList := preload("../lists/FontList.gd")
const TextSamplePreview := preload("../widgets/TextSamplePreview.gd")

var _font_style_item_map: Dictionary = {} # String, PackedStringArray
var _font_size_item_map: Dictionary = {} # String, PackedStringArray

@onready var _layout_root: BoxContainer = %Layout
@onready var _sample_preview: TextSamplePreview = %SamplePreview

@onready var _style_text_filter_widget: TextFilter = %StyleTextFilter
@onready var _style_type_selector_widget: TypeSelector = %StyleTypeSelector
@onready var _font_style_list: FontList = %FontList
@onready var _font_style_details: Control = %FontStyleDetails

@onready var _font_style_title: Label = %FontName
@onready var _font_style_code: CodePreview = %FontCode
@onready var _font_style_inspector: ResourceInspector = %FontInspector

@onready var _size_text_filter_widget: TextFilter = %SizeTextFilter
@onready var _size_type_selector_widget: TypeSelector = %SizeTypeSelector
@onready var _font_size_list: ItemList = %FontSizeList
@onready var _font_size_details: Control = %FontSizeDetails

@onready var _font_size_title: Label = %FontSizeName
@onready var _font_size_value: Label = %FontSizeValue
@onready var _font_size_code: CodePreview = %FontSizeCode


func _ready() -> void:
	_update_theme()

	_add_font_style_items("EditorFonts", [])
	_filter_font_style_list()
	_deselect_font_style_item()

	_add_font_size_items("EditorFonts", [])
	_filter_font_size_list()
	_deselect_font_size_item()

	_style_text_filter_widget.value_changed.connect(_filter_font_style_list.unbind(1))
	_style_type_selector_widget.value_changed.connect(_filter_font_style_list.unbind(1))
	_size_text_filter_widget.value_changed.connect(_filter_font_size_list.unbind(1))
	_size_type_selector_widget.value_changed.connect(_filter_font_size_list.unbind(1))
	_font_style_list.item_selected.connect(_select_font_style_item)
	_font_size_list.item_selected.connect(_select_font_size_item)

	_sample_preview.value_changed.connect(_font_style_list.set_sample_text)


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		_update_theme()


func _update_theme() -> void:
	if not Engine.is_editor_hint() || not is_node_ready() || get_tree().edited_scene_root == self:
		return

	_layout_root.add_theme_constant_override("separation", 8 * EditorInterface.get_editor_scale())
	_font_style_title.add_theme_font_override("font", get_theme_font("title", "EditorFonts"))
	_font_size_title.add_theme_font_override("font", get_theme_font("title", "EditorFonts"))
	_font_size_value.add_theme_font_override("font", get_theme_font("source", "EditorFonts"))
	_font_size_value.add_theme_color_override("font_color", get_theme_color("accent_color", "Editor"))


# Tab implementation.

# Override.
func set_explored_theme(theme: Theme) -> void:
	super(theme)
	_style_type_selector_widget.clear_options(true)
	_font_style_item_map.clear()
	_size_type_selector_widget.clear_options(true)
	_font_size_item_map.clear()

	if not _explored_theme:
		return

	var font_types := _explored_theme.get_font_type_list()
	font_types.sort()

	for type in font_types:
		_add_font_style_items(type, _explored_theme.get_font_list(type))

	_style_type_selector_widget.restore_selected_value()
	_filter_font_style_list()

	var font_size_types := _explored_theme.get_font_size_type_list()
	font_size_types.sort()

	for type in font_size_types:
		_add_font_size_items(type, _explored_theme.get_font_size_list(type))

	_size_type_selector_widget.restore_selected_value()
	_filter_font_size_list()


# Style list management.

func _add_font_style_items(type_name: String, font_names: PackedStringArray) -> void:
	_style_type_selector_widget.add_option(type_name)

	var sorted_names = Array(font_names)
	sorted_names.sort()
	_font_style_item_map[type_name] = sorted_names


func _filter_font_style_list() -> void:
	_font_style_list.clear()

	var name_filter := _style_text_filter_widget.get_filter_value()
	var type_name := _style_type_selector_widget.get_selected_text()

	if not _font_style_item_map.has(type_name):
		return

	for font_name: String in _font_style_item_map[type_name]:
		if not name_filter.is_empty() && font_name.findn(name_filter) < 0:
			continue

		_font_style_list.add_item(font_name, _explored_theme.get_font(font_name, type_name))

	_font_style_list.set_sample_text(_sample_preview.get_sample_text())


func _deselect_font_style_item() -> void:
	_font_style_details.visible = false
	_sample_preview.font_style = null

	_font_style_title.text = ""
	_font_style_code.code_text = ""
	_font_style_inspector.target_resource = null


func _select_font_style_item(item_index: int) -> void:
	var type_name := _style_type_selector_widget.get_selected_text()
	var font_name := _font_style_list.get_item_name(item_index)
	var font_resource := _font_style_list.get_item_font(item_index)

	_font_style_details.visible = true
	_sample_preview.font_style = font_resource

	_font_style_title.text = font_name
	_font_style_code.code_text = "get_theme_font(\"%s\", \"%s\")" % [ font_name, type_name ]
	_font_style_inspector.target_resource = font_resource


# Size list management.

func _add_font_size_items(type_name: String, font_size_names: PackedStringArray) -> void:
	_size_type_selector_widget.add_option(type_name)

	var sorted_names = Array(font_size_names)
	sorted_names.sort()
	_font_size_item_map[type_name] = sorted_names


func _filter_font_size_list() -> void:
	_font_size_list.clear()

	var name_filter := _size_text_filter_widget.get_filter_value()
	var type_name := _size_type_selector_widget.get_selected_text()

	if not _font_size_item_map.has(type_name):
		return

	for font_size_name: String in _font_size_item_map[type_name]:
		if not name_filter.is_empty() && font_size_name.findn(name_filter) < 0:
			continue

		_font_size_list.add_item(font_size_name)


func _deselect_font_size_item() -> void:
	_font_size_details.visible = false
	_sample_preview.font_size = 0

	_font_size_title.text = ""
	_font_size_value.text = ""
	_font_size_code.code_text = ""


func _select_font_size_item(item_index: int) -> void:
	var type_name := _size_type_selector_widget.get_selected_text()
	var font_size_name := _font_size_list.get_item_text(item_index)
	var font_size_raw := _explored_theme.get_font_size(font_size_name, type_name)

	_font_size_details.visible = true
	_sample_preview.font_size = font_size_raw

	_font_size_title.text = font_size_name
	_font_size_value.text = "%d" % [ font_size_raw ]
	_font_size_code.code_text = "get_theme_font_size(\"%s\", \"%s\")" % [ font_size_name, type_name ]
