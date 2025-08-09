extends Node2D

signal on_close
var CardBase = preload("res://src/cards/card_base.tscn")
var data

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup(load("res://src/cards/data/seed/monstera.tres"))

func setup(card_info):
	var card = CardBase.instantiate()
	card.set_card_info(card_info)
	card.do_passive_effects()
	var scale = Vector2(1.7, 1.7)
	var card_position = Vector2(1920, 1080) / 2 - (Constants.CARD_SIZE / 2)
	card.position = card_position
	card.set_state(Enums.CardState.InShop, card_position, null, scale)
	card.scale = scale
	add_child(card)
	data = card_info
	
	seedVsAction()
	energyCost()
	sizeLabel()
	enhances()
	description()
	mana()
	time()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func seedVsAction():
	$SeedOrAction.clear()
	if data.type == "SEED":
		$SeedOrAction.append_text("This is a Seed card, indicated by the green background. It places seeds on your farm that can be grown and harvested to gain Mana (" + Helper.mana_icon() + ")")
	else:
		$SeedOrAction.append_text("This is an Action card, indicated by the dark orange background. Action cards can have a variety of different effects.")

func energyCost():
	$EnergyCost.clear()
	var text = "[img]res://assets/custom/Energy32.png[/img]: Energy Cost: " + tr("CARD_ENERGY_COST_TOOLTIP").format({"cost": data.cost})
	if data.cost == -1:
		text = "[img]res://assets/custom/Energy32.png[/img] Energy Cost: A cost of X means that this card costs all of your energy to play."
	$EnergyCost.append_text(text)

func sizeLabel():
	$Size.clear()
	var text = "[img]res://assets/custom/SelectTile.png[/img] Size: "
	if data.type == "SEED":
		text += tr("SIZE_TOOLTIP_SEED").format({"size": data.size})
	elif data.type == "ACTION":
		text += tr("SIZE_TOOLTIP_ACTION").format({"size": data.size})
	$Size.append_text(text)

func enhances():
	$Enhances.clear()
	$Enhances.append_text("[img]res://assets/custom/EnhanceChevron.png[/img] Enhances: A card can be enhanced two times. Each filled triangle represents an enhance.\n")
	$Enhances.append_text("This card currently has " + str(data.enhances.size()) + " enhances.")

func description():
	$Description.clear()
	if data.type == "SEED":
		$Description.append_text("Description: Explains the seed's special effects, if it has any.\n")
	else:
		$Description.append_text("Description: Explains the effects of the action card.\n")
	$Description.append_text(data.get_long_description())

func mana():
	$Mana.clear()
	if data.type == "SEED":
		var text = Helper.mana_icon() + ": " + tr("CARD_YIELD_TOOLTIP").format({
			"yield": data.yld,
			"size": data.size,
			"total_yield": data.yld * data.size
		})
		$Mana.append_text(text)

func time():
	$Time.clear()
	if data.type == "SEED":
		var text = Helper.time_icon() + ": " + tr("CARD_DURATION_TOOLTIP").format({
			"duration": data.time
		})
		$Time.append_text(text)


func _on_close_pressed() -> void:
	on_close.emit()
