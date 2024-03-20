extends Control

@onready var viewport = $MarginContainer/MarginContainer2/Button/SubViewportContainer/SubViewport
@export var tile_rotation : float = 0.0

func set_tile(tid : String) -> void:
	var oldModel : Node = viewport.get_node("Model")
	if oldModel != null:
		viewport.remove_child(oldModel)
		oldModel.queue_free()
	
	var state : GLTFState = GLTFState.new()
	var document : GLTFDocument = GLTFDocument.new()
	document.append_from_file(TileIndex.tiles[tid]["model"], state)
	var scene : Node = document.generate_scene(state)
	scene.name = "Model"
	var meshInstance : MeshInstance3D = scene.get_child(0)
	meshInstance.set_layer_mask(2)
	
	if TileIndex.tiles[tid].has("texture"):
		for key in TileIndex.tiles[tid]["texture"].keys():
			var texture_path = TileIndex.tiles[tid]["texture"][key]
			meshInstance.mesh.surface_get_material(int(key)).albedo_texture = load(texture_path)
			
	if TileIndex.tiles[tid].has("color"):
		for key in TileIndex.tiles[tid]["color"].keys():
			var color = TileIndex.tiles[tid]["color"][key]
			meshInstance.mesh.surface_get_material(key).albedo_color = color
	
	viewport.add_child(scene)
