extends Node2D

const BUILD_GHOST_SCENE := preload("res://scenes/buildings/BuildGhost.tscn")

@onready var terrain_layer: TileMapLayer = $TileMapLayer

var _ghost: Node2D = null
var _ghost_size: Vector2i = Vector2i.ONE
var _ghost_cell: Vector2i = Vector2i.ZERO


func _ready() -> void:
	GridManager.register_terrain_layer(terrain_layer)
	BuildingManager.selected_type_changed.connect(_start_placement)


func _process(_delta: float) -> void:
	if _ghost == null:
		return

	var cell := GridManager.world_to_cell(get_global_mouse_position())
	if cell != _ghost_cell:
		_ghost_cell = cell
		_update_ghost_position()

	_ghost.set_valid(BuildingManager.can_place(_ghost_cell, BuildingManager.selected_type))


func _unhandled_input(event: InputEvent) -> void:
	if _ghost == null:
		return

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_confirm_placement()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_cancel_placement()
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		_cancel_placement()


func _start_placement(type: BuildingData.BuildingType) -> void:
	_cancel_placement()

	var data: Dictionary = BuildingData.BUILDING_DATA[type]
	_ghost_size = data["size"]

	_ghost = BUILD_GHOST_SCENE.instantiate()
	add_child(_ghost)
	_ghost.setup(_ghost_size, data["icon"])

	_ghost_cell = GridManager.world_to_cell(get_global_mouse_position())
	_update_ghost_position()


func _update_ghost_position() -> void:
	_ghost.global_position = GridManager.cell_to_world(_ghost_cell) \
		+ Vector2(_ghost_size - Vector2i.ONE) * GridManager.CELL_SIZE / 2.0


func _confirm_placement() -> void:
	var building := BuildingManager.place(_ghost_cell, BuildingManager.selected_type, self)
	if building:
		print("Построено: ", building.building_name, " в клетке ", _ghost_cell, ", HP: ", building.current_hp)
		_cancel_placement()
	else:
		print("Нельзя построить тут: ", _ghost_cell)


func _cancel_placement() -> void:
	if _ghost:
		_ghost.queue_free()
		_ghost = null
