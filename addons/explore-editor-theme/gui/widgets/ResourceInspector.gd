@tool
extends VBoxContainer

var target_resource: Resource = null:
	set = set_target_resource

@onready var _inspect_button: Button = %InspectButton


func _ready() -> void:
	_inspect_button.pressed.connect(_inspect_target_resource)


# Properties.

func set_target_resource(value: Resource) -> void:
	if target_resource == value:
		return

	target_resource = value
	_inspect_button.disabled = not target_resource


# Interactions.

func _inspect_target_resource() -> void:
	if not target_resource:
		return

	# Make sure we aren't actually editing the resource in use, as that can create problems.
	EditorInterface.edit_resource(target_resource.duplicate())
