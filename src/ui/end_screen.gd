extends Node2D

@onready var Title = $Center/Panel/VBoxContainer/Title
@onready var Description = $Center/Panel/VBoxContainer/Description
@onready var Stats = $Center/Panel/VBoxContainer/Grid/Stats
@onready var Deck = $Center/Panel/VBoxContainer/Grid/Deck

signal on_main_menu
signal on_endless_mode

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func setup(turn_manager: TurnManager, deck: Array[CardData], farm: Farm):
	# Title
	if turn_manager.blight_damage < Global.MAX_HEALTH:
		Title.text = "You Win! :)"
		Description.text = "The Blight has been cleansed"
		if Global.DIFFICULTY >= 0:
			$Center/Panel/VBoxContainer/EndlessMode.visible = true
	else:
		Title.text = "You Lose! :("
		Description.text = "Your farm was overtaken by the Blight"
		$Center/Panel/VBoxContainer/EndlessMode.visible = false
	
	Stats.clear()
	Deck.clear()
	
	Stats.append_text("Year: " + str(turn_manager.year) + "\n")
	Stats.append_text("Week: " + str(turn_manager.week) + "\n")
	Stats.append_text("Damage: " + str(turn_manager.blight_damage) + "\n")
	Stats.append_text("Farm: " + Global.FARM_TYPE + "\n")
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
		difficulty = "Mastery " + str(Global.DIFFICULTY - 2)
	Stats.append_text("Difficulty: " + difficulty)
	
	Deck.append_text("Deck: " + "\n")
	var cards = {}
	for card in deck:
		if cards.has(card.name):
			cards[card.name] += 1
		else:
			cards[card.name] = 1
	
	for cardname in cards.keys():
		Deck.append_text(cardname + " x" + str(cards[cardname]) + "\n")
	Deck.append_text("\n")
	Deck.append_text("Structures: \n")
	var structures = {}
	for tile in farm.get_all_tiles():
		if tile.structure != null:
			var structure = tile.structure
			if structures.has(structure.name):
				structures[structure.name] += 1
			else:
				structures[structure.name] = 1
	for structurename in structures.keys():
		Deck.append_text(structurename + " x" + str(structures[structurename]) + "\n")


func _on_main_menu_pressed() -> void:
	on_main_menu.emit()

func hide_send_pics():
	$Center/Panel/VBoxContainer/SendPics.visible = false

func do_unlocks(turn_manager: TurnManager, deck: Array[CardData]):
	if Global.DIFFICULTY == -1:
		return #no unlocks in tutorial
	var win = turn_manager.blight_damage < 5
	var farms = []
	var mages = []
	var difficulties = []
	var caption = $Center/Panel/VBoxContainer/Grid/UnlockedCaption
	var value = $Center/Panel/VBoxContainer/Grid/UnlockValue
	
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
	
	# Forest, Mountain, Wilderness, Riverlands unlocked by default

	# Lunar Temple: Win any farm
	if !Unlocks.FARMS_UNLOCKED["4"]:
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
	
	# Mages
	# Now: Novice [0], acorn[1], void[2] and time[3] unlocked by default
	# Ice mage: Win on any difficulty
	if !Unlocks.MAGES_UNLOCKED[str(IceMageFortune.MAGE_ID)] and win:
		Unlocks.MAGES_UNLOCKED[str(IceMageFortune.MAGE_ID)] = true
		mages.append(IceMageFortune.MAGE_NAME)
	# Alchemist: Win on normal
	if !Unlocks.MAGES_UNLOCKED[str(WaterMage.MAGE_ID)] and Global.DIFFICULTY >= 2:
		Unlocks.MAGES_UNLOCKED[str(WaterMage.MAGE_ID)] = true
		mages.append(WaterMage.MAGE_NAME)
	# Blight mage: Win with a blight card in your deck
	if !Unlocks.MAGES_UNLOCKED[str(BlightMageFortune.MAGE_ID)] and win and deck.any(func(card: CardData):
			return card.name == "Blightrose" or card.name == "Bloodrite" or card.name == "Dark Visions" or card.name == "Corruption"):
		Unlocks.MAGES_UNLOCKED[str(BlightMageFortune.MAGE_ID)] = true
		mages.append(BlightMageFortune.MAGE_NAME)
	# Chaos mage: Embrace chaos / Have no basic cards in your final deck
	if !Unlocks.MAGES_UNLOCKED[str(ChaosMageFortune.MAGE_ID)] and win and deck.all(func(card: CardData):
			return card.rarity != "basic"):
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

	Unlocks.save_unlocks()

func _on_endless_mode_pressed() -> void:
	on_endless_mode.emit()
