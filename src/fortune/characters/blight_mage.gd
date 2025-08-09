extends MageAbility
class_name BlightMageFortune

var icon = preload("res://assets/card/corruption.png")
static var MAGE_NAME = "Blight-Touched"
static var MAGE_ID = 7

var blight_mage_descr = "Start with 30 blight damage.\n\nAt the start of each year, add a [color=gold]Fleeting[/color] copy of 'Shadowbind' to your hand.\n\n[color=gold]Unlock: [/color]Win using a [color=violet]Dark Power[/color] card."

var listener: Listener

func _init() -> void:
	super(MAGE_NAME, Fortune.FortuneType.GoodFortune, blight_mage_descr, MAGE_ID, icon, 1.0)
	#modify_deck_callback = func(deck):
	#	deck.append(load("res://src/cards/data/unique/shadowbind.tres"))

func register_fortune(event_manager: EventManager):
	super.register_fortune(event_manager)
	
	listener = Listener.new(EventManager.EventType.AfterYearStart, func(args: EventArgs):
		args.cards.draw_specific_card(load("res://src/cards/data/unique/shadowbind.tres")))
	event_manager.register(listener)
	TurnManager.bonus_dark_power += 1 if strength >= 2.0 else 0
	if event_manager.turn_manager.blight_damage == 0:
		event_manager.turn_manager.blight_damage = 30
		TurnManager.blight_damage_static = 30
	update_text()

func unregister_fortune(event_manager: EventManager):
	TurnManager.bonus_dark_power -= 1 if strength >= 2.0 else 0
	listener.disable()
	
func upgrade_power():
	strength += 1.0
	update_text()
	TurnManager.bonus_dark_power += 1

func update_text():
	if strength >= 2.0:
		text = "At the start of each year, add a [color=gold]Fleeting[/color] copy of 'Shadowbind' to your hand.\n\nYou have +1 [color=violet]Dark Power[/color]"
	else:
		text = "At the start of each year, add a [color=gold]Fleeting[/color] copy of 'Shadowbind' to your hand."
