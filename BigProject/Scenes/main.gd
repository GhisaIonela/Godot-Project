extends Node

var scenes = {
	Index.SCENE.TITLE_SCREEN_MENU : preload("res://GUI/title_screen_menu.tscn"),
	Index.SCENE.START_MENU : preload("res://GUI/start_menu.tscn"),
	Index.SCENE.LOAD_MENU : preload("res://GUI/load_menu.tscn"),
	Index.SCENE.SETTINGS_MENU : preload("res://GUI/setttings_menu.tscn"),
	Index.SCENE.WORLD_BUILD_MODE : preload("res://Scenes/world_build_mode.tscn")
}

func _ready():
	load_scene(Index.SCENE.TITLE_SCREEN_MENU)
	
func load_scene(key : Index.SCENE):
	if get_child_count() > 0:
		var child_scene = get_child(0)
		remove_child(child_scene)
		child_scene.queue_free()
	add_child(scenes[key].instantiate())
	for control in Utils.get_nodes_from_group(self, "load_scene_trigger"):
		control.connect("pressed", _on_load_scene_trigger_pressed.bind(control.get_meta("load_scene")))
	
func _on_load_scene_trigger_pressed(key : Index.SCENE):
	load_scene(key)
