extends Node
## Автозагрузка: хранит ссылку на TileMapLayer и построенные здания (то, что
## существует только во время игры). Математику сетки и данные о местности
## берёт из GridConstants (см. этот скрипт - он безопасен для использования
## и в редакторе).

const CELL_SIZE := GridConstants.CELL_SIZE

var terrain_layer: TileMapLayer
var buildings: Dictionary = {}  # Vector2i -> Node (постройка)


func register_terrain_layer(layer: TileMapLayer) -> void:
	terrain_layer = layer


## --- Местность ---

func get_terrain(cell: Vector2i) -> GridConstants.Terrain:
	if terrain_layer == null:
		push_warning("GridManager: terrain_layer не назначен")
		return GridConstants.Terrain.GRASS
	var data := terrain_layer.get_cell_tile_data(cell)
	if data == null:
		return GridConstants.Terrain.GRASS
	return data.get_custom_data("terrain_type") as GridConstants.Terrain


## --- Проверки ---

func is_walkable(cell: Vector2i) -> bool:
	if buildings.has(cell):
		return false
	return GridConstants.TERRAIN_DATA[get_terrain(cell)]["walkable"]

func is_buildable(cell: Vector2i) -> bool:
	if buildings.has(cell):
		return false
	return GridConstants.TERRAIN_DATA[get_terrain(cell)]["buildable"]

func move_cost(cell: Vector2i) -> float:
	return GridConstants.TERRAIN_DATA[get_terrain(cell)]["move_cost"]


## --- Координаты (просто перенаправляют в GridConstants) ---

func world_to_cell(world_pos: Vector2) -> Vector2i:
	return GridConstants.world_to_cell(world_pos)

func cell_to_world(cell: Vector2i) -> Vector2:
	return GridConstants.cell_to_world(cell)

func nearest_origin_cell_for_center(world_pos: Vector2, size: Vector2i) -> Vector2i:
	return GridConstants.nearest_origin_cell_for_center(world_pos, size)


## --- Постройки ---

func place_building(origin_cell: Vector2i, building: Node, size: Vector2i = Vector2i.ONE) -> bool:
	for x in range(size.x):
		for y in range(size.y):
			if not is_buildable(origin_cell + Vector2i(x, y)):
				return false
	for x in range(size.x):
		for y in range(size.y):
			buildings[origin_cell + Vector2i(x, y)] = building
	building.global_position = GridConstants.cell_to_world(origin_cell) + Vector2(size - Vector2i.ONE) * GridConstants.CELL_SIZE / 2.0
	return true

## Регистрирует постройку, которая УЖЕ стоит на сцене (расставлена вручную
## в редакторе) - без проверок и без изменения позиции.
func register_existing_building(origin_cell: Vector2i, building: Node, size: Vector2i) -> void:
	for x in range(size.x):
		for y in range(size.y):
			var c := origin_cell + Vector2i(x, y)
			if buildings.has(c):
				push_warning("GridManager: клетка %s уже занята другой постройкой" % [c])
			buildings[c] = building

func remove_building(cell: Vector2i) -> void:
	var b = buildings.get(cell)
	if b == null:
		return
	for c in buildings.keys().duplicate():
		if buildings[c] == b:
			buildings.erase(c)
