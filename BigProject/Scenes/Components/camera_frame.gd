class_name Camera extends Node3D

@onready var camera : Camera3D = $Marker3D/Camera3D
@onready var pivot : Marker3D = $Marker3D
@export var camera_speed = 25
@export var zoom_speed = 500

@export var camera_position : Vector3 = Vector3(0,0,0)
@export var camera_rotation : Vector3 = Vector3(0,0,0)
@export var camera_fov : int = 70 

@export var mouse_sensitivity_y_rotation = 0.3
@export var mouse_sensitivity_x_rotation = 0.05
		
func _ready():
	pivot.global_position = camera_position
	camera.fov = camera_fov
	camera.rotation_degrees = camera_rotation
	rotation_degrees.y = camera_rotation.y
	
func move_to(new_position : Vector3, delta : float) -> void:
	pivot.position += new_position * camera_speed * delta
	
func zoom(fov : int, delta = 1) -> void:
	var new_fov = camera.fov + fov * zoom_speed * delta
	if new_fov >= 1 && new_fov <= 179:
		camera.fov = new_fov

func rotate_around(point_a : Vector2, point_b) -> Vector2:
	var point_c : Vector2 = (point_a - point_b).snapped(Vector2(1,1))
	rotate_camera_y(point_c.x * mouse_sensitivity_y_rotation)
	rotate_camera_x(-point_c.y * mouse_sensitivity_x_rotation)
	return point_b
	
func rotate_camera_y(degrees : float) -> void:
	rotation_degrees.y += degrees
	
func rotate_camera_x(degrees : float) -> void:
	camera.rotation_degrees.x += degrees

func get_camera() -> Camera3D:
	return $Marker3D/Camera3D
	
func get_mouse_projection(collision_mask) -> Dictionary:
	var spaceState = get_world_3d().direct_space_state
	var mousePos = get_viewport().get_mouse_position()
	var rayOrigin = camera.project_ray_origin(mousePos)
	var rayEnd = rayOrigin + camera.project_ray_normal(mousePos) * 1000
	var query = PhysicsRayQueryParameters3D.create(rayOrigin, rayEnd, collision_mask)
	var result = spaceState.intersect_ray(query)
	return result
	
func get_camera_orientation() -> Vector3:
	var camera_rotation_y : float = deg_to_rad(-rotation_degrees.y)
	var siny : float = sin(camera_rotation_y)
	var cosy : float = cos(camera_rotation_y)
	var rotation_offset = Vector3(0,0,0)
	# FRONT
	if (siny >= 0 and cosy > 0 and siny < cosy) or \
		(siny < 0 and cosy > 0 and abs(siny) < cosy):
			rotation_offset.y = deg_to_rad(180)
	# RIGHT
	elif (siny < 0 and cosy < 0 and abs(siny) > abs(cosy)) or \
		(siny < 0 and cosy > 0 and abs(siny) > cosy):
			rotation_offset.y = deg_to_rad(270)
	# BACK
	elif (siny > 0 and cosy < 0 and siny < abs(cosy)) or \
		(siny < 0 and cosy < 0 and abs(siny) < abs(cosy)):
			rotation_offset.y = deg_to_rad(0)
	# LEFT
	elif (siny > 0 and cosy > 0 and siny > cosy) or \
		(siny > 0 and cosy < 0 and siny > abs(cosy)):
			rotation_offset.y = deg_to_rad(90)
	return rotation_offset
