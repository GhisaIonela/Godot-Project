extends Node3D

var tile_map : Dictionary = {}

## Adds a tile node and returns the node if it does not overlap with other nodes
func add_tile(tile : Node3D) -> Node3D:
	tile.connect("overlapping_areas", _on_overlapping_areas)
	if !tile.overlapping:
		add_child(tile)
		tile.get_node("Area3D").collision_layer = 1
		tile_map[tile.get_instance_id()] = tile.position	
	return tile
	
func _on_overlapping_areas(area : Area3D) -> void:
	var tile = area.get_parent()
	remove_tile_node(area.get_parent())

## Gets a tile node by id
func get_tile(tile_id: int) -> Node3D:
	if tile_map.has(tile_id):
		return instance_from_id(tile_id)
	return null

## Gets a tile node by position
func get_tile_at(tile_position: Vector3) -> Node3D:
	return get_tile(tile_map.find_key(tile_position))

## Gets a tile id by position
func get_tile_id_at(tile_position : Vector3) -> Variant:
	var tile_id = tile_map.find_key(tile_position)
	if tile_id != null:
		return tile_id
	return null

## Removes tile by id
func remove_tile(tile_id : int) -> bool:
	var tile : Node3D = instance_from_id(tile_id)
	if tile != null:
		tile_map.erase(tile_id)
		remove_child(tile)
		tile.queue_free()
		return true
	return false
	
## Removes tile 
func remove_tile_node(tile : Node3D) -> bool:
	if tile != null:
		tile_map.erase(tile.get_instance_id())
		remove_child(tile)
		tile.queue_free()
		return true
	return false

## Removes tile by position
func remove_tile_at(tile_position: Vector3) -> bool:
	var tile_id = tile_map.find_key(tile_position)
	if tile_id != null:
		var tile = instance_from_id(tile_id)
		if tile != null:
			tile_map.erase(tile_id)
			remove_child(tile)
			tile.queue_free()
			return true
		return false
	return false
			
## Gets all tile ids
func get_tile_ids() -> Array:
	return tile_map.keys()

func get_tile_map() -> Dictionary:
	return tile_map

func remove_tiles() -> void:
	for tile_id in tile_map.keys():
		remove_tile(tile_id)
