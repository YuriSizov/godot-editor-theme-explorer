@tool
extends AcceptDialog

const ExplorerTab := preload("./tabs/ExplorerTab.gd")
const TAB_SCENES: Array[PackedScene] = [
	preload("./tabs/ExplorerTabColors.tscn"),
	preload("./tabs/ExplorerTabConstants.tscn"),
	preload("./tabs/ExplorerTabFonts.tscn"),
	preload("./tabs/ExplorerTabIcons.tscn"),
	preload("./tabs/ExplorerTabStyleboxes.tscn"),
]
const TAB_NAMES: PackedStringArray = [
	"Colors",
	"Constants",
	"Fonts",
	"Icons",
	"Styles",
]

var _explorer_tabs: Array[ExplorerTab] = []


func _init() -> void:
	title = "Editor Theme Explorer"
	wrap_controls = true
	transient = true
	size = Vector2(1140, 720)

	add_theme_stylebox_override("panel", EditorInterface.get_editor_theme().get_stylebox("panel", "ProjectSettingsEditor"))
	_build_window_ui()


func _ready() -> void:
	_update_editor_theme()


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		_update_editor_theme()


# Helpers.

func _build_window_ui() -> void:
	var tab_container := TabContainer.new()
	tab_container.theme_type_variation = &"TabContainerOdd"
	add_child(tab_container)

	for tab_scene in TAB_SCENES:
		var tab_index := tab_container.get_tab_count()
		var tab_node := tab_scene.instantiate()

		_explorer_tabs.push_back(tab_node)
		tab_container.add_child(tab_node)
		tab_container.set_tab_title(tab_index, TAB_NAMES[tab_index])


# Explored theme management.

func _update_editor_theme() -> void:
	if not is_node_ready():
		return

	var editor_theme := EditorInterface.get_editor_theme()

	for tab in _explorer_tabs:
		tab.set_explored_theme(editor_theme)
