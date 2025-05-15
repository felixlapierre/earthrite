extends Node2D
class_name Tutorial2

var user_interface: UserInterface
var cards: Cards
var event_manager: EventManager
var turn_manager: TurnManager
var farm: Farm

@onready var click_out: Button = $ClickOutButton
@onready var panel: PanelContainer = $Panel
@onready var label: RichTextLabel = $Panel/Margin/VBox/Label
@onready var continue_label: Label = $Panel/Margin/VBox/Label2
@onready var bird_sprite: AnimatedSprite2D = $Panel/BirdSprite

var text1_welcome = "Welcome to Earthrite!"
var text1_welcome2 = "My forest has been afflicted with a terrible [color=mediumpurple]Blight[/color] after mages carelessly fought, bled and died here for generations."
var text1_welcome3 = "Only pure [color=gold]Mana[/color] - gathered by growing and harvesting plants - can bring the forest back to health."
var text1_welcome4 = "You must Plant, Grow, and Harvest crops on your farm to gain [color=gold]Mana ({MANA})[/color]\n\nTo start, plant some [color=gold]Seeds[/color] on your Farm.\n\nClick on a Seed Card in your hand, then click on your Farm where you want to plant the Seed"


var text_week2 = "When you End your Turn, [color=aqua]1 Week[/color] ({TIME}) passes.\n\nBlueberries and Carrots take 2 Weeks {TIME} (2 turns) to grow, indicated on the bottom right of the card. They will be ready for harvest in 1 turn.\n\nFor now, no crops are ready, so you should plant more seeds on your farm."
var text_week3 = "You have plants ready to [color=gold]Harvest[/color]! Click on a [color=gold]Scythe[/color] card to select it, then click on a farm tile to use the Scythe there.\n\nA Scythe card harvests 9 tiles.\n\nFor now, [color=orange]don't harvest the plants on the right (blue) side of your farm yet[/color]. They will be needed later, when the Blight attacks."
var text_week3_ritual = "When you Harvest plants on the left ([color=yellow]yellow[/color]) side of your farm, you gain [color=yellow]Yellow Mana[/color] ({MANA}).\n\nThe amount of mana yielded by a seed on harvest is indicated on the bottom left of the card.\n\nFill up the [color=gold]Obelisk[/color] with [color=yellow]Mana {MANA}[/color] to complete the ritual and proceed."

var text_week4 = "The [color=mediumpurple]Blight[/color] hates any who would dare set foot in these woods!\n\nThis turn, the Blight is attacking you with a Strength of 6 {BLIGHT}. To protect yourself, you must generate 6 [color=aqua]Blue Mana {BLUE_MANA}[/color] this turn.\n\nTo gain [color=aqua]Blue Mana[/color] {BLUE_MANA}, use a Scythe to harvest plants [color=orange]on the right side of your farm[/color]."
var text_week4_safe = "As long as your total Blue Mana {BLUE_MANA} equals or exceeds the blight attack strength {BLIGHT}, you are safe.\n\nOtherwise, you will take damage equal to the unmatched attack amount {BLIGHT}.\n\n[color=red]Note![/color] Excess Blue Mana {BLUE_MANA} [color=orange]is lost at the end of the turn![/color]"

var text_week5 = "Continue planting, growing and harvesting plants until the ritual is complete.\n\nThe list at the right of the screen indicates when the blight will attack you, and how strong each attack will be.\n\nMake sure to keep the right side of your farm stocked with plants to protect yourself!"

var text_no_energy = "Most cards cost [color=gold]Energy[/color] ({ENERGY}) to play, indicated in the top right of the card.\n\nYou gain 3 energy {ENERGY} at the start of each turn.\n\nSince you are out of energy, click 'End Turn' on the bottom right of the screen"
var text_no_energy2 = "You are out of [color=gold]Energy[/color] again. Click 'End Turn' on the bottom right of the screen."

var end_year_1 = "You've completed the [color=gold]Ritual[/color]!"
var end_year_2 = "Once the ritual is complete, continue to the next [color=gold]Year[/color].\n\nComplete the ritual for 8 years in a row, without succumbing to the Blight's attacks, to [color=gol]Win[/color].\n\nFor now, it's time to [color=gold]rest[/color] and prepare for the next year."

var year2_start1 = "Once again, fill the Obelisk with Mana {MANA} to complete the ritual and progress"
var year2_start2 = "Each turn the Blight may inflict one or more [color=mediumpurple]Hexes[/color] on you to slow your progress.\n\nHexes are displayed on the right of the screen alongside the Blight attacks.\n\nHover over a hex's icon to view its effects."

var completed_tutorials = {}

var dialogue_map = {
	"winter1": "Each [color=gold]Winter[/color], you can [color=gold]Explore[/color] the forest to find cool things that will make you [color=gold]stronger[/color].\n\nClick the [color=gold]Explore[/color] button to get started.",
	"winter_end": "Now that you have finished [color=gold]Exploring[/color], click [color=gold]Continue[/color] to proceed to the next year.",
	"explore": "Each winter, you can [color=gold]Explore[/color] a fixed number of times.\n\nEach time you Explore, you will be presented with a choice of options that will make you stronger.\n\nPick one of these options now!",
	"card": "[color=gold]Gain Card[/color]: Pick a Card to permanently add to your Deck.\n\nHover over a card for more details about its [color=gold]Effects[/color].\n\nIf you don't like any of the cards, you can [color=gold]Skip[/color] instead.",
	"enhance": "[color=gold]Enhance Card[/color]: Pick an Enhancement and apply it to one of the cards in your Deck.\n\nEnhancements will make a card more powerful - permanently!\n\nEach card can hold a maximum of 2 [color=gold]different[/color] enhancements.",
	"remove": "[color=gold]Remove Card[/color]: Pick a card in your Deck to permanently remove.\n\nRemoving weaker cards from your deck is great - it means you will draw your strong cards more often!",
	"structure": "[color=gold]Structure[/color]: Pick a Structure to build on your farm.\n\nStructures provide powerful effects that become immediately available when you start the year.\n\nStructures take up a tile on your farm, and they can be moved around every winter.",
	"expand": "[color=gold]Expand Farm[/color]: Pick a direction in which to increase the size of your farm.\n\nA larger farm gives you more room to plant crops and gain more Mana!",
	"event": "[color=gold]Event[/color]: Each Event presents you with a unique choice of options.\n\nMake the right choice to gain the power that you'll need to defeat the Blight!"
}

var anchor_center = Vector2(700, 170)
var anchor_right = Vector2(1390, 175)
var anchor_left = Vector2(175, 175)
var anchor_farleft = Vector2(15, 100)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func setup(p_ui, p_cards, p_events, p_turns):
	user_interface = p_ui
	cards = p_cards
	event_manager = p_events
	turn_manager = p_turns
	farm = event_manager.farm
	
	event_manager.register_listener(EventManager.EventType.BeforeTurnStart, start_turn)
	event_manager.register_listener(EventManager.EventType.BeforeYearStart, start_year)
	event_manager.register_listener(EventManager.EventType.EndYear, end_year)
	visible = Settings.TUTORIALS_V2
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !Settings.TUTORIALS_V2 or click_out.visible:
		return
	if user_interface.is_winter():
		return

	var year = turn_manager.year
	var week = turn_manager.week
	
	panel.size.y = 0

	if year == 1 and (week == 1 or week == 2):
		highlight_seeds()

	if year == 1 and week == 3:
		if turn_manager.ritual_counter < turn_manager.total_ritual:
			set_text(text_week3_ritual)
			panel.position = anchor_right
			user_interface.EndTurnButton.disabled = false
		highlight_scythes(false)

	if year == 1 and week == 4:
		if turn_manager.ritual_counter <= 0:
			return
		if turn_manager.purple_mana >= turn_manager.target_blight:
			set_text(text_week4_safe)
			panel.position = anchor_left
			user_interface.EndTurnButton.disabled = false
			reset_cards()
		else:
			highlight_scythes(true)

	if turn_manager.energy == 0:
		reset_cards()
		if year == 1 and week == 1:
			set_text(text_no_energy)
			panel.position = anchor_left
			user_interface.EndTurnButton.disabled = false
		elif year == 1 and week == 2:
			set_text(text_no_energy2)
			panel.position = anchor_left
			user_interface.EndTurnButton.disabled = false

func _on_click_out_button_pressed():
	pass # Replace with function body.

func start_year(args: EventArgs):
	if !Settings.TUTORIALS_V2:
		return
	if turn_manager.year == 1:
		panel.position = anchor_center
		set_text(text1_welcome)
		await wait_click_out()
		set_text(text1_welcome2)
		await wait_click_out()
		set_text(text1_welcome3)
		await wait_click_out()
		panel.position = anchor_right
		set_text(text1_welcome4)
		user_interface.EndTurnButton.disabled = true
		
		turn_manager.blight_pattern = [0, 0, 0, 6, 0, 10, 0, 0, 10, 0, 5, 0, 10, 10, 0, 10]
		var attack_pattern = dummy_attack_pattern(turn_manager.blight_pattern, [])
		user_interface.AttackPreview.set_attack(attack_pattern)
	elif turn_manager.year == 2:
		panel.position = anchor_center
		set_text(year2_start1)
		await wait_click_out()
		get_tree().create_timer(1.0).timeout.connect(func():
			panel.position = anchor_left
			set_text(year2_start2)
			wait_click_out())
	elif turn_manager.year == 3:
		Settings.TUTORIALS_V2 = false
		Settings.save_settings()
	else:
		panel.visible = false

func start_turn(args: EventArgs):
	if !Settings.TUTORIALS_V2:
		return
	var year = turn_manager.year
	var week = turn_manager.week
	
	if week <= 2:
		var count = 0
		for card in cards.HAND_CARDS.get_children():
			if card.card_info.type == "SEED":
				count += 1
		if count < 3:
			cards.drawcard()
	
	if year == 1 and week == 2:
		set_text(text_week2)
		user_interface.EndTurnButton.disabled = true
		panel.position = anchor_right
	elif year == 1 and week == 3:
		set_text(text_week3)
		user_interface.EndTurnButton.disabled = true
		panel.position = anchor_right
	elif year == 1 and week == 4:
		set_text(text_week4)
		user_interface.EndTurnButton.disabled = true
		panel.position = anchor_left
	elif year == 1 and week == 5:
		set_text(text_week5)
		panel.position = anchor_center
		await wait_click_out()
	elif week > 5:
		panel.visible = false

func end_year(args: EventArgs):
	if !Settings.TUTORIALS_V2:
		return
	if args.turn_manager.year == 1:
		panel.visible = false
		await get_tree().create_timer(1.0).timeout
		set_text(end_year_1)
		panel.position = anchor_right
		await wait_click_out()
		set_text(end_year_2)
		await wait_click_out()
		get_tree().create_timer(4.0).timeout.connect(func():
			set_text(dialogue_map["winter1"])
			panel.position = anchor_center)


func set_text(text: String):
	text = text.replace("{MANA}", Helper.mana_icon())\
		.replace("{BLUE_MANA}", Helper.blue_mana())\
		.replace("{TIME}", Helper.time_icon())\
		.replace("{ENERGY}", Helper.energy_icon())\
		.replace("{BLIGHT}", Helper.blight_attack_icon())
	label.text = text
	panel.visible = true
	label.size
	bird_speak(text)

func wait_click_out():
	panel.visible = true
	click_out.visible = true
	continue_label.visible = true
	await click_out.pressed
	panel.visible = false
	click_out.visible = false
	continue_label.visible = false

func highlight_tiles(grid_locations: Array[Vector2], state: Enums.TileState):
	for tile in farm.get_all_tiles():
		if tile.grid_location in grid_locations and (tile.state == null or tile.state == state):
			tile.SELECT_PROMPT.visible = true
			tile.SELECT_PROMPT.play("default")
		else:
			tile.TILE_BUTTON.disabled = true

func reset_tiles():
	for tile in farm.get_all_tiles():
		tile.SELECT_PROMPT.visible = false
		tile.SELECT_PROMPT.play("default")
		tile.TILE_BUTTON.disabled = false

func highlight_scythes(purple: bool):
	if Global.selected_card != null:
		if Global.selected_card.type == "ACTION":
			highlight_scythe_spots(purple)
			reset_cards()
		else:
			reset_tiles()
	else:
		reset_tiles()
		# Check if a tile is ready for harvest
		var any_plant_mature = false
		for tile in farm.get_all_tiles():
			if tile.state == Enums.TileState.Mature and tile.purple == purple:
				any_plant_mature = true
		if any_plant_mature:
			for card in cards.HAND_CARDS.get_children():
				if card.card_info.type == "ACTION":
					card.set_highlight(true)
				else:
					card.set_disabled(true)
		else:
			reset_cards()

func highlight_scythe_spots(purple: bool):
	var loc = [Vector2(2, 2), Vector2(2, 3), Vector2(2, 4), Vector2(2, 5), Vector2(2, 6)] if !purple else [Vector2(5, 2), Vector2(5, 3), Vector2(5, 4), Vector2(5, 5), Vector2(5, 6)]
	
	var copy = []
	copy.assign(loc)
	for l in copy:
		var adjacent_tiles = Helper.get_adjacent_active_tiles(l, farm)
		var any_mature = false
		for tile in adjacent_tiles:
			if tile.state == Enums.TileState.Mature:
				any_mature = true
		if !any_mature:
			loc.erase(l)
		
	for tile in farm.get_all_tiles():
		tile.TILE_BUTTON.disabled = !tile.grid_location in loc
		tile.SELECT_PROMPT.visible = tile.grid_location in loc
		tile.SELECT_PROMPT.play("default")

func highlight_seeds():
	var week = turn_manager.week
	if Global.selected_card != null:
		for card in cards.HAND_CARDS.get_children():
			card.set_highlight(false)
		if week == 1:
			highlight_tiles([Vector2(2, 2), Vector2(5, 2), Vector2(2, 4)], Enums.TileState.Empty)
	else:
		reset_tiles()
		for card in cards.HAND_CARDS.get_children():
			if card.card_info.type == "SEED":
				card.set_highlight(true)
			else:
				card.set_disabled(true)

func reset_cards():
	for card in cards.HAND_CARDS.get_children():
		card.set_highlight(false)
		card.set_disabled(false)

func dummy_attack_pattern(blight_pattern, fortunes: Array[Fortune]):
	var attack_pattern = SimpleAttackBuilder.new()
	for fortune in fortunes:
		attack_pattern.fortune_once(fortune)
	attack_pattern = attack_pattern.build()
	var pattern: Array[int] = []
	pattern.assign(blight_pattern)
	attack_pattern.blight_pattern = pattern
	attack_pattern.compute_fortunes(1)
	return attack_pattern

func set_dialogue_ext(key: String = "", anchor: String = "", wait_click: bool = false):
	if !Settings.TUTORIALS_V2:
		return
	if key == "":
		panel.visible = false
		return
	if completed_tutorials.has(key):
		return
	completed_tutorials[key] = true
	set_text(dialogue_map[key])
	match anchor:
		"right":
			panel.position = anchor_right
		"center":
			panel.position = anchor_center
		"left":
			panel.position = anchor_left
		"farleft":
			panel.position = anchor_farleft
	if wait_click:
		await wait_click_out()
	else:
		continue_label.visible = false
		
func bird_speak(text: String):
	bird_sprite.play("speak")
	var time = 1.0
	if text.length() > 25:
		time = 1.8
	elif text.length() > 50:
		time = 2.5
	get_tree().create_timer(time).timeout.connect(func():
		bird_sprite.play("default"))
