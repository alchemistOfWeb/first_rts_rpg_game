class_name EnemyData
extends RefCounted
# Enemy type definitions. Placeholder for now - only lists available types
# so spawners can pick one. Movement/attack stats arrive with the enemy
# system itself (next step).

enum EnemyType {
	BASIC,
}
 
const ENEMY_DATA := {
	EnemyType.BASIC: {
		"name": "Basic Enemy",
		"max_hp": 30,
		"move_speed": 60.0,        # pixels per second
		"attack_damage": 5,
		"attack_range": 40.0,      # pixels; stops moving once this close to target
		"attack_interval": 1.0,    # seconds between attacks
		"radius": 16.0,            # visual size (pixels)
		"color": Color(0.7, 0.1, 0.1),
		"icon": preload("res://assets/art/creatures/basic_enemy.png"),
	},
}
