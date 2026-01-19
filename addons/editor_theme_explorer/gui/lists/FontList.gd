@tool
extends ScrollContainer

signal item_selected(item_index: int)

const ITEM_SCENE := preload("./FontListItem.tscn")
const FontListItem := preload("./FontListItem.gd")

var _selected_item_index: int = -1
var _item_node_pool: Array[FontListItem] = []

@onready var _item_list: VBoxContainer = %List


func _notification(what: int) -> void:
	# Since this is a scene, we can reference nodes way before ready, even though
	# Godot has no quick hooks for that.
	if what == NOTIFICATION_SCENE_INSTANTIATED:
		_item_list = %List

	elif what == NOTIFICATION_PREDELETE:
		for node in _item_node_pool:
			node.queue_free()
		_item_node_pool.clear()


# List management.

func clear() -> void:
	_selected_item_index = -1

	for item_node: FontListItem in _item_list.get_children():
		item_node.item_clicked.disconnect(_select_item_node.bind(item_node))

		_item_list.remove_child(item_node)
		_item_node_pool.push_back(item_node)


func add_item(font_name: String, resource: Font) -> void:
	var item_node: FontListItem = _item_node_pool.pop_back()
	if not item_node:
		item_node = ITEM_SCENE.instantiate()

	item_node.font_name = font_name
	item_node.font_resource = resource
	item_node.selected = false

	_item_list.add_child(item_node)
	item_node.item_clicked.connect(_select_item_node.bind(item_node))


func get_item_name(item_index: int) -> String:
	if item_index < 0 || item_index >= _item_list.get_child_count():
		return ""

	var item_node: FontListItem = _item_list.get_child(item_index)
	return item_node.font_name


func get_item_font(item_index: int) -> Font:
	if item_index < 0 || item_index >= _item_list.get_child_count():
		return null

	var item_node: FontListItem = _item_list.get_child(item_index)
	return item_node.font_resource


func _select_item_node(item_node: FontListItem) -> void:
	var item_index := item_node.get_index()
	if _selected_item_index == item_index:
		return

	if _selected_item_index >= 0 && _selected_item_index < _item_list.get_child_count():
		var current_node: FontListItem = _item_list.get_child(_selected_item_index)
		current_node.selected = false

	_selected_item_index = item_index
	item_node.selected = true
	item_selected.emit(item_index)


func set_sample_text(value: String) -> void:
	for item_node: FontListItem in _item_list.get_children():
		item_node.sample_text = value
