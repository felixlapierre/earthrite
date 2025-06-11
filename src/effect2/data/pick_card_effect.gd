extends StrEffect
class_name PickCardEffect

var PickOption = preload("res://src/ui/pick_option.tscn")
var SelectCard = preload("res://src/cards/select_card.tscn")
var strength_enhance = load("res://src/enhance/data/strength.tres")

enum PickFrom {
	Hand,
	Discard,
	Burned,
	RandomSeed,
	Blight,
	HandCost1,
	HandCanStrengthen,
	Wish
}

enum AndThen {
	Draw,
	Burn,
	Use,
	Strengthen
}

@export var timing: EventManager.EventType:
	set(value): event_type = value
@export var seed: bool:
	set(value): is_seed = value
@export var timing2: EventManager.EventType
@export var count: int
@export var pick_from: PickFrom
@export var and_then: AndThen
@export var skippable: bool

var card: CardData = null

var tile: Tile = null

var listener_play: Listener
var listener_andthen: Listener

static var wish_index = 0
static var wish_options_list = []

# An effect involving picking cards
# Pick 
# * any card if count == -1
# * 1 of (count + strength) cards if count != -1
# From (pick_from)
# * hand or discard pile or burned cards or random seeds or blight cards
# And Then (and_then)
# * Draw (1 + strength) copies if count == -1
# * Burn the card
# * Immediately play the card
# Can only be strengthened if and_then==draw
# timing1 is the timing on which you pick the card which is AfterCardPlayed unless it's a seed where the effect scales which size then -> OnActionCardUsed
# timing2 is the timing on which the and_then occurs
# Should pretty much either be OnPlantHarvest (for seed effect like iris)
# or AfterCardPlayed for immediate effect (burn, add card to hand)

func _init(p_timing_2 = EventManager.EventType.AfterCardPlayed, p_count = -1, p_pick_from = PickFrom.Hand,
	p_and_then = AndThen.Draw, p_skippable = false):
	super(timing, seed, Enums.EffectType.Other, "PickCardEffect")
	
	timing2 = p_timing_2
	count = p_count
	pick_from = p_pick_from
	and_then = p_and_then

func register(event_manager: EventManager, p_tile: Tile):
	tile = p_tile
	listener_play = Listener.create(self, func(args: EventArgs):
		await pick_card_event(args))
	
	listener_andthen = Listener.new(timing2, func(args: EventArgs):
		# If timing2 is Plant Harvest, it must not trigger when other plants are harvested
		if timing2 != EventManager.EventType.OnPlantHarvest or args.specific.tile == tile:
			await do_followup_action(args))

	owner.register(listener_play)
	
	# As an exception the AfterCardPlayed trigger is done immediately
	# after timing1 function is executed
	if timing2 != EventManager.EventType.AfterCardPlayed:
		event_manager.register(listener_andthen)

func pick_card_event(args: EventArgs):
	if card != null:
		return
	var options = []
	match pick_from:
		PickFrom.Hand:
			options.assign(args.cards.get_hand_info())
		PickFrom.HandCost1:
			options.assign(args.cards.get_hand_info().filter(func(card_data):
				return card_data.cost <= strength))
		PickFrom.Discard:
			options.assign(args.cards.discard_pile_cards)
		PickFrom.Burned:
			pass
		PickFrom.RandomSeed:
			options.assign(pick_from_random_seed())
		PickFrom.Blight:
			options.assign(DataFetcher.get_element_cards("blight"))
		PickFrom.HandCanStrengthen:
			options.assign(args.cards.get_hand_info().filter(func(card_data: CardData):
				if card_data.can_strengthen_custom_effect():
					return true
				for effect in card_data.effects:
					if effect.strength != 0:
						return true
				return false))
		PickFrom.Wish:
			options.assign(get_wish_options())
	if count != -1:
		options.shuffle()
	Global.LOCK = true
	await display_options(args, options, func(card_data):
		Global.LOCK = false
		card = card_data
		if event_type == EventManager.EventType.OnActionCardUsed:
			args.specific.tile.play_effect_particles()
		if timing2 == EventManager.EventType.AfterCardPlayed:
			await do_followup_action(args))

func pick_from_random_seed():
	var cards = DataFetcher.get_all_cards()
	var candidates = []
	for card in cards:
		if card.type == "SEED" and card.rarity != "basic" and card.rarity != "unique" and card.rarity != "legendary":
			candidates.append(card)
	return candidates

func display_options(args: EventArgs, options: Array, set_card: Callable):
	if options.size() == 0:
		set_card.call(load("res://src/cards/data/unique/void.tres"))
		return
	if count > 0:
		options = options.slice(0, count + strength)
	if options.size() == 1 and !skippable and pick_from == PickFrom.Hand:
		set_card.call(options[0])
	else:
		var pick_option_ui = PickOption.instantiate()
		args.user_interface.add_child(pick_option_ui)
		var prompt = "Pick a card (%s)" % owner.name
		var cancel_callback = null if !skippable else func():
			args.user_interface.remove_child(pick_option_ui)
			set_card.call(null)

		pick_option_ui.setup(prompt, options, func(selected):
			await set_card.call(selected)
			args.user_interface.remove_child(pick_option_ui), cancel_callback)
		await pick_option_ui.pick_finished

func do_followup_action(args: EventArgs):
	if card == null:
		return
	if and_then == AndThen.Burn:
		args.cards.remove_card_with_info(card)
		args.cards.notify_card_burned(card)
		card = null
	elif and_then == AndThen.Draw:
		for i in range(strength if count == -1 else 1):
			args.cards.draw_specific_card_from(card, args.user_interface.get_global_mouse_position())
	elif and_then == AndThen.Use:
		Global.selected_card = card
		await args.farm.use_card(tile.grid_location, true)
		Global.selected_card = null
	elif and_then == AndThen.Strengthen:
		var str_enhance = Enhance.new("strength", "common", strength)
		var copy: CardData = card.apply_enhance(str_enhance)
		for hand_card: CardBase in args.cards.HAND_CARDS.get_children():
			if hand_card.card_info == card:
				hand_card.set_card_info(copy)

func unregister(event_manager: EventManager):
	listener_play.disable()
	listener_andthen.disable()

func get_description(size: int):
	var descr = ""
	if card == null:
		descr += get_timing_text(event_type) + get_pick_from_description() + get_and_then_description()
	else:
		descr += get_and_then_description()
	return get_description_interp(descr)

func get_pick_from_description():
	var count_text = ""
	if count == -1:
		count_text = " a card "
	elif strength > base_strength:
		count_text = " 1 of [color=aqua]" + str(count + strength) + "[/color] cards"
	else:
		count_text = " 1 of " + str(count) + " cards"

	match pick_from:
		PickFrom.Hand, PickFrom.HandCanStrengthen:
			return "Pick" + count_text + "from your hand"
		PickFrom.HandCost1:
			return "Pick" + count_text.replace("card", ("[color=aqua]" if strength > 1 else "")\
			+ str(strength) + "-cost" + ("[/color]" if strength > 1 else "") + " card")\
			 + "from your hand"
		PickFrom.Discard:
			return "Pick" + count_text + "from your discard pile"
		PickFrom.Burned:
			return "Pick" + count_text + "from those burned this year"
		PickFrom.RandomSeed:
			return ("Pick" + count_text).replace("cards", "random Seed cards")
		PickFrom.Blight:
			return "Pick" + count_text + "Blight cards"
		PickFrom.Wish:
			return ""
		_:
			return "card"

func get_and_then_description():
	if pick_from == PickFrom.Wish:
		return ""
	var count_text = ""
	if count == -1 and strength > 1:
		count_text = " [color=aqua]" + str(strength) + " copies[/color] "
		if card != null:
			count_text += "of " + card.name + " "
	elif card == null:
		count_text = " a copy "
	else:
		count_text = " " + card.name + " "
	match and_then:
		AndThen.Draw:
			if timing2 == EventManager.EventType.AfterCardPlayed:
				return " and add" + count_text + "to your hand"
			else:
				return (". " if card == null else "") + get_timing_text(timing2) + "Add" + count_text + "to your hand"
		AndThen.Burn:
			return " and [color=gold]Burn[/color] it"
		AndThen.Use:
			return (". " if card == null else "") + get_timing_text(timing2) + "Cast " + ("it" if card == null else card.name) + " on this plant"
		AndThen.Strengthen:
			return " and increase its Strength by " + highlight(str(strength))

func copy():
	var copy = PickCardEffect.new()
	copy.assign(self)
	return copy

func save_data() -> Dictionary:
	var save_dict = super.save_data()
	save_dict["count"] = count
	save_dict["pick_from"] = pick_from
	save_dict["and_then"] = and_then
	save_dict["skippable"] = skippable
	save_dict["timing2"] = timing2
	return save_dict

func load_data(data) -> Effect2:
	super.load_data(data)
	count = data.count
	pick_from = data.pick_from
	and_then = data.and_then
	skippable = data.skippable
	timing2 = data.timing2
	return self

func assign(other):
	super.assign(other)
	count = other.count
	pick_from = other.pick_from
	and_then = other.and_then
	skippable = other.skippable
	timing2 = other.timing2
	card = other.card
	return self

func can_strengthen():
	return and_then == AndThen.Draw or pick_from == PickFrom.HandCost1 or and_then == AndThen.Strengthen

func get_long_description():
	if and_then == AndThen.Burn:
		return Helper.get_long_description("burn")
	elif pick_from == PickFrom.Wish:
		return "[color=gold]Wish[/color]: One of 9 powerful effects."
	return ""

func get_wish_options():
	if wish_options_list.size() == 0:
		var timehop: CardData = load("res://src/cards/data/action/time_hop.tres").copy()
		timehop.effects2[0].strength = 2
		timehop.name = "Time"
		wish_options_list.append(timehop)
		var windrite: CardData = load("res://src/cards/data/action/windrite.tres").copy()
		windrite.name = "Wind"
		wish_options_list.append(windrite)
		var invigorate: CardData = load("res://src/cards/data/action/invigorate.tres").copy()
		invigorate.name = "Nature"
		invigorate.effects2[0].strength = 3
		wish_options_list.append(invigorate)
		var wildflowers: CardData = load("res://src/fortune/unique/wildflower.tres").copy()
		wildflowers.name = "Life"
		wildflowers.size = -1
		wildflowers.text = "Fill your farm with Wildflowers"
		wish_options_list.append(wildflowers)
		var protect: CardData = load("res://src/cards/data/action/shelter.tres").copy()
		protect.size = -1
		protect.name = "Abjuration"
		wish_options_list.append(protect)
		var draw: CardData = CardData.new()
		draw.texture = load("res://assets/card/inspiration.png")
		draw.name = "Knowledge"
		draw.effects2.append(DrawCardEffect.new())
		draw.effects2[0].strength = 10
		draw.effects2[0].event_type = EventManager.EventType.AfterCardPlayed
		wish_options_list.append(draw)
		var energy: CardData = CardData.new()
		energy.texture = load("res://assets/card/catalyze.png")
		energy.name = "Lightning"
		energy.effects2.append(GainEnergyEffect.new())
		energy.effects2[0].event_type = EventManager.EventType.AfterCardPlayed
		energy.effects2[0].strength = 5
		wish_options_list.append(energy)
		var yellow_mana: CardData = CardData.new()
		yellow_mana.texture = load("res://assets/custom/YellowMana.png")
		yellow_mana.name = "Sun"
		yellow_mana.effects2.append(GainManaEffect.new())
		yellow_mana.effects2[0].strength = 150
		wish_options_list.append(yellow_mana)
		var purple_mana: CardData = CardData.new()
		purple_mana.texture = load("res://assets/custom/PurpleMana.png")
		purple_mana.name = "Moon"
		purple_mana.effects2.append(GainManaEffect.new())
		purple_mana.effects2[0].strength = 200
		purple_mana.effects2[0].purple = true
		wish_options_list.append(purple_mana)
		for opt in wish_options_list:
			opt.cost = 99
			if opt.size != -1:
				opt.size = 0
			if opt.effects2.size() > 0 and opt.effects2[0] is StrEffect:
				opt.effects2[0].base_strength = opt.effects2[0].strength
		wish_options_list.shuffle()
	if wish_index >= 9:
		wish_index = 0
		wish_options_list.shuffle()
	var result = wish_options_list.slice(wish_index, wish_index + 3)
	wish_index += 3
	return result
