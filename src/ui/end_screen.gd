extends Node2D

var MINI_CARD = preload("res://src/ui/menus/mini_card.tscn")

@onready var Title = $Center/Panel/Margin/VBox/Title
@onready var Description = $Center/Panel/Margin/VBox/Description
@onready var Stats = $Center/Panel/Margin/VBox/Grid/Stats
@onready var Deck2 = $Center/Panel/Margin/VBox/Grid/Deck2/Flow
@onready var SendPics = $Center/Panel/Margin/VBox/SendPics

signal on_main_menu
signal on_endless_mode

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func setup(turn_manager: TurnManager, deck: Array[CardData], farm: Farm, user_interface: UserInterface):
	# Title
	if turn_manager.blight_damage < Global.MAX_HEALTH:
		Title.text = "You Win! :)"
		Description.text = "The Blight has been cleansed"
		if Global.DIFFICULTY >= 0:
			$Center/Panel/Margin/VBox/EndlessMode.visible = true
	else:
		Title.text = "You Lose! :("
		Description.text = "Your farm was overtaken by the Blight"
		$Center/Panel/Margin/VBox/EndlessMode.visible = false
	
	Settings.TUTORIALS_V2 = false
	Settings.save_settings()
	Stats.clear()
	
	Stats.append_text("Year: " + str(turn_manager.year) + "\n")
	Stats.append_text("Week: " + str(turn_manager.week) + "\n")
	Stats.append_text("Damage: " + str(turn_manager.blight_damage) + "\n\n")
	Stats.append_text("Farm: [img]" + FarmType.farms[Global.FARM_TYPE].icon.resource_path + "[/img] " + Global.FARM_TYPE.to_lower().capitalize() + "\n")
	Stats.append_text("Mage: [img]" + user_interface.mage_fortune.icon.resource_path + "[/img] " + user_interface.mage_fortune.name + "\n")
	var difficulty;
	match Global.DIFFICULTY:
		-1:
			difficulty = "Tutorial"
		0:
			difficulty = "Easy"
		1:
			difficulty = "Normal"
		2:
			difficulty = "Hard"
	if Global.DIFFICULTY >= 3:
		difficulty = "Mastery" + str(Global.DIFFICULTY - 2)
	Stats.append_text("Difficulty: [img]" + StatisticsDisplay.get_difficulty_icon(difficulty).resource_path + "[/img] " + difficulty)

	for card in deck:
		var mini_card = MINI_CARD.instantiate()
		mini_card.setup(card)
		Deck2.add_child(mini_card)
	
	for tile in farm.get_all_tiles():
		if tile.structure != null:
			var structure = tile.structure
			var mini_card = MINI_CARD.instantiate()
			mini_card.setup_structure(structure)
			Deck2.add_child(mini_card)

func _on_main_menu_pressed() -> void:
	on_main_menu.emit()

func hide_send_pics():
	SendPics.visible = false

func do_unlocks(turn_manager: TurnManager, deck: Array[CardData]):
	print("Start unlocks")
	if Global.DIFFICULTY == -1:
		return #no unlocks in tutorial
	var win = turn_manager.blight_damage < Global.MAX_HEALTH
	var farms = []
	var mages = []
	var difficulties = []
	var caption = $Center/Panel/Margin/VBox/Grid/UnlockedCaption
	var value = $Center/Panel/Margin/VBox/Grid/UnlockValue
	
	print("Win: " + str(win))
	print("Difficulty: " + str(Global.DIFFICULTY))
	print(Unlocks.DIFFICULTIES_UNLOCKED)
	print(Unlocks.MAGES_UNLOCKED)
	print(Unlocks.FARMS_UNLOCKED)
	#Difficulty
	if !Unlocks.DIFFICULTIES_UNLOCKED["1"] and win:
		Unlocks.DIFFICULTIES_UNLOCKED["1"] = true
		difficulties.append("Normal")
	if !Unlocks.DIFFICULTIES_UNLOCKED["2"] and win and Global.DIFFICULTY == 1:
		Unlocks.DIFFICULTIES_UNLOCKED["2"] = true
		difficulties.append("Hard")
	if !Unlocks.DIFFICULTIES_UNLOCKED["3"] and win and Global.DIFFICULTY == 2:
		Unlocks.DIFFICULTIES_UNLOCKED["3"] = true
		difficulties.append("Mastery")
	
	for i in range(4):
		var diff = 4 + i
		if !Unlocks.DIFFICULTIES_UNLOCKED[str(diff)] and win and Global.DIFFICULTY == diff - 1:
			Unlocks.DIFFICULTIES_UNLOCKED[str(diff)] = true
			difficulties.append("Mastery " + str(diff - 2))
	
	print(difficulties)
	# Forest, Mountain, Wilderness, Riverlands unlocked by defaultF

	# Lunar Temple: Win any farm
	if !Unlocks.FARMS_UNLOCKED["4"] and win:
		Unlocks.FARMS_UNLOCKED["4"] = true
		farms.append("Lunar Temple")

	# Storm Vale: Win Wilderness farm or Lunar temple
	if !Unlocks.FARMS_UNLOCKED["5"] and win and (Global.FARM_TYPE == "LUNARTEMPLE" or Global.FARM_TYPE == "WILDERNESS"):
		Unlocks.FARMS_UNLOCKED["5"] = true
		farms.append("Storm Vale")

	# Scrapyard: Win Mountain farm or Riverland
	if !Unlocks.FARMS_UNLOCKED["6"] and win and (Global.FARM_TYPE == "MOUNTAINS" or Global.FARM_TYPE == "RIVERLANDS"):
		Unlocks.FARMS_UNLOCKED["6"] = true
		farms.append("Scrapyard")
	
	if !Unlocks.FARMS_UNLOCKED["7"]:
		Unlocks.FARMS_UNLOCKED["7"] = true
		farms.append("Village")
	
	print(farms)
	# Mages
	# Now: Novice [0], acorn[1], void[2] and time[3] unlocked by default
	# Ice mage: Win on any difficulty
	if !Unlocks.MAGES_UNLOCKED[str(IceMageFortune.MAGE_ID)] and win:
		Unlocks.MAGES_UNLOCKED[str(IceMageFortune.MAGE_ID)] = true
		mages.append(IceMageFortune.MAGE_NAME)
	# Alchemist: Win on normal
	if !Unlocks.MAGES_UNLOCKED[str(WaterMage.MAGE_ID)] and Global.DIFFICULTY >= 2 and win:
		Unlocks.MAGES_UNLOCKED[str(WaterMage.MAGE_ID)] = true
		mages.append(WaterMage.MAGE_NAME)
	# Blight mage: Win with a blight card in your deck
	if !Unlocks.MAGES_UNLOCKED[str(BlightMageFortune.MAGE_ID)] and win and deck.any(func(card: CardData):
			return card.name == "Blightrose" or card.name == "Bloodrite" or card.name == "Dark Visions" or card.name == "Corruption"):
		Unlocks.MAGES_UNLOCKED[str(BlightMageFortune.MAGE_ID)] = true
		mages.append(BlightMageFortune.MAGE_NAME)
	# Chaos mage: Embrace chaos / Have no basic cards in your final deck
	if !Unlocks.MAGES_UNLOCKED[str(ChaosMageFortune.MAGE_ID)] and win and deck.all(func(card: CardData):
			return card.rarity != "basic" or card.enhances.size() > 0):
		Unlocks.MAGES_UNLOCKED[str(ChaosMageFortune.MAGE_ID)] = true
		mages.append(ChaosMageFortune.MAGE_NAME)
	# Fire mage: Win on Hard
	if !Unlocks.MAGES_UNLOCKED[str(FireMageFortune.MAGE_ID)] and win and Global.DIFFICULTY >= 2:
		Unlocks.MAGES_UNLOCKED[str(FireMageFortune.MAGE_ID)] = true
		mages.append(FireMageFortune.MAGE_NAME)
	# Archmage: Win on Mastery
	if !Unlocks.MAGES_UNLOCKED[str(ArchmageFortune.MAGE_ID)] and win and Global.DIFFICULTY >= 3:
		Unlocks.MAGES_UNLOCKED[str(ArchmageFortune.MAGE_ID)] = true
		mages.append(ArchmageFortune.MAGE_NAME)
	
	print(mages)
	if difficulties.size() > 0:
		for diff in difficulties:
			caption.append_text("[color=gold]Unlocked New Difficulty![/color]\n")
			value.append_text("[color=aqua]" + diff + "[/color]\n")
	if farms.size() > 0:
		for farm in farms:
			caption.append_text("[color=gold]Unlocked New Farm![/color]\n")
			value.append_text("[color=aqua]" + farm + "[/color]\n")
	if mages.size() > 0:
		for mage in mages:
			caption.append_text("[color=gold]Unlocked New Character![/color]\n")
			value.append_text("[color=aqua]" + mage + "[/color]\n")

	print("Saving unlocks")
	Unlocks.save_unlocks()

func _on_endless_mode_pressed() -> void:
	on_endless_mode.emit()
