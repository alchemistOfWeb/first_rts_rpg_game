@tool
extends Node2D
class_name Building
# Base script for any building.
#
# Two ways a Building gets configured:
# 1) Spawned in code via BuildingManager.place() during gameplay - all
#    fields are set directly by BuildingManager, building_type stays NONE.
# 2) Placed by hand in the editor (Wall.tscn/Castle.tscn/...) - picking a
#    Building Type in the Inspector copies template values from BuildingData
#    ONCE as a starting point. After that icon/max_hp/color/size_cells are
#    freely editable by hand and saved with the scene - BuildingData is
#    never reapplied automatically.

const PLAYER_GROUP := "player"
const ENEMY_GROUP := "enemy"


@export var building_name: String = "Building"
@export var max_hp: int = 100
@export var color: Color = Color.WHITE
@export var icon: Texture2D
@export var size_cells: Vector2i = Vector2i.ONE
@export var starting_group: String = PLAYER_GROUP

@export var building_type: BuildingData.BuildingType = BuildingData.BuildingType.NONE:
	set(value):
		building_type = value
		if Engine.is_editor_hint() and is_node_ready():
			_apply_type_template()

var origin_cell: Vector2i
var current_hp: int

signal died(building: Building)
signal hp_changed(current: int, max: int)

@onready var visual: ColorRect = $Visual
@onready var icon_rect: TextureRect = $Icon
@onready var hp_back: ColorRect = $HPBarBack
@onready var hp_fill: ColorRect = $HPBarFill


func _ready() -> void:
	setup(size_cells)

	if Engine.is_editor_hint():
		return

	add_to_group(starting_group)

	if building_type != BuildingData.BuildingType.NONE:
		_register_with_grid()
	current_hp = max_hp
	_update_hp_bar()


func _process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		return
	# Keep visuals in sync with whatever fields are currently set, so hand
	# edits to icon/color/size_cells show up immediately without touching code.
	setup(size_cells)
	_snap_to_grid()


## Copies default stats from BuildingData. Runs ONLY when the Building Type
## dropdown changes - never again automatically, so later manual edits stick.
func _apply_type_template() -> void:
	if building_type == BuildingData.BuildingType.NONE:
		return
	if not BuildingData.BUILDING_DATA.has(building_type):
		return

	var data: Dictionary = BuildingData.BUILDING_DATA[building_type]
	building_name = data["name"]
	max_hp = data["max_hp"]
	color = data["color"]
	icon = data["icon"]
	starting_group = data["group"]
	size_cells = data["size"]


func _snap_to_grid() -> void:
	var origin := GridConstants.nearest_origin_cell_for_center(global_position, size_cells)
	global_position = GridConstants.cell_to_world(origin) + Vector2(size_cells - Vector2i.ONE) * GridConstants.CELL_SIZE / 2.0


## Runtime only: finds this building's cell from its placed position and
## marks those cells occupied in GridManager.
func _register_with_grid() -> void:
	var origin := GridManager.nearest_origin_cell_for_center(global_position, size_cells)
	global_position = GridManager.cell_to_world(origin) + Vector2(size_cells - Vector2i.ONE) * GridManager.CELL_SIZE / 2.0
	origin_cell = origin
	GridManager.register_existing_building(origin, self, size_cells)


func setup(p_size_cells: Vector2i) -> void:
	size_cells = p_size_cells
	var px_size := Vector2(size_cells) * GridConstants.CELL_SIZE

	visual.position = -px_size / 2.0
	visual.size = px_size
	visual.color = color

	icon_rect.position = -px_size / 2.0
	icon_rect.size = px_size
	icon_rect.texture = icon

	var bar_pos := Vector2(-px_size.x / 2.0, -px_size.y / 2.0 - 10)
	hp_back.position = bar_pos
	hp_back.size = Vector2(px_size.x, 5)
	hp_fill.position = bar_pos
	hp_fill.size = Vector2(px_size.x, 5)


func take_damage(amount: int) -> void:
	current_hp = max(current_hp - amount, 0)
	_update_hp_bar()
	hp_changed.emit(current_hp, max_hp)
	if current_hp <= 0:
		die()


func heal(amount: int) -> void:
	current_hp = min(current_hp + amount, max_hp)
	_update_hp_bar()
	hp_changed.emit(current_hp, max_hp)


func die() -> void:
	GridManager.remove_building(origin_cell)
	died.emit(self)
	queue_free()


func _update_hp_bar() -> void:
	if hp_fill == null or max_hp <= 0:
		return
	var frac := float(current_hp) / float(max_hp)
	hp_fill.size.x = hp_back.size.x * frac
