@tool
extends Building
# Enemy spawner building. Placed manually in the editor (like the Castle).
# Inherits HP, icon display and grid-snapping from Building - this class only
# adds the enemy_type setting. Actual spawning logic is added in the next
# step, once the Enemy scene exists.
#
# NOTE: @tool must be re-declared here even though Building.gd already has it -
# Godot checks the tool flag on the script actually attached to the node,
# not on its parent class.

const ENEMY_SCENE := preload("res://scenes/enemies/Enemy.tscn")
 
@export var enemy_type: EnemyData.EnemyType = EnemyData.EnemyType.BASIC
@export var spawn_interval: float = 5.0
@export var spawn_search_radius: int = 2 

@onready var spawn_timer: Timer = $SpawnTimer
 
 
func _ready() -> void:
	super._ready()  # run Building's own setup (editor preview / grid registration) first
 
	if Engine.is_editor_hint():
		return
 
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()
 
 
func _on_spawn_timer_timeout() -> void:
	var enemy: Enemy = ENEMY_SCENE.instantiate()
	get_tree().current_scene.add_child(enemy)
	enemy.global_position = GridManager.cell_to_world(_find_spawn_cell())
	enemy.setup(enemy_type)
	
func _find_spawn_cell() -> Vector2i:
	var candidates: Array[Vector2i] = []
 
	for x in range(-spawn_search_radius, spawn_search_radius + 1):
		for y in range(-spawn_search_radius, spawn_search_radius + 1):
			var cell := origin_cell + Vector2i(x, y)
			if GridManager.is_walkable(cell):
				candidates.append(cell)
 
	if candidates.is_empty():
		return origin_cell
	return candidates[randi() % candidates.size()]
