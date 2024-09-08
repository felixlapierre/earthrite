extends Playspace
class_name TutorialGame

var ExplanationScene = preload("res://src/tutorial/explanation.tscn")

var farming_explanation
var shop_explanation
var winter_explanation

func start_year():
	if turn_manager.year == 0:
		Constants.BASE_HAND_SIZE = 0
		deck = []
		deck.assign(StartupHelper.load_deck(StartupHelper.tutorial_deck))
	elif turn_manager.year == 1:
		Constants.BASE_HAND_SIZE = 0
	super.start_year()
	if turn_manager.year == 1:
		year_one()
	elif turn_manager.year == 2:
		year_two()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func save_game():
	pass

func end_year():
	if turn_manager.year == 2:
		user_interface.GameEventDialog.always_do_event = load("res://src/event/data/trader_common.tres")
	await super.end_year()
	if turn_manager.year == 1:
		year_one_end_year()
	elif turn_manager.year == 2:
		year_two_end_year()
	elif turn_manager.year == 3:
		user_interface.EventPanel.visible = true
		winter_explanation.set_text("At the end of the year, an Event will occur that will give you something useful. Click on the Event button.")
		user_interface.shop.remove_child(shop_explanation)
	elif turn_manager.year == 4:
		user_interface.UpgradeButton.visible = true
		user_interface.FortuneTellerButton.visible = true

func on_turn_end():
	Constants.BASE_HAND_SIZE = 5
	await super.on_turn_end()
	match turn_manager.year:
		1:
			year_one_end_turn()
		2:
			year_two_end_turn()

func year_one():
	for tile in farm.get_all_tiles():
		if tile.purple:
			tile.state = Enums.TileState.Inactive
			tile.update_display()
	user_interface.BlightPanel.visible = false
	user_interface.Stats.visible = false
	turn_manager.blight_pattern = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	#Hardcode turn 1
	var cards_copy = []
	cards_copy.assign(cards.deck_cards)
	for card in cards_copy:
		if cards.number_of_cards_in_hand >= 5:
			break
		if card.name == "Radish":
			cards.draw_specific_card(card)
			cards.deck_cards.erase(card)
		elif card.name == "Potato":
			cards.draw_specific_card(card)
			cards.deck_cards.erase(card)
	cards.reorganize_hand()
	user_interface.update()
	# Explanation: Year 1
	farming_explanation = ExplanationScene.instantiate()
	farming_explanation.set_text("Play Seed Cards (Radish, Potato) from your hand to plant crops on your farm.\n\nEach card costs Energy to play.\n\nWhen you're done your turn, click End Turn to go to the next week, and give your crops time to grow.")
	farming_explanation.position = Vector2(1250, 10)
	farming_explanation.set_exp_size(650, 375)
	user_interface.FarmingUi.add_child(farming_explanation)

func year_one_end_turn():
	match turn_manager.week:
		2:
			farming_explanation.set_text("Each plant takes CLOCK weeks to grow and generates YIELD yield.\n\nHover your mouse over a tile on the farm to see what's growing there and how much Yield it has.\n\nScythe cards will harvest mature plants, gaining Yellow Yield if they are on a Yellow tile.\n\nGenerate 40 Yellow Yield to complete the ritual and go to the next year.")

func year_one_end_year():
	user_interface.FortuneTellerButton.visible = false
	user_interface.EventButton.disabled = true
	user_interface.EventPanel.visible = false
	user_interface.shop.CHOICE_TWO.visible = false
	user_interface.shop.STOCK_TWO.visible = false
	user_interface.shop.CHOICE_TWO_LABEL.visible = false
	shop_explanation = ExplanationScene.instantiate()
	shop_explanation.set_text("[color=aquamarine]Shop[/color]: Choose one of the above cards to add to your deck. You can also skip this choice to get a reroll, which can be used later to refresh your options.\n\n[color=green]Seed cards (Green)[/color]: Plant a seed on your farm that generates yield after some amount of weeks.\n\n[color=red]Action Card (Red)[/color]: Perform special effects that can manipulate your plants or give you other benefits")
	shop_explanation.set_exp_size(1200, 150)
	shop_explanation.position = Vector2(270, 530)
	user_interface.shop.add_child(shop_explanation)
	winter_explanation = ExplanationScene.instantiate()
	winter_explanation.set_text("At the end of each year, go to the Shop to make your deck stronger by adding new cards.\n\nWhen you're ready, click the Next Year button to continue")
	winter_explanation.set_exp_size(500, 400)
	winter_explanation.position = Vector2(1250, 10)
	user_interface.WinterUi.add_child(winter_explanation)
	user_interface.update()
	user_interface.FortuneTeller.current_fortunes.clear()
	user_interface.create_fortune_display()

func year_two():
	for tile in farm.get_all_tiles():
		tile.do_active_check()
	for tile in farm.get_all_tiles():
		if !tile.purple:
			tile.state = Enums.TileState.Inactive
			tile.update_display()
	user_interface.BlightPanel.visible = true
	turn_manager.blight_pattern = [0, 5, 10, 0, 10, 0, 5, 0, 10, 0, 5, 0, 10, 10, 0, 10]
	farming_explanation.set_text("Plants harvested on Purple tiles will not progress the ritual. Instead, they will protect you from the Blight's attacks.\n\nThe Blight will attack you next turn, as indicated by the 'Next turn: 5' display. Plant a Radish so that you can harvest it next turn to protect yourself.")
	# Hardcode turn 1
	var cards_copy = []
	cards_copy.assign(cards.deck_cards)
	for card in cards_copy:
		if cards.number_of_cards_in_hand >= 5:
			break
		if card.name == "Radish":
			cards.draw_specific_card(card)
			cards.deck_cards.erase(card)
		elif card.name == "Potato":
			cards.draw_specific_card(card)
			cards.deck_cards.erase(card)
	cards.reorganize_hand()
	user_interface.update()
	user_interface.FortuneTeller.current_fortunes.clear()
	user_interface.create_fortune_display()

func year_two_end_turn():
	match turn_manager.week:
		2:
			farming_explanation.set_text("Use a Scythe to harvest a plant on a purple tile, which will generate Purple Yield. Generate at least 5 Purple Yield to protect yourself from the Blight this turn.\n\nBe careful! Excess Purple Yield will be lost at the end of the turn. Save some plants for next turn - note from the 'Next Turn: 10' display that the Blight will attack you again.")
		3:
			farming_explanation.set_text("Make sure to protect yourself by harvesting plants on purple tiles whenever the Blight is attacking you. It looks like you will not be attacked next turn.\n\nAt the same time, make sure to plant some plants on yellow tiles so you can complete the ritual.\n\nMake sure to complete the ritual before winter comes on Week 12, when your plants will stop growing.")
			for tile in farm.get_all_tiles():
				tile.do_active_check()

func year_two_end_year():
	user_interface.shop.CHOICE_TWO.visible = true
	user_interface.shop.CHOICE_TWO_LABEL.visible = true
	user_interface.EventButton.disabled = true
	shop_explanation.set_text("Now you can also select one Structure or Enhance from the shop\n\n[color=lightcyan]Structure (Grey)[/color]: Place a structure that occuppies one tile on your farm and grants a permanent bonus effect.\n\n[color=aqua]Enhance (blue)[/color]: Makes one card in your deck stronger by making its effects stronger or adding a new effect.")
	shop_explanation.position = Vector2(270, 875)