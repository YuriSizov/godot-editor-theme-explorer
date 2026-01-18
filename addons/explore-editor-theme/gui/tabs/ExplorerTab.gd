@tool
extends MarginContainer

var _explored_theme: Theme = null


# Virtual. Implemented by extending classes.
func set_explored_theme(theme: Theme) -> void:
	_explored_theme = theme
