@tool
extends "./ExplorerTab.gd"

const TextFilter := preload("../widgets/TextFilter.gd")
const TypeSelector := preload("../widgets/TypeSelector.gd")
const CodePreview := preload("../widgets/CodePreview.gd")

var _constant_item_map: Dictionary = {} # String, PackedStringArray

@onready var _layout_root: BoxContainer = %Layout
@onready var _text_filter_widget: TextFilter = %TextFilter
@onready var _type_selector_widget: TypeSelector = %TypeSelector

@onready var _constant_list: ItemList = %ConstantList
@onready var _constant_details: Control = %ConstantDetails

@onready var _constant_title: Label = %ConstantName
@onready var _constant_value: Label = %ConstantValue
@onready var _constant_code: CodePreview = %ConstantCode


func _ready() -> void:
	_update_theme()

	_add_constant_items("Editor", [])
	_filter_constant_list()
	_deselect_constant_item()

	_text_filter_widget.value_changed.connect(_filter_constant_list.unbind(1))
	_type_selector_widget.value_changed.connect(_filter_constant_list.unbind(1))
	_constant_list.item_selected.connect(_select_constant_item)


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		_update_theme()


func _update_theme() -> void:
	if not Engine.is_editor_hint() || not is_node_ready() || get_tree().edited_scene_root == self:
		return

	_layout_root.add_theme_constant_override("separation", 8 * EditorInterface.get_editor_scale())
	_constant_title.add_theme_font_override("font", get_theme_font("title", "EditorFonts"))
	_constant_value.add_theme_font_override("font", get_theme_font("source", "EditorFonts"))
	_constant_value.add_theme_color_override("font_color", get_theme_color("accent_color", "Editor"))


# Tab implementation.

# Override.
func set_explored_theme(theme: Theme) -> void:
	super(theme)
	_type_selector_widget.clear_options(true)
	_constant_item_map.clear()

	if not _explored_theme:
		return

	var constant_types := _explored_theme.get_constant_type_list()
	constant_types.sort()

	for type in constant_types:
		_add_constant_items(type, _explored_theme.get_constant_list(type))

	_type_selector_widget.restore_selected_value()
	_filter_constant_list()


# List management.

func _add_constant_items(type_name: String, constant_names: PackedStringArray) -> void:
	_type_selector_widget.add_option(type_name)

	var sorted_names = Array(constant_names)
	sorted_names.sort()
	_constant_item_map[type_name] = sorted_names


func _filter_constant_list() -> void:
	_constant_list.clear()

	var name_filter := _text_filter_widget.get_filter_value()
	var type_name := _type_selector_widget.get_selected_text()

	if not _constant_item_map.has(type_name):
		return

	for constant_name: String in _constant_item_map[type_name]:
		if not name_filter.is_empty() && constant_name.findn(name_filter) < 0:
			continue

		_constant_list.add_item(constant_name)


func _deselect_constant_item() -> void:
	_constant_details.visible = false

	_constant_title.text = ""
	_constant_value.text = ""
	_constant_code.code_text = ""


func _select_constant_item(item_index: int) -> void:
	var type_name := _type_selector_widget.get_selected_text()
	var constant_name := _constant_list.get_item_text(item_index)
	var constant_raw := _explored_theme.get_constant(constant_name, type_name)

	_constant_details.visible = true
	_constant_title.text = constant_name
	_constant_value.text = "%d (%s)" % [ constant_raw, bool(constant_raw) ]
	_constant_code.code_text = "get_theme_constant(\"%s\", \"%s\")" % [ constant_name, type_name ]
