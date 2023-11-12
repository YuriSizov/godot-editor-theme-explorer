@tool
extends VBoxContainer

# Public proprrties
@export var inspected_resource : Resource

# Node references
@onready var inspect_button : Button = $InspectButton

func _ready() -> void:
	inspect_button.pressed.connect(self._on_inspect_pressed)

func _on_inspect_pressed() -> void:
	if (!inspected_resource):
		return

	# Make sure we aren't actually editing the resource in use, as that can create problems.
	EditorInterface.edit_resource(inspected_resource.duplicate())
