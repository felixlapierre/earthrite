extends MageAbility
class_name BlightMageFortune

var icon = preload("res://assets/card/corruption.png")
static var MAGE_NAME = "Blight-Touched"
static var MAGE_ID = 7

var listener: Listener

func _init() -> void:
	super(MAGE_NAME, Fortune.FortuneType.GoodFortune, "Start with 30 blight damage.Blight cards appear in card rewards.\n\nAt the start of each year, add a [color=gold]Fleeting[/color] copy of 'Shadowbind' to your hand.\n\n[color=gold]Unlock: [/color]Win after accepting the Blight offering", MAGE_ID, icon, 1.0)
	#modify_deck_callback = func(deck):
	#	deck.append(load("res://src/cards/data/unique/shadowbind.tres"))

func register_fortune(event_manager: EventManager):
	super.register_fortune(event_manager)
	
	listener = Listener.new(EventManager.EventType.AfterYearStart, func(args: EventArgs):
		args.cards.draw_specific_card(load("res://src/cards/data/unique/shadowbind.tres")))
	event_manager.register(listener)
	if strength >= 2.0:
		Global.MAX_BLIGHT += 1
		Global.MAX_HEALTH += 20
	if event_manager.turn_manager.blight_damage == 0:
		event_manager.turn_manager.blight_damage = 30
	update_text()

func unregister_fortune(event_manager: EventManager):
	listener.disable()
	
func upgrade_power():
	strength += 1.0
	update_text()
	Global.MAX_BLIGHT += 1

func update_text():
	if strength >= 2.0:
		text = "Start with 20 blight damage and 1 copy of 'Blightrose' in your deck. Gain +20 max health. Blight cards appear in card rewards."
	else:
		text = "Start with 20 blight damage and 1 copy of 'Blightrose' in your deck. Blight cards appear in card rewards."
