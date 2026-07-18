extends Node2D
class_name Enemy
# A single enemy unit. Does NOT snap to the grid (unlike buildings) - it
# moves in free pixel coordinates, but each movement step is checked against
# GridManager.is_walkable() so it can't cross mountains, water or buildings.

var max_hp: int
var move_speed: float
var attack_damage: int
var attack_range: float
var attack_interval: float

var current_hp: int
var target: Building = null
var _attack_cooldown: float = 0.0


@onready var icon_rect: TextureRect = $Icon
@onready var hp_back: ColorRect = $HPBarBack
@onready var hp_fill: ColorRect = $HPBarFill

signal died(enemy: Enemy)


func _ready() -> void:
	add_to_group("enemy")

## Called once right after instantiate() + add_child(), fills in stats from
## EnemyData and sizes the visuals. Same pattern as Building.setup().
func setup(enemy_type: EnemyData.EnemyType) -> void:
	var data: Dictionary = EnemyData.ENEMY_DATA[enemy_type]
	max_hp = data["max_hp"]
	move_speed = data["move_speed"]
	attack_damage = data["attack_damage"]
	attack_range = data["attack_range"]
	attack_interval = data["attack_interval"]
	current_hp = max_hp

	var radius: float = data["radius"]
	var size := Vector2.ONE * radius * 2.0


	icon_rect.position = -size / 2.0
	icon_rect.size = size
	icon_rect.texture = data["icon"]

	hp_back.position = Vector2(-size.x / 2.0, -size.y / 2.0 - 8)
	hp_back.size = Vector2(size.x, 4)
	hp_fill.position = hp_back.position
	hp_fill.size = hp_back.size


func _process(delta: float) -> void:
	if not is_instance_valid(target):
		target = _find_nearest_building()
		if target == null:
			return  # nothing left to attack, stay idle

	var distance := _distance_to_building(target)
	if distance > attack_range:
		_move_towards(target.global_position, delta)
	else:
		_attack_cooldown -= delta
		if _attack_cooldown <= 0.0:
			target.take_damage(attack_damage)
			_attack_cooldown = attack_interval


## Moves each axis (X then Y) separately and only if the resulting cell is
## walkable. This is a simple obstacle check, not real pathfinding - the
## enemy can still get stuck on complex mazes, but it slides along straight
## walls instead of freezing completely. Proper pathfinding is future work.
func _move_towards(target_pos: Vector2, delta: float) -> void:
	var direction := (target_pos - global_position).normalized()
	var step := direction * move_speed * delta

	var try_x := global_position + Vector2(step.x, 0)
	if GridManager.is_walkable(GridManager.world_to_cell(try_x)):
		global_position.x = try_x.x

	var try_y := global_position + Vector2(0, step.y)
	if GridManager.is_walkable(GridManager.world_to_cell(try_y)):
		global_position.y = try_y.y


func _distance_to_building(building: Building) -> float:
	var half_size := Vector2(building.size_cells) * GridConstants.CELL_SIZE / 2.0
	var closest := Vector2(
		clamp(global_position.x, building.global_position.x - half_size.x, building.global_position.x + half_size.x),
		clamp(global_position.y, building.global_position.y - half_size.y, building.global_position.y + half_size.y)
	)
	return global_position.distance_to(closest)

## Scans all player buildings and returns the closest one.
## Only called when the current target is gone, not every frame.
func _find_nearest_building() -> Building:
	var nearest: Building = null
	var nearest_dist := INF
	
	for building in get_tree().get_nodes_in_group("player"):
		var dist := _distance_to_building(building)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = building

	return nearest


func take_damage(amount: int) -> void:
	current_hp = max(current_hp - amount, 0)
	var frac := float(current_hp) / float(max_hp)
	hp_fill.size.x = hp_back.size.x * frac
	if current_hp <= 0:
		died.emit(self)
		queue_free()
