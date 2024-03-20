extends Node3D

@export var active : bool = false

@onready var meshInstance : MeshInstance3D = $MeshInstance3D
@onready var collisionShape : CollisionShape3D = $StaticBody3D/CollisionShape3D
@onready var selectionMaterial := preload("res://Assets/Shaders/selection.tres")

var start : Vector3 = Vector3(0, 0, 0)
var end : Vector3 = Vector3(0, 0, 0)

func begin_selection(start_point : Dictionary, tile : Dictionary, on_surface : bool = false) -> void:
	if !start_point.is_empty():
		#var tid : String = tile["tid"]
		#
		#var oldModel : Node = get_node("Model")
		#if oldModel != null:
			#remove_child(oldModel)
			#oldModel.queue_free()
		#
		#var state : GLTFState = GLTFState.new()
		#var document : GLTFDocument = GLTFDocument.new()
		#document.append_from_file(TileIndex.tiles[tid]["model"], state)
		#var scene : Node = document.generate_scene(state)
		#scene.name = "Model"
		#var meshInstance : MeshInstance3D = scene.get_child(0)
		#meshInstance.set_surface_override_material(0, selectionMaterial)
		#scene.rotate_y(tile["rotation_offset"].y)
		
		#add_child(scene)
		
		var start_position : Vector3 = start_point["position"].snapped(Vector3(1,1,1))
		start = start_position
		if on_surface and start_point["collider"].name != "BoundsStaticBody":
			start += start_point["normal"]
		end = start
		visible = true
		collisionShape.disabled = false
		active = true
		refresh_selection()
	
func end_selection(end_point : Dictionary, on_surface : bool = false) -> void:
	if !end_point.is_empty():
		var end_position : Vector3 = end_point["position"].snapped(Vector3(1,1,1))
		end = end_position
		if on_surface and end_point["collider"].name != "BoundsStaticBody":
			end_position += end_point["normal"]
		if end != end_position:
			end = end_position
		refresh_selection()
		
func clear_selection() -> void:
	start = Vector3(0,0,0)
	end = Vector3(0,0,0)
	visible = false
	collisionShape.disabled = true
	active = false
	refresh_selection()

func refresh_selection(start_position : Vector3 = start, end_position : Vector3 = end) -> void:
	match start_position.x < end_position.x:
		true:
			start_position.x -= 0.505
			end_position.x += 0.505
		false:
			start_position.x += 0.505
			end_position.x -= 0.505
			
	match start_position.z < end_position.z:
		true:
			start_position.z -= 0.505
			end_position.z += 0.505
		false:
			start_position.z += 0.505
			end_position.z -= 0.505

	if start_position.y < end_position.y:
		start_position.y -= 1.05
		end_position.y += 1.05
	else:
		start_position.y += 0.05
		end_position.y -= 0.05

	#var model : Node = get_node("Model")
	#model.scale = abs(start_position - end_position + Vector3(0,1,0))
	#model.global_position = ( start_position + end_position ) / 2
	meshInstance.mesh.size = abs(start_position - end_position + Vector3(0,1,0))
	meshInstance.global_position = ( start_position + end_position ) / 2
	
	collisionShape.shape.size = abs(start_position - end_position + Vector3(0,1,0))
	collisionShape.global_position = ( start_position + end_position ) / 2
