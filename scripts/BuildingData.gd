class_name BuildingData
extends RefCounted

enum BuildingType {
	NONE = -1,
	WALL = 0,
	BALLISTA_TOWER = 1,
	QUARRY = 2,
	CASTLE = 3,
	ENEMY_SPAWNER = 4,
}

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
	BuildingType.ENEMY_SPAWNER: {
		"name": "Спавнер",
		"size": Vector2i(2, 2),
		"max_hp": 300,
		"color": Color(0.851, 0.11, 0.2, 1.0),
		"requires_terrain": [],
		"dev_only": true,
		"icon": preload("res://assets/art/buildings/spawner_default.png"),
	},
	
}
