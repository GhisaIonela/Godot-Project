extends Control

@onready var backButton : Button = $VBoxContainer/BackButton
@onready var tilePreview : Control = $VBoxContainer/TilePreview
@onready var buildTilesContainer : TabContainer = $VBoxContainer/BuildTiles
@onready var blocksContainer : VBoxContainer = $VBoxContainer/BuildTiles/BlocksContainer
@onready var rotateTileLeftButton : Button = $VBoxContainer/TilePreview/HBoxContainer/RotateTileLeftButton
@onready var rotateTileRightButton : Button = $VBoxContainer/TilePreview/HBoxContainer/RotateTileRightButton
@onready var dayPhaseSelector : Control = $VBoxContainer/DayPhaseSelector

signal change_build_tile_properties(tid : String)
signal change_sky(color : Color)
signal set_build_tile_properties(tid : String)

func _ready():
	
	backButton.set_meta("load_scene", Index.SCENE.START_MENU)
	
	buildTilesContainer.set_tab_icon(0, Index.ICON_PATH[Index.ICON.BUILD_TILE_BLOCK32])
	buildTilesContainer.set_tab_title(0 , "")
	buildTilesContainer.set_tab_icon(1, Index.ICON_PATH[Index.ICON.BUILD_TILE_BUILDING32])
	buildTilesContainer.set_tab_title(1 , "")
	buildTilesContainer.set_tab_icon(2, Index.ICON_PATH[Index.ICON.BUILD_TILE_ENTITY32])
	buildTilesContainer.set_tab_title(2 , "")
	
	tilePreview.set_tile("grass1")
	load_tile_buttons()
		
	#rotateTileLeftButton.connect("pressed", _on_change_tile_preview.bind({"rotation": 90}))
	#rotateTileRightButton.connect("pressed", _on_change_tile_preview.bind({"rotation": -90}))
	
	dayPhaseSelector.connect("phase_changed", _on_day_phase_value_changed)
	change_sky.emit(dayPhaseSelector.get_sky_color(), dayPhaseSelector.get_light_energy())
	
func load_tile_buttons():
	for tid in TileIndex.tiles.keys():
		var button : TextureButton = TextureButton.new()
		button.custom_minimum_size = Vector2(64,64)
		button.texture_normal = load(TileIndex.tiles[tid]["icon"])
		button.focus_mode = Control.FOCUS_NONE
		button.connect("pressed", _on_tile_button_pressed.bind(tid))
		button.tooltip_text = TileIndex.tiles[tid]["name"]
		match TileIndex.tiles[tid]["category"]:
			"terrain":
				buildTilesContainer.get_child(0).get_child(0).add_child(button)
			"structure":
				buildTilesContainer.get_child(1).get_child(0).add_child(button)
			"":
				buildTilesContainer.get_child(2).get_child(0).add_child(button)
		
		
func _on_tile_button_pressed( tid : String) -> void:
	tilePreview.set_tile(tid)
	set_build_tile_properties.emit(tid)
	
func _on_day_phase_value_changed(sky_color : Color, light_energy : float) -> void:
	change_sky.emit(sky_color, light_energy)
