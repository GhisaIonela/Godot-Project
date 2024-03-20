extends Control

@onready var backButton : Button = $BackButton

func _ready():
	backButton.set_meta("load_scene", Index.SCENE.TITLE_SCREEN_MENU)
