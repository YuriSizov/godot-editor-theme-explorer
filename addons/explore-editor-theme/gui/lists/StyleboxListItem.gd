@tool
extends MarginContainer

signal item_clicked()

const PREVIEW_BACKGROUND_TEXTURE := preload("../../assets/color-preview-icon.png")

var stylebox_name: String = "":
	set = set_stylebox_name
var stylebox_resource: StyleBox = null:
	set = set_stylebox_resource
var selected: bool = false:
	set = set_selected

var _highlight_active_style: StyleBoxFlat = null
var _highlight_inactive_style: StyleBoxFlat = null

@onready var _background_panel: PanelContainer = %BackgroundPanel

@onready var _stylebox_name_label: Label = %StyleboxName
@onready var _stylebox_preview: Panel = %PreviewPanel
@onready var _preview_background: TextureRect = %PreviewBackground


func _ready() -> void:
	_update_theme()

	_update_labels()
	_update_preview_background()
	_update_preview()
	_update_background()


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		_update_theme()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton

		if mb.button_index == MOUSE_BUTTON_LEFT && not mb.pressed:
			item_clicked.emit()


func _update_theme() -> void:
	if not Engine.is_editor_hint() || not is_node_ready() || get_tree().edited_scene_root == self:
		return

	var panel_style := get_theme_stylebox("panel", "Panel").duplicate()
	panel_style.set_content_margin_all(0)
	_background_panel.add_theme_stylebox_override("panel", panel_style)

	_highlight_active_style = StyleBoxFlat.new()
	_highlight_inactive_style = _highlight_active_style.duplicate()
	_highlight_active_style.bg_color = get_theme_color("highlight_color", "Editor")
	_highlight_inactive_style.bg_color = Color(0, 0, 0, 0)


# Properties.

func set_stylebox_name(value: String) -> void:
	if stylebox_name == value:
		return

	stylebox_name = value
	_update_preview()
	_update_labels()


func set_stylebox_resource(value: StyleBox) -> void:
	if stylebox_resource == value:
		return

	stylebox_resource = value
	_update_preview()


func set_selected(value: bool) -> void:
	if selected == value:
		return

	selected = value
	_update_background()


# Helpers.

func _update_labels() -> void:
	if not is_node_ready():
		return

	_stylebox_name_label.text = stylebox_name
	tooltip_text = stylebox_name


func _update_preview() -> void:
	if not is_node_ready() || stylebox_name.is_empty() || not stylebox_resource:
		return

	_stylebox_preview.add_theme_stylebox_override("panel", stylebox_resource)


func _update_preview_background() -> void:
	if not Engine.is_editor_hint() || not is_node_ready() || get_tree().edited_scene_root == self:
		return

	var bg_image = PREVIEW_BACKGROUND_TEXTURE.get_image().duplicate()
	bg_image.resize(bg_image.get_width() * 2, bg_image.get_height() * 2, Image.INTERPOLATE_NEAREST)
	_preview_background.texture = ImageTexture.create_from_image(bg_image)


func _update_background() -> void:
	if not Engine.is_editor_hint() || not is_node_ready() || (is_inside_tree() && get_tree().edited_scene_root == self):
		return

	if selected:
		_stylebox_name_label.add_theme_stylebox_override("normal", _highlight_active_style)
	else:
		_stylebox_name_label.add_theme_stylebox_override("normal", _highlight_inactive_style)
