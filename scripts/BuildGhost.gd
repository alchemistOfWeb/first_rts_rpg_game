extends Node2D
## Полупрозрачный "призрак" постройки при расстановке: показывает иконку
## постройки и подкрашивает её зелёным/красным в зависимости от того,
## можно ли строить в текущей клетке.

@onready var icon_rect: TextureRect = $Icon
@onready var overlay: ColorRect = $Overlay


func setup(size_cells: Vector2i, building_icon: Texture2D) -> void:
	var px_size := Vector2(size_cells) * GridConstants.CELL_SIZE

	icon_rect.position = -px_size / 2.0
	icon_rect.size = px_size
	icon_rect.texture = building_icon

	overlay.position = -px_size / 2.0
	overlay.size = px_size


func set_valid(valid: bool) -> void:
	overlay.color = Color(0.25, 0.9, 0.25, 0.35) if valid else Color(0.9, 0.25, 0.25, 0.35)
