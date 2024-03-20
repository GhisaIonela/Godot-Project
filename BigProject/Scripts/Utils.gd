class_name Utils extends GDScript

static func create_range(a : float, b : float, step : float = 1) -> Array:
	if a > b:
		return range(b, a+1, step)
	return range(a, b+1, step)

static func get_nodes_from_group(root : Node, group_name : String) -> Array[Node] :
	return root.get_tree().get_nodes_in_group(group_name)
