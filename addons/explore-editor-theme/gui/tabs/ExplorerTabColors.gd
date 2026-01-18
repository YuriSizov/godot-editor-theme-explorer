@tool
extends "./ExplorerTab.gd"

const TextFilter := preload("../widgets/TextFilter.gd")
const TypeSelector := preload("../widgets/TypeSelector.gd")
const CodePreview := preload("../widgets/CodePreview.gd")

const PREVIEW_BACKGROUND_TEXTURE := preload("../../assets/color-preview-icon.png")

var _color_item_map: Dictionary = {} # String, PackedStringArray

@onready var _layout_root: BoxContainer = %Layout
@onready var _text_filter_widget: TextFilter = %TextFilter
@onready var _type_selector_widget: TypeSelector = %TypeSelector

@onready var _color_list: ItemList = %ColorList
@onready var _color_details: Control = %ColorDetails

@onready var _color_preview: TextureRect = %ColorPreview
@onready var _color_preview_info_1: Label = %ColorPreviewInfo1
@onready var _color_preview_info_2: Label = %ColorPreviewInfo2
@onready var _color_title: Label = %ColorName
@onready var _color_code: CodePreview = %ColorCode


func _ready() -> void:
	_update_theme()

	_add_color_items("Editor", [])
	_filter_color_list()
	_deselect_color_item()

	_text_filter_widget.value_changed.connect(_filter_color_list.unbind(1))
	_type_selector_widget.value_changed.connect(_filter_color_list.unbind(1))
	_color_list.item_selected.connect(_select_color_item)


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		_update_theme()


func _update_theme() -> void:
	if not Engine.is_editor_hint() || not is_node_ready() || get_tree().edited_scene_root == self:
		return

	_layout_root.add_theme_constant_override("separation", 8 * EditorInterface.get_editor_scale())
	_color_preview_info_1.add_theme_color_override("font_color", get_theme_color("contrast_color_2", "Editor"))
	_color_preview_info_2.add_theme_color_override("font_color", get_theme_color("contrast_color_2", "Editor"))
	_color_title.add_theme_font_override("font", get_theme_font("title", "EditorFonts"))


# Tab implementation.

# Override.
func set_explored_theme(theme: Theme) -> void:
	super(theme)
	_type_selector_widget.clear_options(true)
	_color_item_map.clear()

	if not _explored_theme:
		return

	var color_types := _explored_theme.get_color_type_list()
	color_types.sort()

	for type in color_types:
		_add_color_items(type, _explored_theme.get_color_list(type))

	_type_selector_widget.restore_selected_value()
	_filter_color_list()


# List management.

func _add_color_items(type_name: String, color_names: PackedStringArray) -> void:
	_type_selector_widget.add_option(type_name)

	var sorted_names = Array(color_names)
	sorted_names.sort()
	_color_item_map[type_name] = sorted_names


func _filter_color_list() -> void:
	_color_list.clear()

	var name_filter := _text_filter_widget.get_filter_value()
	var type_name := _type_selector_widget.get_selected_text()

	if not _color_item_map.has(type_name):
		return

	for color_name: String in _color_item_map[type_name]:
		if not name_filter.is_empty() && color_name.findn(name_filter) < 0:
			continue

		var item_index := _color_list.item_count
		_color_list.add_item(color_name, PREVIEW_BACKGROUND_TEXTURE)
		_color_list.set_item_icon_modulate(item_index, _explored_theme.get_color(color_name, type_name))


func _deselect_color_item() -> void:
	_color_details.visible = false

	_color_preview.texture = null
	_color_preview.self_modulate = Color.WHITE

	_color_preview_info_1.text = ""
	_color_preview_info_2.text = ""
	_color_title.text = ""
	_color_code.code_text = ""


func _select_color_item(item_index: int) -> void:
	var type_name := _type_selector_widget.get_selected_text()
	var color_name := _color_list.get_item_text(item_index)
	var color_texture := _color_list.get_item_icon(item_index)
	var color_modulate := _color_list.get_item_icon_modulate(item_index)

	_color_details.visible = true
	_color_preview.texture = color_texture
	_color_preview.self_modulate = color_modulate

	var info_text := "" +\
		"R: %.5f\n" % [ color_modulate.r ] +\
		"G: %.5f\n" % [ color_modulate.g ] +\
		"B: %.5f\n" % [ color_modulate.b ] +\
		"A: %.5f"   % [ color_modulate.a ]
	var include_alpha := not is_equal_approx(color_modulate.a, 1.0)

	_color_preview_info_1.text = info_text
	_color_preview_info_2.text = "# %s\n" % [ color_modulate.to_html(include_alpha) ]

	_color_title.text = color_name
	_color_code.code_text = "get_theme_color(\"%s\", \"%s\")" % [ color_name, type_name ]
