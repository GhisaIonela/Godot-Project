class_name Index extends GDScript

enum SCENE {
	TITLE_SCREEN_MENU,
	START_MENU,
	LOAD_MENU,
	SETTINGS_MENU,
	WORLD_BUILD_MODE
}

enum ICON {
	BUILD_TILE_BLOCK32,
	BUILD_TILE_BUILDING32,
	BUILD_TILE_ENTITY32
}

static var ICON_PATH = {
	ICON.BUILD_TILE_BLOCK32 : preload("res://Assets/Icons/Placeholders/block32.png"),
	ICON.BUILD_TILE_BUILDING32 : preload("res://Assets/Icons/Placeholders/building32.png"),
	ICON.BUILD_TILE_ENTITY32 : preload("res://Assets/Icons/Placeholders/entity32.png")
}

enum TILE {
	DEFAULT,
	GREEN_BLOCK,
	BLUE_BLOCK,
	STAIRS,
	STAIRS_INNER_CORNER,
	STAIRS_OUTER_CORNER,
	SLOPE,
	SMALL_HOUSE
}

static var TILE_TEXTURE = {
	TILE.DEFAULT : preload("res://Assets/Textures/Tiles/default.png"),
	TILE.GREEN_BLOCK : preload("res://Assets/Textures/Tiles/green_block.png"),
	TILE.BLUE_BLOCK : preload("res://Assets/Textures/Tiles/blue_block.png"),
	TILE.STAIRS : null,
	TILE.STAIRS_INNER_CORNER : null,
	TILE.STAIRS_OUTER_CORNER : null,
	TILE.SLOPE : null,
	TILE.SMALL_HOUSE : null
}

enum MESH {
	CUBE,
	STAIRS,
	STAIRS_INNER_CORNER,
	STAIRS_OUTER_CORNER,
	SLOPE,
	SMALL_HOUSE
}

static var MESH_PATH = {
	MESH.CUBE : preload("res://Assets/Meshes/default.obj"),
	MESH.STAIRS : preload("res://Assets/Meshes/stairs.obj"),
	MESH.STAIRS_INNER_CORNER : preload("res://Assets/Meshes/stairs_inner_corner.obj"),
	MESH.STAIRS_OUTER_CORNER : preload("res://Assets/Meshes/stairs_outer_corner.obj"),
	MESH.SLOPE : preload("res://Assets/Meshes/slope.obj"),
	MESH.SMALL_HOUSE : preload("res://Assets/Meshes/small_house.obj")
}

static var TILE_MESH = {
	TILE.DEFAULT : MESH.CUBE,
	TILE.GREEN_BLOCK : MESH.CUBE,
	TILE.BLUE_BLOCK : MESH.CUBE,
	TILE.STAIRS : MESH.STAIRS,
	TILE.STAIRS_INNER_CORNER : MESH.STAIRS_INNER_CORNER,
	TILE.STAIRS_OUTER_CORNER : MESH.STAIRS_OUTER_CORNER,
	TILE.SLOPE : MESH.SLOPE,
	TILE.SMALL_HOUSE : MESH.SMALL_HOUSE
}
