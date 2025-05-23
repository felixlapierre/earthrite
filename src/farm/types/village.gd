extends FarmType
class_name VillageFarm

static var ID = 7
static var NAME = "VILLAGE"
static var ICON = preload("res://assets/custom/Temp.png")
static var DESCR = "Greatly increase Ritual Target. No Blight Attacks or Hexes.\n\nLose if the ritual is incomplete at the end of Week 12."

var listener_year_start: Listener
var listener_lose: Listener
var listener_mana: Listener

func _init():
	super(ID, NAME, ICON, DESCR)

func register(event_manager: EventManager):
	listener_year_start = Listener.new("village", EventManager.EventType.BeforeYearStart, func(args: EventArgs):
		# Make all tiles yellow
		for tile in args.farm.get_all_tiles():
			tile.purple = false
			tile.update_display()
		
		var bonus = get_bonus(args)

		# Increase ritual terget
		args.turn_manager.total_ritual *= (3 + bonus)
		args.turn_manager.ritual_counter *= (3 + bonus)
		
		# Remove attacks
		args.turn_manager.attack_pattern.unregister_fortunes(event_manager)
		var empty_attack = EmptyAttackPattern.new()
		args.turn_manager.register_attack_pattern(empty_attack)
		args.turn_manager.blight_pattern = empty_attack.blight_pattern
		args.user_interface.AttackPreview.visible = false
		args.user_interface.update()
		)
	
	listener_lose = Listener.new("village2", EventManager.EventType.OnTurnEnd, func(args: EventArgs):
		if args.turn_manager.week >= Global.FINAL_WEEK - 1:
			args.turn_manager.blight_damage = Global.MAX_HEALTH
		)
		
	listener_mana = Listener.new("village3", EventManager.EventType.OnManaGained, func(args: EventArgs):
		args.specific.harvest_args.purple = false
		)

	event_manager.register(listener_year_start)
	event_manager.register(listener_lose)
	event_manager.register(listener_mana)

func unregister(event_manager: EventManager):
	event_manager.user_interface.AttackPreview.visible = true
	listener_year_start.disable()
	listener_lose.disable()
	listener_mana.disable()

func get_bonus(args: EventArgs):
	var bonus = 0
	if Global.DIFFICULTY >= 2:
		bonus = 1.0
	elif Global.DIFFICULTY >= 5:
		bonus = 2.0
	elif Global.DIFFICULTY >= 7:
		bonus = 3.0
	
	if args.turn_manager.year < 7:
		bonus /= 2
	if args.turn_manager.year < 4:
		bonus = 0
	return bonus
