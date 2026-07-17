class_name GridConstants
extends RefCounted
## Общие константы и математика сетки. НЕ автозагрузка — обычный класс,
## поэтому доступен как в игре, так и в редакторе Godot (в @tool-скриптах),
## где обычные автозагрузки (GridManager, BuildingManager) ещё не существуют.

const CELL_SIZE := 64

enum Terrain {
	GRASS,
	STONE,
	MOUNTAIN,
	SAND,
	FOREST,
	RIVER,
	SEA,
}

const TERRAIN_DATA := {
	Terrain.GRASS:    {"buildable": true,  "walkable": true,  "move_cost": 1.0},
	Terrain.STONE:    {"buildable": true,  "walkable": true,  "move_cost": 1.2},
	Terrain.MOUNTAIN: {"buildable": false, "walkable": false, "move_cost": 999.0},
	Terrain.SAND:     {"buildable": true,  "walkable": true,  "move_cost": 1.5},
	Terrain.FOREST:   {"buildable": false, "walkable": true,  "move_cost": 2.0},
	Terrain.RIVER:    {"buildable": false, "walkable": false, "move_cost": 999.0},
	Terrain.SEA:      {"buildable": false, "walkable": false, "move_cost": 999.0},
}


static func world_to_cell(world_pos: Vector2) -> Vector2i:
	return Vector2i(floori(world_pos.x / CELL_SIZE), floori(world_pos.y / CELL_SIZE))


static func cell_to_world(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * CELL_SIZE + CELL_SIZE / 2.0, cell.y * CELL_SIZE + CELL_SIZE / 2.0)


static func nearest_origin_cell_for_center(world_pos: Vector2, size: Vector2i) -> Vector2i:
	var offset := Vector2(size - Vector2i.ONE) * CELL_SIZE / 2.0
	return world_to_cell(world_pos - offset)
