extends Node3D

signal overlapping_areas(area : Area3D)
var overlapping : bool = false
var id : String
@onready var highlight_shader : Shader = preload("res://Assets/Shaders/highlight.gdshader")
var shaderMaterial : ShaderMaterial

func _ready():
	shaderMaterial = ShaderMaterial.new()
	shaderMaterial.shader = highlight_shader

func set_tile(tile_position : Vector3, tile : Dictionary) -> void:
	var tid : String = tile["tid"]
	id = tid
	if !tid.is_empty():
		var oldModel := get_node("Model")
		if oldModel != null:
			remove_child(oldModel)
			oldModel.queue_free()
		
		var state : GLTFState = GLTFState.new()
		var document : GLTFDocument = GLTFDocument.new()
		document.append_from_file(TileIndex.tiles[tid]["model"], state)
		var scene : Node = document.generate_scene(state)
		var meshInstance : MeshInstance3D = scene.get_child(0)
		
		if TileIndex.tiles[tid].has("texture"):
			for key in TileIndex.tiles[tid]["texture"].keys():
				var texture_path = TileIndex.tiles[tid]["texture"][key]
				meshInstance.mesh.surface_get_material(key).albedo_texture = load(texture_path)
		
		if TileIndex.tiles[tid].has("color"):
			for key in TileIndex.tiles[tid]["color"].keys():
				var texture_path = TileIndex.tiles[tid]["color"][key]
				meshInstance.mesh.surface_get_material(key).albedo_color = texture_path
		
		position = tile_position
		var rotation_offset : Vector3 = tile["rotation_offset"]
		rotate_x(rotation_offset.x)
		rotate_y(rotation_offset.y)
		rotate_z(rotation_offset.z)
		
		scene.name = "Model"
		add_child(scene)
		
func has_overlapping_areas() -> bool:
	return $Area3D.has_overlapping_areas()

func _on_area_3d_area_entered(area : Area3D) -> void:
	overlapping = true
	overlapping_areas.emit(area)

func _on_area_3d_area_exited(area):
	overlapping = false
	#
#func _on_static_body_3d_mouse_entered():
	#var meshInstance : MeshInstance3D = get_node("Model").get_child(0)
	#for index in range(0, meshInstance.mesh.get_surface_count()):
		#meshInstance.mesh.surface_get_material(index).next_pass = shaderMaterial
#
#func _on_static_body_3d_mouse_exited():
	#var meshInstance : MeshInstance3D = get_node("Model").get_child(0)
	#for index in range(0, meshInstance.mesh.get_surface_count()):
		#meshInstance.mesh.surface_get_material(index).next_pass = null
