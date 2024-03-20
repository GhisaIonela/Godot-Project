extends Node

var tiles = {}
var filepath = "res://Data/Presets/tiles.txt"

func _ready():
	tiles = FileHandler.load_data(filepath)
	
	#if FileAccess.file_exists(filepath):
		#var fileData = FileAccess.open(filepath, FileAccess.READ)
		#tiles = JSON.parse_string(fileData.get_as_text())
