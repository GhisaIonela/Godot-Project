extends Control

@onready var worldButton : Button = $VBoxContainer/WorldButton
@onready var backButton : Button = $VBoxContainer/BackButton

func _ready():
	worldButton.set_meta("load_scene", Index.SCENE.WORLD_BUILD_MODE)
	backButton.set_meta("load_scene", Index.SCENE.TITLE_SCREEN_MENU)
