extends Node3D

@onready var GUI : Control = $WorldBuildMenu
@onready var tileRepository : Node3D = $TileRepository
@onready var selection : Node3D = $Selection
@onready var cameraFrame : Node3D = $CameraFrame
@onready var worldEnvironment : WorldEnvironment = $WorldEnvironment
@onready var sunLight : DirectionalLight3D = $DirectionalLight3D
const tileScene : PackedScene = preload("res://Scenes/Components/tile.tscn")
const contextMenuScene : PackedScene = preload("res://GUI/Components/context_menu.tscn")
@export var lenght : float = 10
@export var width : float = 10
const floor_layer : int = 0
var delta : float
var locked_camera : bool = false
var mouse_position : Vector2

var player_input : Dictionary = {
	"action_left_click" : false,
	"action_right_click" : false,
	"action_middle_mouse_button" : false,
}

var tile : Dictionary = {
	"tid" : "grass1",
	"rotation" : Vector3(0,0,0),
	"rotation_offset" : Vector3(0,0,0)
}
var edit_mode : bool = true

func _ready() -> void:
	GUI.connect("set_build_tile_properties", _on_set_build_tile)
	GUI.connect("change_sky", _on_change_sky)
	on_ready_set_tiles()
	
func on_ready_set_tiles() -> void:
	for i in range(int(-lenght/2), int(lenght/2+1), 1):
		for j in range(-lenght/2, lenght/2+1, 1):
			var new_tile = tileScene.instantiate()
			new_tile.set_tile(Vector3(i, floor_layer, j), tile)
			tileRepository.add_tile(new_tile)
			
func _process(_delta) -> void:
	delta = _delta
	if edit_mode:
		if player_input["action_left_click"]:
			selection.end_selection(cameraFrame.get_mouse_projection(1), true)
		elif player_input["action_right_click"]:
			selection.end_selection(cameraFrame.get_mouse_projection(1))
	_handle_camera_input()

func _handle_camera_input() -> void:
	if !locked_camera:
		# Camera movement
		if Input.is_action_pressed("action_left"):
			cameraFrame.move_to(Vector3.LEFT, delta)
		if Input.is_action_pressed("action_right"):
			cameraFrame.move_to(Vector3.RIGHT, delta)
		if Input.is_action_pressed("action_up"):
			cameraFrame.move_to(Vector3.FORWARD, delta)
		if Input.is_action_pressed("action_down"):
			cameraFrame.move_to(Vector3.BACK, delta)
		# Camera rotation
		if player_input["action_middle_mouse_button"]:
			var mouse_position_new = get_viewport().get_mouse_position()
			mouse_position = cameraFrame.rotate_around(mouse_position, mouse_position_new)

func _unhandled_input(event : InputEvent) -> void:
	# Camera zoom
	if event.is_action_released("action_scroll_up"):
		cameraFrame.zoom(-1, delta)
	if event.is_action_released("action_scroll_down"):
		cameraFrame.zoom(1, delta)
		
	# Mouse position for camera to rotate around when middle mouse button is pressed
	if event.is_action_pressed("action_middle_mouse_button"):
		mouse_position = get_viewport().get_mouse_position()
		player_input["action_middle_mouse_button"] = true
		GUI.mouse_default_cursor_shape = Control.CURSOR_MOVE
	elif event.is_action_released("action_middle_mouse_button"):
		player_input["action_middle_mouse_button"] = false
		GUI.mouse_default_cursor_shape = Control.CURSOR_ARROW
		if TileIndex.tiles[tile["tid"]].rotatable.y == 1:
			tile["rotation_offset"] = cameraFrame.get_camera_orientation()
		
	#Clicks
	if edit_mode:
		if event.is_action_pressed("action_left_click"):
			player_input["action_left_click"] = true
			selection.begin_selection(cameraFrame.get_mouse_projection(1), tile, true)
		elif event.is_action_released("action_left_click"):
			if player_input["action_left_click"] != false:
				insert_tiles_from_selection()
			player_input["action_left_click"] = false
		elif event.is_action_pressed("action_right_click"):
			player_input["action_right_click"] = true
			selection.begin_selection(cameraFrame.get_mouse_projection(1), tile)
		elif event.is_action_released("action_right_click"):
			player_input["action_right_click"] = false
			create_context_menu()
	else:
		if event.is_action_pressed("left_click"):
			selection.begin_selection(cameraFrame.get_mouse_projection(1), tile)
			
func insert_tiles_from_selection() -> void:
	var selection_start : Vector3 = selection.start
	var selection_end : Vector3 = selection.end
	for x in Utils.create_range(selection_start.x, selection_end.x):
		for y in Utils.create_range(selection_start.y, selection_end.y):
			for z in Utils.create_range(selection_start.z, selection_end.z):
				var new_tile : Node3D = tileScene.instantiate()
				new_tile.set_tile(Vector3(x, y, z), tile)
				tileRepository.add_tile(new_tile)
	selection.clear_selection()
	
func delete_tiles_from_selection() -> void:
	var selection_start : Vector3 = selection.start
	var selection_end : Vector3 = selection.end
	for x in Utils.create_range(selection_start.x, selection_end.x):
		for y in Utils.create_range(selection_start.y, selection_end.y):
			for z in Utils.create_range(selection_start.z, selection_end.z):
				tileRepository.remove_tile_at(Vector3(x, y, z))
	selection.clear_selection()
	
func create_context_menu() -> void:
	var context_menu = contextMenuScene.instantiate()
	context_menu.options = {
		"Delete tiles" : "delete_tiles_from_selection",
		"Insert tiles" : "insert_tiles_from_selection"
	}
	add_child(context_menu)
	context_menu.connect("option_pressed", _on_context_menu_option_pressed)
	
func _on_context_menu_option_pressed(function_called : String) -> void:
	call(function_called)
		
func _on_set_build_tile(tid : String) -> void:
	tile["tid"] = tid
	if TileIndex.tiles[tid].rotatable.y == 1:
		tile["rotation_offset"] = cameraFrame.get_camera_orientation()

func _on_change_sky(color : Color, energy : float) -> void:
	worldEnvironment.environment.sky.sky_material.sky_top_color = color
	color.s = energy/2
	worldEnvironment.environment.sky.sky_material.sky_horizon_color = color
	worldEnvironment.environment.sky.sky_material.ground_horizon_color = color
	sunLight.light_energy = (1 - energy) * 1.5
