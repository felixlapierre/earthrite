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
		3:
			difficulty = "Mastery " + str(Mastery.get_total_mastery())
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
	
	# Riverland Farm
	if !Unlocks.FARMS_UNLOCKED["1"]:
		Unlocks.FARMS_UNLOCKED["1"] = true
		farms.append("Riverlands")
	# Wilderness Farm
	if !Unlocks.FARMS_UNLOCKED["2"] and win and Global.FARM_TYPE == "RIVERLANDS":
		Unlocks.FARMS_UNLOCKED["2"] = true
		farms.append("Wilderness")
	# Mountain Farm
	if !Unlocks.FARMS_UNLOCKED["3"] and win and Global.FARM_TYPE == "WILDERNESS":
		Unlocks.FARMS_UNLOCKED["3"] = true
		farms.append("Mountains")
	# Lunar Temple
	if !Unlocks.FARMS_UNLOCKED["4"] and win and Global.FARM_TYPE == "MOUNTAINS":
		Unlocks.FARMS_UNLOCKED["4"] = true
		farms.append("Lunar Temple")
	# Storm Vale
	if !Unlocks.FARMS_UNLOCKED["5"] and win and Global.FARM_TYPE == "LUNARTEMPLE":
		Unlocks.FARMS_UNLOCKED["5"] = true
		farms.append("Storm Vale")
	
	# Mages
	if !Unlocks.MAGES_UNLOCKED["1"]:
		Unlocks.MAGES_UNLOCKED["1"] = true
		mages.append(IceMageFortune.MAGE_NAME)
	if !Unlocks.MAGES_UNLOCKED["2"] and Global.FARM_TYPE == "RIVERLANDS":
		Unlocks.MAGES_UNLOCKED["2"] = true
		mages.append(WaterMage.MAGE_NAME)
	#if !Unlocks.MAGES_UNLOCKED["3"] and Global.MAGE == IceMageFortune.MAGE_NAME:
	#	Unlocks.MAGES_UNLOCKED["3"] = true
	#	mages.append(LunarMageFortune.MAGE_NAME)
	if !Unlocks.MAGES_UNLOCKED["4"] and win and deck.any(func(card: CardData):
			return card.name == "Blightrose" or card.name == "Bloodrite" or card.name == "Dark Visions"):
		Unlocks.MAGES_UNLOCKED["4"] = true
		mages.append(BlightMageFortune.MAGE_NAME)
	if !Unlocks.MAGES_UNLOCKED["5"] and win and deck.size() >= 18:
		Unlocks.MAGES_UNLOCKED["5"] = true
		mages.append(ChaosMageFortune.MAGE_NAME)
	if !Unlocks.MAGES_UNLOCKED["6"] and win and Global.DIFFICULTY == 1:
		Unlocks.MAGES_UNLOCKED["6"] = true
		mages.append(FireMageFortune.MAGE_NAME)
	if !Unlocks.MAGES_UNLOCKED["7"] and win and deck.any(func(card: CardData): return card.name == "Dark Rose"):
		Unlocks.MAGES_UNLOCKED["7"] = true
		mages.append("Voidcaster")
	
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
