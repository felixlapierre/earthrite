extends Node2D

@onready var state_label = $VBox/StatsPanel/VBox/StateLabel
@onready var yield_label = $VBox/StatsPanel/VBox/YieldLabel
@onready var duration_label = $VBox/StatsPanel/VBox/DurationLabel
@onready var card_base = $VBox/CardBase
@onready var tags_label = $VBox/StatsPanel/VBox/TagsLabel
@onready var coords_label = $VBox/StatsPanel/VBox/Coords

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func setup(tile: Tile):
	tags_label.clear()
	coords_label.text = "(" + tile.get_id() + ")"
	state_label.text = "State: " + str(Enums.TileState.find_key(tile.state))
	if tile.seed != null:
		card_base.set_card_info(tile.seed)
		card_base.visible = true
	elif tile.structure != null:
		card_base.set_card_info(tile.structure)
		card_base.visible = true
	else:
		card_base.visible = false
	
	if tile.seed_grow_time != null and tile.seed_grow_time != 0:
		duration_label.text = "Duration: " + str(tile.current_grow_progress) + " / " + str(tile.seed_grow_time)
		duration_label.visible = true
	else:
		duration_label.visible = false
	
	if tile.current_yield != null and tile.current_yield != 0.0:
		yield_label.visible = true
		yield_label.text = str(snapped(tile.current_yield, 0.01)) + " " + Helper.mana_icon_small()
	else:
		yield_label.visible = false
	if tile.purple:
		tags_label.append_text("[color=cornflowerblue]Color: Blue[/color]\n")
	else:
		tags_label.append_text("[color=gold]Color: Yellow[/color]\n")
	if tile.is_watered():
		tags_label.append_text("[color=deepskyblue]Watered[/color]\n")
	if tile.is_destroyed():
		tags_label.append_text("[color=crimson]Destroyed[/color]\n")
	if tile.is_protected():
		tags_label.append_text("[color=green]Protected[/color]\n")
	card_base.state = Enums.CardState.InShop

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
