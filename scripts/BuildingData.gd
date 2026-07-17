class_name BuildingData
extends RefCounted
## Данные о типах построек (размер, HP, цвет, иконка, требования к местности).
## НЕ автозагрузка — обычный класс, чтобы Building.gd мог читать эти данные
## и во время игры, и в редакторе Godot (для превью при ручной расстановке).

enum BuildingType {
	NONE = -1,
	WALL = 0,
	BALLISTA_TOWER = 1,
	QUARRY = 2,
	CASTLE = 3,
}

## Если переименовываешь файлы иконок - обнови пути preload() здесь
## (это ЕДИНСТВЕННОЕ место, где они теперь прописаны).
const BUILDING_DATA := {
	BuildingType.WALL: {
		"name": "Стена",
		"size": Vector2i(1, 1),
		"max_hp": 50,
		"color": Color(0.55, 0.55, 0.55),
		"requires_terrain": [],
		"dev_only": false,
		"icon": preload("res://assets/art/buildings/wall.png"),
	},
	BuildingType.BALLISTA_TOWER: {
		"name": "Башня с баллистой",
		"size": Vector2i(2, 2),
		"max_hp": 150,
		"color": Color(0.45, 0.3, 0.55),
		"requires_terrain": [],
		"dev_only": false,
		"icon": preload("res://assets/art/buildings/tower.png"),
	},
	BuildingType.QUARRY: {
		"name": "Каменоломня",
		"size": Vector2i(2, 2),
		"max_hp": 100,
		"color": Color(0.6, 0.5, 0.35),
		"requires_terrain": [GridConstants.Terrain.STONE],
		"dev_only": false,
		"icon": preload("res://assets/art/buildings/quarry.png"),
	},
	BuildingType.CASTLE: {
		"name": "Замок",
		"size": Vector2i(3, 3),
		"max_hp": 500,
		"color": Color(0.85, 0.7, 0.2),
		"requires_terrain": [],
		"dev_only": true,
		"icon": preload("res://assets/art/buildings/castle.png"),
	},
}
