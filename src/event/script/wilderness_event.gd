extends CustomEvent

var PickOption = preload("res://src/ui/pick_option.tscn")
var empty_native_seed_fortune = preload("res://src/fortune/unique/native_seed.gd")

func _init():
	super._init("Guardian of the Fields", "This description is blank for now, sorry!")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_options():
	var node1 = FortuneDisplay.instantiate()
	node1.setup(empty_native_seed_fortune.new())
	var is_wilderness = Global.FARM_TYPE == "WILDERNESS"
	
	var message = "Pick one of three Native Seeds to add to your farm" if !is_wilderness else "Pick a second Native Seed for your farm"
	var option1 = CustomEvent.Option.new("Take the offered seed",\
	nodes_preview(message, [node1]), func():
		var cards = []
		cards.assign(StartupHelper.get_wilderness_seed_options())
		if WildernessFarm.WILDERNESS_PLANT != null:
			cards = cards.filter(func(card):
				return card.name != WildernessFarm.WILDERNESS_PLANT.name)
		var pick_option_ui = PickOption.instantiate()
		user_interface.add_child(pick_option_ui)
		var prompt = "Pick the Native Seed"
		var get_cards = func(rerolls: int = 0):
			cards.shuffle()
			return cards.slice(0, 3)
		pick_option_ui.reroll_callable = get_cards
		pick_option_ui.reroll_enabled = true
		pick_option_ui.setup(prompt, get_cards.call(), func(selected):
			var fortune = empty_native_seed_fortune.new()
			fortune.seed = selected
			user_interface._on_explore_on_fortune(fortune)
			user_interface.remove_child(pick_option_ui), func():
				user_interface.remove_child(pick_option_ui))
	)
	
	var options = [option1]
	if is_wilderness:
		var native_seed: CardData = WildernessFarm.WILDERNESS_PLANT
		var card1 = ShopCard.instantiate()
		card1.card_data = native_seed
		var option2 = CustomEvent.Option.new("Enhance the Native Seed", nodes_preview("Add an Enhance to your Native Seed", [card1]), func():
			# Get list of relevant enhances
			var enhances: Array[Enhance] = [load("res://src/enhance/data/plus1yield.tres")]
			if native_seed.can_strengthen_custom_effect():
				enhances.append(load("res://assets/enhance/strength.png"))
			if native_seed.time > 1:
				enhances.append(load("res://src/enhance/data/growspeed.tres"))
			if native_seed.get_effect("plant") == null and native_seed.name != "Dark Rose":
				enhances.append(load("res://src/enhance/data/regrow.tres"))
			if native_seed.size < 9:
				enhances.append(load("res://src/enhance/data/size.tres"))
			
			var pick_option_ui = PickOption.instantiate()
			user_interface.add_child(pick_option_ui)
			var prompt = "Pick an Enhance"
			enhances.shuffle()
			pick_option_ui.setup(prompt, enhances.slice(0, 3), func(selected):
				WildernessFarm.WILDERNESS_PLANT = native_seed.copy().apply_enhance(selected)
				user_interface.remove_child(pick_option_ui), func():
					user_interface.remove_child(pick_option_ui)
		))
		options.append(option2)
	return options

func check_prerequisites():
	return true
