extends Playspace
class_name TutorialGame

var ExplanationScene = preload("res://src/tutorial/explanation.tscn")

var farming_explanation
var shop_explanation
var winter_explanation

func start_new_game():
	for card in StartupHelper.load_deck(StartupHelper.tutorial_deck):
		deck.append(card)
	StartupHelper.setup_farm($FarmTiles, $EventManager)
	start_year()

func start_year():
	if turn_manager.year == 0:
		Settings.TUTORIALS_ENABLED = false
		user_interface.EventPanel.visible = false
		Global.DIFFICULTY = -1
		Global.FINAL_YEAR = 3
		Constants.BASE_HAND_SIZE = 0
	elif turn_manager.year == 1:
		Constants.BASE_HAND_SIZE = 0
	super.start_year()
	match turn_manager.year:
		1:
			year_one()
		2:
			year_two()
		3:
			year_three()
		4:
			year_four()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func save_game():
	pass

func end_year(endless: bool):
	await super.end_year(endless)
	user_interface.EventButton.disabled = true
	if turn_manager.year == 1:
		year_one_end_year()
	elif turn_manager.year == 2:
		year_two_end_year()
	elif turn_manager.year == 3:
		year_three_end_year()
	elif turn_manager.year == 4:
		user_interface.UpgradeButton.visible = true
		

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
	user_interface.AttackPreview.visible = false
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
	farming_explanation.set_text("Click on a [color=chartreuse]Seed Card[/color] (Radish, Potato) in your hand to select it. Then, click on an empty space on your farm to plant the seed there.\n\nEach card costs [color=orangered]Energy[/color] ([img]res://assets/custom/Energy.png[/img]) to play.\n\nOnce you've used all your Energy, or you don't want to play any more cards, click End Turn.")
	farming_explanation.position = Vector2(1250, 10)
	farming_explanation.set_exp_size(650, 375)
	user_interface.FarmingUi.add_child(farming_explanation)

func year_one_end_turn():
	match turn_manager.week:
		2:
			farming_explanation.set_text("Each plant takes [img]res://assets/custom/Time.png[/img] weeks to grow and generates [img]res://assets/custom/YellowMana16.png[/img] mana. One turn equals one week.\n\nHover your mouse over a farm tile for details.\n\n[color=darkorange]Scythe cards[/color] will harvest mature plants, gaining [color=gold]Yellow Mana[/color] (" + Helper.mana_icon() + ") if they are on a [color=gold]Yellow[/color] tile.\n\nGenerate 40 " + Helper.mana_icon() + " to complete the ritual and go to the next year.")
		3:
			farming_explanation.set_text("Your deck starts with 10 cards, and you draw 5 cards per turn. When your deck is empty, your discard pile is shuffled back into your deck.\n\nClick on your deck and discard piles in the bottom corners of your screen to peek at their contents.\n\nContinue farming and generate 40 " + Helper.mana_icon() + " to complete the ritual and go to the next year.")
func year_one_end_year():
	user_interface.FortuneTellerButton.visible = false
	user_interface.shop.CHOICE_TWO.visible = false
	user_interface.shop.STOCK_TWO.visible = false
	user_interface.shop.CHOICE_TWO_LABEL.visible = false
	shop_explanation = ExplanationScene.instantiate()
	shop_explanation.set_text("[color=aquamarine]Shop[/color]: Choose one of the above cards to add to your deck. You can also skip this choice to get a reroll, which can be used later to refresh your options.\n\n[color=green]Seed cards (Green)[/color]: Plant a seed on your farm that generates " + Helper.mana_icon() + " after some amount of weeks.\n\n[color=tomato]Action Card (Red)[/color]: Perform special effects that can manipulate your plants or give you other benefits")
	shop_explanation.set_exp_size(500, 400)
	shop_explanation.position = Vector2(700, 10)
	user_interface.explore.add_child(shop_explanation)
	winter_explanation = ExplanationScene.instantiate()
	winter_explanation.set_text("You've completed the [color=gold]Cleansing Ritual[/color] for Year 1 by generating 40" + Helper.mana_icon() + ".\n\nAt the end of each year, make your deck stronger by adding a card to it. You can also view your current deck by clicking the 'View Deck' button on the bottom left.\n\nWhen you're done, click the Continue button")
	winter_explanation.set_exp_size(500, 400)
	winter_explanation.position = Vector2(700, 10)
	user_interface.explore_button.visible = false
	user_interface.explore.explores = 0
	user_interface.WinterUi.add_child(winter_explanation)
	user_interface.WinterUi.move_child(winter_explanation, 0)
	user_interface.update()
	user_interface.FortuneTeller.current_fortunes.clear()
	user_interface.FortuneTeller.attack_pattern = dummy_attack_pattern([0, 5, 0, 7, 0, 5, 0, 10, 0, 5, 0, 10, 10, 0, 10, 0], [])
	user_interface.create_fortune_display()
	user_interface.shop.STOCK_ONE.get_child(0).set_data(load("res://src/cards/data/action/invigorate.tres"))
	user_interface.shop.STOCK_ONE.get_child(1).set_data(load("res://src/cards/data/seed/daylily.tres"))
	user_interface.shop.STOCK_ONE.get_child(2).set_data(load("res://src/cards/data/action/time_bubble.tres"))
	user_interface.shop.STOCK_ONE.get_child(3).set_data(load("res://src/cards/data/action/frostcut.tres"))
	user_interface.shop.STOCK_ONE.get_child(4).set_data(load("res://src/cards/data/seed/mint.tres"))

func year_two():
	for tile in farm.get_all_tiles():
		tile.do_active_check()
	for tile in farm.get_all_tiles():
		if !tile.purple:
			tile.state = Enums.TileState.Inactive
			tile.update_display()
	user_interface.AttackPreview.visible = true
	turn_manager.blight_pattern = [0, 5, 0, 7, 0, 5, 0, 10, 0, 5, 0, 10, 10, 0, 10, 0]
	dummy_attack_pattern(turn_manager.blight_pattern, [])
	turn_manager.target_blight = 0
	turn_manager.next_turn_blight = 5
	farming_explanation.set_text("Plants harvested on [color=aqua]Blue Tiles[/color] will generate [color=aqua]Blue Mana[/color] (" + Helper.blue_mana() + ") instead of Yellow Mana " + Helper.mana_icon() + ". Blue mana will not progress the ritual; instead, it will protect you from the Blight's attacks.\n\nThe 'Attack Preview' (1" + Helper.time_icon() + ": 5[img]res://assets/custom/BlightAttack.png[/img]) indicates that an attack of strength 5 is coming in 1 week. You will need to generate 5 " + Helper.blue_mana() + " next turn.\n\nPlant a Radish Seed; it will be ready on time as they only take 1 week [img]res://assets/custom/Time.png[/img] to grow")
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
			farming_explanation.set_text("Use a Scythe to harvest a plant on a [color=aqua]blue[/color] tile, which will generate [color=aqua]Blue Mana[/color] (" + Helper.blue_mana() + "). Generate at least 5 " + Helper.blue_mana() + " to protect yourself from the Blight this turn.\n\n[color=orangered]If you end your turn with less than 5 [/color]" + Helper.blue_mana() + ", the circled tiles will be destroyed until the end of the year, and you will take 1 Damage. If you take damage five times, [color=orangered]you lose[/color]!\n\nExcess " + Helper.blue_mana() + " will be lost at the end of the turn.")
		3:
			farming_explanation.set_text("Make sure to protect yourself by harvesting plants on [color=aqua]blue[/color] tiles whenever the Blight is attacking you.\n\nAt the same time, make sure to plant some plants on [color=gold]yellow[/color] tiles so you can complete the ritual.\n\nYou must complete the ritual before winter comes on Week 12, when your plants will stop growing.")
			for tile in farm.get_all_tiles():
				tile.do_active_check()

func year_two_end_year():
	user_interface.shop.CHOICE_TWO.visible = true
	user_interface.shop.CHOICE_TWO_LABEL.visible = true
	user_interface.explore_button.visible = true
	user_interface.explore.explores = 2
	var points = user_interface.explore.points
	points.remove_child(points.get_children()[3])
	points.remove_child(points.get_children()[1])
	points.remove_child(points.get_children()[0])
	winter_explanation.set_text("You can now 'Explore' the areas around your farm and find more ways to get stronger.")
	winter_explanation.set_exp_size(500, 200)
	shop_explanation.set_text("\n\n[color=lightcyan]Structure (Grey)[/color]: Occuppies one tile on your farm and grants a permanent bonus effect.\n\n[color=aqua]Enhance (blue)[/color]: Makes one card in your deck stronger")
	shop_explanation.position = Vector2(520, 260)
	user_interface.shop.STOCK_ONE.get_child(0).set_data(load("res://src/cards/data/action/leaf_ward.tres"))
	user_interface.shop.STOCK_ONE.get_child(1).set_data(load("res://src/cards/data/action/focus.tres"))
	user_interface.shop.STOCK_ONE.get_child(2).set_data(load("res://src/cards/data/seed/coffee.tres"))
	user_interface.shop.STOCK_ONE.get_child(3).set_data(load("res://src/cards/data/seed/cranberry.tres"))
	user_interface.shop.STOCK_ONE.get_child(4).set_data(load("res://src/cards/data/action/inspiration.tres"))
	user_interface.shop.STOCK_TWO.get_child(0).set_data(load("res://src/structure/data/sprinkler.tres"))
	user_interface.shop.STOCK_TWO.get_child(1).set_data(load("res://src/enhance/data/discount.tres"))
	user_interface.shop.STOCK_TWO.get_child(2).set_data(load("res://src/enhance/data/growspeed.tres"))
	user_interface.FortuneTeller.current_fortunes.clear()
	var fortunes: Array[Fortune] = [load("res://src/fortune/data/add_blightroot.gd").new()]
	user_interface.FortuneTeller.attack_pattern = dummy_attack_pattern([0, 0, 10, 0, 10, 5, 0, 15, 10, 0, 10, 0, 10, 10, 0, 10], fortunes)
	user_interface.create_fortune_display()

func year_three():
	turn_manager.ritual_counter = 60
	turn_manager.total_ritual = 60
	turn_manager.blight_pattern = [0, 0, 10, 0, 10, 5, 0, 15, 10, 0, 10, 0, 10, 10, 0, 10]
	farming_explanation.set_exp_size(650, 350)
	farming_explanation.set_text("Each year, the Blight will unleash various attacks to hinder your progress.\n\nHover over the icons underneath this text to see the details of this year's attacks.\n\nMake sure to adapt your strategy in order to complete this year's Ritual safely!")
	user_interface.EndScreen.hide_send_pics()
	user_interface.update()

func year_three_end_year():
	user_interface.FortuneTellerButton.visible = true
	winter_explanation.visible = false
	winter_explanation.set_text("At the end of the year, an Event will occur that will give you something useful. Click on the Event button.")
	winter_explanation.set_exp_size(500, 300)
	user_interface.explore.remove_child(shop_explanation)
	user_interface.FortuneTeller.current_fortunes.clear()
	user_interface.FortuneTeller.current_fortunes.append(load("res://src/fortune/data/wildflowers.gd").new())
	user_interface.FortuneTeller.current_fortunes.append(load("res://src/fortune/data/weeds_on_farm.gd").new())
	user_interface.create_fortune_display()
	user_interface.shop.STOCK_TWO.get_child(0).set_data(load("res://src/structure/data/harvester.tres"))
	user_interface.shop.STOCK_TWO.get_child(1).set_data(load("res://src/enhance/data/regrow.tres"))
	user_interface.shop.STOCK_TWO.get_child(2).set_data(load("res://src/enhance/data/plus1yield.tres"))

func year_four():
	turn_manager.ritual_counter = 70
	turn_manager.total_ritual = 70
	user_interface.update()
	turn_manager.blight_pattern = [0, 0, 10, 0, 10, 5, 0, 15, 10, 0, 10, 0, 10, 10, 0, 10]
	dummy_attack_pattern(turn_manager.blight_pattern, [])
	farming_explanation.visible = false
	user_interface.EndScreen.hide_send_pics()

func on_win():
	super.on_win()
	Unlocks.TUTORIAL_COMPLETE = true
	Unlocks.save_unlocks()

func dummy_attack_pattern(blight_pattern, fortunes: Array[Fortune]):
	var attack_pattern = SimpleAttackBuilder.new()
	for fortune in fortunes:
		attack_pattern.fortune_once(fortune)
	attack_pattern = attack_pattern.build()
	var pattern: Array[int] = []
	pattern.assign(blight_pattern)
	attack_pattern.blight_pattern = pattern
	return attack_pattern
