extends Control

#Buttons
@onready var startButton : Button = $ButtonContainer/StartButton
@onready var loadButton : Button = $ButtonContainer/LoadButton
@onready var settingsButton : Button = $ButtonContainer/SettingsButton

func _ready():
	startButton.set_meta("load_scene", Index.SCENE.START_MENU)
	loadButton.set_meta("load_scene", Index.SCENE.LOAD_MENU)
	settingsButton.set_meta("load_scene", Index.SCENE.SETTINGS_MENU)
	
func _on_quit_button_pressed():
	get_tree().quit()
