extends Object

static func get_plugin_instance(from_node: Node) -> EditorPlugin:
	if !from_node.is_inside_tree() || !Engine.is_editor_hint():
		return null

	var current_node := from_node

	while current_node:
		var instance := current_node.get("editor_plugin") as EditorPlugin
		if instance:
			return instance

		current_node = current_node.get_parent()

	return null

static func get_editor_scale(from_node: Node) -> float:
	var plugin_instance = get_plugin_instance(from_node)
	if !is_instance_valid(plugin_instance):
		return 1.0
	
	return plugin_instance.get_editor_interface().get_editor_scale()
