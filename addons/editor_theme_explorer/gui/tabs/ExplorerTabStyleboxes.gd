@tool
extends "./ExplorerTab.gd"

const PREVIEW_BACKGROUND_TEXTURE := preload("../../assets/color-preview-icon.png")

const TextFilter := preload("../widgets/TextFilter.gd")
const TypeSelector := preload("../widgets/TypeSelector.gd")
const CodePreview := preload("../widgets/CodePreview.gd")
const ResourceInspector := preload("../widgets/ResourceInspector.gd")

const StyleboxList := preload("../lists/StyleboxList.gd")

var _stylebox_item_map: Dictionary = {} # String, PackedStringArray

@onready var _layout_root: BoxContainer = %Layout
@onready var _text_filter_widget: TextFilter = %TextFilter
@onready var _type_selector_widget: TypeSelector = %TypeSelector

@onready var _stylebox_list: StyleboxList = %StyleboxList
@onready var _stylebox_details: Control = %StyleboxDetails

@onready var _stylebox_preview: Panel = %StyleboxPreviewPanel
@onready var _preview_background: TextureRect = %PreviewBackground
@onready var _stylebox_title: Label = %StyleboxName
@onready var _stylebox_code: Control = %StyleboxCode
@onready var _stylebox_inspector: Control = %StyleboxInspector


func _ready() -> void:
	_update_theme()
	_update_preview_background()

	_add_style_items("EditorStyles", [])
	_filter_style_list()
	_deselect_style_item()

	_text_filter_widget.value_changed.connect(_filter_style_list.unbind(1))
	_type_selector_widget.value_changed.connect(_filter_style_list.unbind(1))
	_stylebox_list.item_selected.connect(_select_style_item)


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		_update_theme()


func _update_theme() -> void:
	if not Engine.is_editor_hint() || not is_node_ready() || get_tree().edited_scene_root == self:
		return

	_layout_root.add_theme_constant_override("separation", 8 * EditorInterface.get_editor_scale())
	_stylebox_preview.add_theme_color_override("font_color", get_theme_color("accent_color", "Editor"))
	_stylebox_title.add_theme_font_override("font", get_theme_font("title", "EditorFonts"))

# Helpers.

func _update_preview_background() -> void:
	if not Engine.is_editor_hint() || not is_node_ready() || get_tree().edited_scene_root == self:
		return

	var bg_image = PREVIEW_BACKGROUND_TEXTURE.get_image().duplicate()
	bg_image.resize(bg_image.get_width() * 2, bg_image.get_height() * 2, Image.INTERPOLATE_NEAREST)
	_preview_background.texture = ImageTexture.create_from_image(bg_image)


# Tab implementation.

# Override.
func set_explored_theme(theme: Theme) -> void:
	super(theme)
	_type_selector_widget.clear_options(true)
	_stylebox_item_map.clear()

	if not _explored_theme:
		return

	var stylebox_types := _explored_theme.get_stylebox_type_list()
	stylebox_types.sort()

	for type in stylebox_types:
		_add_style_items(type, _explored_theme.get_stylebox_list(type))

	_type_selector_widget.restore_selected_value()
	_filter_style_list()


# List management.

func _add_style_items(type_name: String, stylebox_names: PackedStringArray) -> void:
	_type_selector_widget.add_option(type_name)

	var sorted_names = Array(stylebox_names)
	sorted_names.sort()
	_stylebox_item_map[type_name] = sorted_names


func _filter_style_list() -> void:
	_stylebox_list.clear()

	var name_filter := _text_filter_widget.get_filter_value()
	var type_name := _type_selector_widget.get_selected_text()

	if not _stylebox_item_map.has(type_name):
		return

	for stylebox_name: String in _stylebox_item_map[type_name]:
		if not name_filter.is_empty() && stylebox_name.findn(name_filter) < 0:
			continue

		_stylebox_list.add_item(stylebox_name, _explored_theme.get_stylebox(stylebox_name, type_name))


func _deselect_style_item() -> void:
	_stylebox_details.visible = false

	_stylebox_title.text = ""
	_stylebox_preview.remove_theme_stylebox_override("panel")
	_stylebox_code.code_text = ""
	_stylebox_inspector.target_resource = null


func _select_style_item(item_index: int) -> void:
	var type_name := _type_selector_widget.get_selected_text()
	var stylebox_name := _stylebox_list.get_item_name(item_index)
	var stylebox_resource := _stylebox_list.get_item_stylebox(item_index)

	_stylebox_details.visible = true

	_stylebox_title.text = stylebox_name
	_stylebox_preview.add_theme_stylebox_override("panel", stylebox_resource)
	_stylebox_code.code_text = "get_theme_stylebox(\"%s\", \"%s\")" % [ stylebox_name, type_name ]
	_stylebox_inspector.target_resource = stylebox_resource
