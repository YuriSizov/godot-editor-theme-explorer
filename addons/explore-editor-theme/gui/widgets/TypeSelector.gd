@tool
extends HBoxContainer

signal value_changed(value: int)

var _stored_option_value: String = ""

@onready var _selector_label: Label = %Label
@onready var _selector_value: OptionButton = %Value


func _ready() -> void:
	# This doesn't seem to work, but it should. Godot or Windows bug?
	_selector_value.get_popup().max_size.y = 480.0

	_selector_value.clear()
	_selector_value.item_selected.connect(value_changed.emit)


# Option management.

func clear_options(store_selected: bool = false) -> void:
	if store_selected:
		store_selected_value()

	_selector_value.clear()


func add_option(value: String) -> void:
	_selector_value.add_item(value)


func select_option(value: String) -> void:
	for i in _selector_value.item_count:
		if _selector_value.get_item_text(i) != value:
			continue

		_selector_value.select(i)
		break


func get_selected_text() -> String:
	return _selector_value.get_item_text(_selector_value.selected)


func store_selected_value() -> void:
	_stored_option_value = get_selected_text()


func restore_selected_value() -> void:
	select_option(_stored_option_value)
	_stored_option_value = ""
