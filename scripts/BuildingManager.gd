extends Node
## Автозагрузка: текущий выбор постройки, доступные для игрового UI типы,
## проверка и размещение построек во время игры. Сами данные о постройках -
## в BuildingData (доступен и в редакторе для превью).

const BUILDING_SCENE := preload("res://scenes/buildings/Building.tscn")

var selected_type: BuildingData.BuildingType = BuildingData.BuildingType.NONE

signal selected_type_changed(type: BuildingData.BuildingType)


func select_type(type: BuildingData.BuildingType) -> void:
	selected_type = type
	selected_type_changed.emit(type)


## Постройки, доступные через игровой UI (без dev_only, например Замка).
func get_available_types() -> Array:
	var result := []
	for type in BuildingData.BUILDING_DATA.keys():
		if BuildingData.BUILDING_DATA[type].get("dev_only", false):
			continue
		result.append(type)
	return result


func can_place(origin_cell: Vector2i, type: BuildingData.BuildingType) -> bool:
	if type == BuildingData.BuildingType.NONE or not BuildingData.BUILDING_DATA.has(type):
		return false

	var data: Dictionary = BuildingData.BUILDING_DATA[type]

	# dev_only постройки нельзя ставить через игровой UI/код никогда -
	# только вручную в редакторе Godot
	if data.get("dev_only", false):
		return false

	var size: Vector2i = data["size"]
	for x in range(size.x):
		for y in range(size.y):
			if not GridManager.is_buildable(origin_cell + Vector2i(x, y)):
				return false

	var required: Array = data.get("requires_terrain", [])
	if required.size() > 0:
		var found := false
		for x in range(size.x):
			for y in range(size.y):
				if GridManager.get_terrain(origin_cell + Vector2i(x, y)) in required:
					found = true
					break
			if found:
				break
		if not found:
			return false

	return true


func place(origin_cell: Vector2i, type: BuildingData.BuildingType, parent: Node) -> Building:
	if not can_place(origin_cell, type):
		return null

	var data: Dictionary = BuildingData.BUILDING_DATA[type]
	var building: Building = BUILDING_SCENE.instantiate()

	building.building_name = data["name"]
	building.max_hp = data["max_hp"]
	building.color = data["color"]
	building.icon = data["icon"]

	parent.add_child(building)
	building.setup(data["size"])

	if not GridManager.place_building(origin_cell, building, data["size"]):
		building.queue_free()
		return null

	building.origin_cell = origin_cell
	return building
