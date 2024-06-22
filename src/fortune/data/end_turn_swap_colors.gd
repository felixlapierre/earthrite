extends Fortune

var callable
var farm_ref: Farm

func _init() -> void:
	super("Kaleidoscope", FortuneType.Blank, "Swap purple and yellow zones at end of turn")

func register_fortune(event_manager: EventManager):
	callable = func(farm: Farm, turn_manager: TurnManager, cards: Cards):
		farm_ref = farm
		for tile: Tile in farm.get_node("Tiles").get_children():
			tile.purple = !tile.purple
			tile.update_purple_overlay()
	event_manager.register_on_turn_end(callable)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_on_turn_end(callable)
	if farm_ref != null:
		for tile: Tile in farm_ref.get_node("Tiles").get_children():
			tile.purple = tile.grid_location.x >= Constants.PURPLE_GTE_INDEX
			tile.update_purple_overlay()