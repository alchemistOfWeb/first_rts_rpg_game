extends CanvasLayer
## Панель построек: кнопка "Строительство" открывает/закрывает список,
## клик по постройке выбирает её и запускает режим расстановки (world1.gd
## слушает BuildingManager.selected_type_changed и создаёт призрака).

@onready var toggle_button: Button = $BottomArea/ToggleButton
@onready var building_panel: PanelContainer = $BottomArea/BuildingPanel
@onready var button_row: HBoxContainer = $BottomArea/BuildingPanel/ButtonRow


func _ready() -> void:
	toggle_button.pressed.connect(_on_toggle_pressed)
	_rebuild_buttons()


func _on_toggle_pressed() -> void:
	building_panel.visible = not building_panel.visible


func _rebuild_buttons() -> void:
	for child in button_row.get_children():
		child.queue_free()

	for type in BuildingManager.get_available_types():
		var data: Dictionary = BuildingData.BUILDING_DATA[type]

		var button := Button.new()
		button.custom_minimum_size = Vector2(84, 84)
		button.icon = data.get("icon")
		button.expand_icon = true
		button.text = data["name"]
		button.tooltip_text = "%s\nHP: %d\nРазмер: %dx%d" % [
			data["name"], data["max_hp"], data["size"].x, data["size"].y
		]
		button.pressed.connect(_on_building_button_pressed.bind(type))

		button_row.add_child(button)


func _on_building_button_pressed(type: BuildingData.BuildingType) -> void:
	BuildingManager.select_type(type)
	building_panel.visible = false
