@tool
extends "./ExplorerTab.gd"

const TextFilter := preload("../widgets/TextFilter.gd")
const TypeSelector := preload("../widgets/TypeSelector.gd")
const CodePreview := preload("../widgets/CodePreview.gd")
const IconExporter := preload("../widgets/IconExporter.gd")

var _icon_item_map: Dictionary = {} # String, PackedStringArray

@onready var _layout_root: BoxContainer = %Layout
@onready var _text_filter_widget: TextFilter = %TextFilter
@onready var _type_selector_widget: TypeSelector = %TypeSelector

@onready var _icon_list: ItemList = %IconList
@onready var _icon_details: Control = %IconDetails

@onready var _icon_preview: TextureRect = %IconPreview
@onready var _icon_preview_info: Label = %IconPreviewInfo
@onready var _icon_title: Label = %IconName
@onready var _icon_code: CodePreview = %IconCode
@onready var _icon_exporter: IconExporter = %IconExporter


func _ready() -> void:
	_update_theme()

	_add_icon_items("EditorIcons", [])
	_filter_icon_list()
	_deselect_icon_item()

	_text_filter_widget.value_changed.connect(_filter_icon_list.unbind(1))
	_type_selector_widget.value_changed.connect(_filter_icon_list.unbind(1))
	_icon_list.item_selected.connect(_select_icon_item)


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		_update_theme()


func _update_theme() -> void:
	if not Engine.is_editor_hint() || not is_node_ready() || get_tree().edited_scene_root == self:
		return

	_layout_root.add_theme_constant_override("separation", 8 * EditorInterface.get_editor_scale())
	_icon_preview_info.add_theme_color_override("font_color", get_theme_color("contrast_color_2", "Editor"))
	_icon_title.add_theme_font_override("font", get_theme_font("title", "EditorFonts"))


# Tab implementation.

# Override.
func set_explored_theme(theme: Theme) -> void:
	super(theme)
	_type_selector_widget.clear_options(true)
	_icon_item_map.clear()

	if not _explored_theme:
		return

	var icon_types := _explored_theme.get_icon_type_list()
	icon_types.sort()

	for type in icon_types:
		_add_icon_items(type, _explored_theme.get_icon_list(type))

	_type_selector_widget.restore_selected_value()
	_filter_icon_list()


# List management.

func _add_icon_items(type_name: String, icon_names: PackedStringArray) -> void:
	_type_selector_widget.add_option(type_name)

	var sorted_names = Array(icon_names)
	sorted_names.sort()
	_icon_item_map[type_name] = sorted_names


func _filter_icon_list() -> void:
	_icon_list.clear()

	var name_filter := _text_filter_widget.get_filter_value()
	var type_name := _type_selector_widget.get_selected_text()

	if not _icon_item_map.has(type_name):
		return

	for icon_name: String in _icon_item_map[type_name]:
		if not name_filter.is_empty() && icon_name.findn(name_filter) < 0:
			continue

		_icon_list.add_item(icon_name, _explored_theme.get_icon(icon_name, type_name))


func _deselect_icon_item() -> void:
	_icon_details.visible = false
	_icon_preview.texture = null

	_icon_preview_info.text = ""
	_icon_title.text = ""
	_icon_code.code_text = ""

	_icon_exporter.icon_name = ""
	_icon_exporter.type_name = ""


func _select_icon_item(item_index: int) -> void:
	var type_name := _type_selector_widget.get_selected_text()
	var icon_name := _icon_list.get_item_text(item_index)
	var icon_texture := _icon_list.get_item_icon(item_index)

	_icon_details.visible = true
	_icon_preview.texture = icon_texture

	_icon_preview_info.text = "%dx%d" % [ icon_texture.get_width(), icon_texture.get_height() ]
	_icon_title.text = icon_name
	_icon_code.code_text = "get_theme_icon(\"%s\", \"%s\")" % [ icon_name, type_name ]

	_icon_exporter.icon_name = icon_name
	_icon_exporter.type_name = type_name
