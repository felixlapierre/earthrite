extends Resource

class_name CardData

const CLASS_NAME = "CardData"

@export var type: String
@export var name: String
@export var rarity: String
@export var cost: int
@export var yld: int
@export var time: int
@export var size: int
@export_multiline var text: String
@export var strength_increment: float = 1.0
@export var size_increment: int = 1
@export var texture: Texture2D
@export var seed_texture: int
@export var texture_icon_offset: int = 16
@export var targets: Array[String]
@export var effects: Array[Effect]
@export var enhances: Array[Dictionary]
@export var strength: float

@export var animation: SpriteFrames
@export var delay: float
@export var anim_on: Enums.AnimOn
@export var effects2: Array[Effect2]

var card_listeners: Array[Listener]

func _init(p_type = "ACTION", p_name = "PlaceholderCardName", p_rarity = "common", p_cost = 1, p_yld = 1,\
	p_time = 1, p_size = 1, p_text = "", p_texture = null, p_seed_texture = 1, p_targets = [], p_effects = [],\
	p_strength_increment = 1.0, p_size_increment = 1, p_text_icon_offset = 16, p_enhances = [], p_strength = 0, p_animation = null, p_delay = 0.0, p_anim_on = Enums.AnimOn.Mouse, p_effects_2 = []):
		type = p_type
		name = p_name
		rarity = p_rarity
		cost = p_cost
		yld = p_yld
		time = p_time
		size = p_size
		text = p_text
		texture = p_texture
		seed_texture = p_seed_texture
		targets.assign(p_targets)
		effects.assign(p_effects)
		enhances.assign(p_enhances)
		strength_increment = p_strength_increment
		size_increment = p_size_increment
		texture_icon_offset = p_text_icon_offset
		strength = p_strength
		animation = p_animation
		delay = p_delay
		anim_on = p_anim_on
		effects2.assign(p_effects_2)
		card_listeners = []

func get_effect(effect_name):
	for effect in effects:
		if effect.name == effect_name:
			return effect
	return null

func has_effect(type: Enums.EffectType):
	for effect in effects2:
		if effect.get_type() == type:
			return true
	return false

func copy() -> CardData:
	var new = CardData.new()
	new.assign(self)
	return new

func assign(other: CardData) -> void:
	type = other.type
	name = other.name
	rarity = other.rarity
	cost = other.cost
	yld = other.yld
	time = other.time
	size = other.size
	text = other.text
	texture = other.texture
	seed_texture = other.seed_texture
	for target in other.targets:
		targets.append(target)
	for effect in other.effects:
		effects.append(effect.copy())
	for enhance in other.enhances:
		enhances.append(enhance)
	strength_increment = other.strength_increment
	size_increment = other.size_increment
	texture_icon_offset = other.texture_icon_offset
	strength = other.strength
	animation = other.animation
	delay = other.delay
	anim_on = other.anim_on
	for effect2 in other.effects2:
		effects2.append(effect2.copy())

func apply_enhance(enhance: Enhance):
	var n_card = copy()
	match enhance.type:
		Enhance.Type.Discount:
			n_card.cost = max(cost - int(enhance.strength), 0)
		Enhance.Type.GrowSpeed:
			n_card.time = (time - int(enhance.strength)) if time > int(enhance.strength) else 1
			if n_card.time < 1:
				n_card.time = 1
		Enhance.Type.Mana:
			n_card.yld += int(enhance.strength)
		Enhance.Type.Spread:
			n_card.effects2.append(load("res://src/effect2/basic/data/spread_grow_rare.tres"))
		Enhance.Type.Burn:
			n_card.effects2.append(load("res://src/effect2/basic/data/burn_effect.tres"))
		Enhance.Type.Frozen:
			n_card.effects2.append(load("res://src/effect2/basic/data/frozen_effect.tres"))
		Enhance.Type.Echo:
			n_card.effects2.append(load("res://src/effect2/basic/data/echo_effect.tres"))
		Enhance.Type.Burn:
			n_card.effects2.erase(load("res://src/effect2/basic/data/burn_effect.tres"))
		Enhance.Type.Strength:
			n_card.apply_strength(enhance)
		Enhance.Type.Size:
			n_card.size += enhance.strength * size_increment
			if n_card.size > 9:
				n_card.size = 9
		Enhance.Type.Springbound:
			n_card.effects2.append(load("res://src/effect2/basic/data/springbound_effect.tres"))
		Enhance.Type.Regrow:
			for effect in n_card.effects2:
				if effect.effect_type == Enums.EffectType.Regrow:
					effect.strength += enhance.strength
					n_card.enhances.append({
						"name": enhance.name,
						"type": enhance.type
						})
					return n_card
			n_card.effects.append(load("res://src/effect/data/regrow_0.tres"))
			if enhance.strength == 1:
				n_card.time += 1
	if !n_card.has_enhance_type(enhance.type):
		n_card.enhances.append({
			"name": enhance.name,
			"type": enhance.type
		})
	return n_card

func apply_strength(enhance: Enhance):
	var done = false
	for effect in effects2:
		if effect.can_strengthen():
			if effect.strength >= 0.0:
				effect.strength += enhance.strength * effect.strength_increment
			elif effect.strength < 0.0:
				effect.strength -= enhance.strength * effect.strength_increment
			done = true
			break
	if !done and can_strengthen_custom_effect():
		strength += enhance.strength * strength_increment
		done = true
	if !done:
		for effect in effects:
			if effect.strength > 0.0:
				effect.strength += enhance.strength * strength_increment
				break
			elif effect.strength < 0.0:
				effect.strength -= enhance.strength * strength_increment
				break
	if enhance.strength > 1.0 and enhance.rarity == "uncommon":
		cost += 1
	return self

func get_description() -> String:
	var descr: String = text
	for effect in effects2:
		var highlight = highlight_effect(effect)
		var effect_text = effect.get_description(size)
		if effect_text.length() > 0:
			if descr.length() > 0:
				descr += ". "
			if highlight:
				effect_text = "[color=aqua]" + effect_text.replace("[color=gold]", "").replace("[/color]", "") + "[/color]"
			descr += effect_text
	
	if has_enhance_type(Enhance.Type.Strength):
		descr = descr.replace("{STRENGTH}", "[color=aqua]" + str(strength) + "[/color]")
		descr = descr.replace("{STR_PER}", "[color=aqua]" + str(self.strength * 100) + "[/color]")
	else:
		descr = descr.replace("{STRENGTH}", str(strength))
		descr = descr.replace("{STR_PER}", str(self.strength * 100))
	return descr.replace("{MANA}", Helper.mana_icon())\
		.replace("{BLUE_MANA}", Helper.blue_mana())\
		.replace("{ENERGY}", Helper.energy_icon())\
		.replace("{TIME}", Helper.time_icon())

# To be overridden by specific code seeds
func register_events(event_manager: EventManager, tile: Tile):
	for eff in effects2:
		eff.owner = self
		eff.register_events(event_manager, tile)

func unregister_events(event_manager: EventManager):
	for eff in effects2:
		eff.unregister_events(event_manager)

func register_seed_events(event_manager: EventManager, tile: Tile):
	for eff in effects2:
		eff.owner = self
		eff.register_seed_events(event_manager, tile)

func unregister_seed_events(event_manager: EventManager):
	for eff in effects2:
		eff.unregister_seed_events(event_manager)

func get_yield(tile: Tile) -> EventArgs.HarvestArgs:
	var yld = tile.current_yield
	yld = round(yld)
	return EventArgs.HarvestArgs.new(yld, tile.purple, false, 0, self)

func save_data() -> Dictionary:
	var save_dict = {
		"path": get_script().get_path(),
		"type": type,
		"name": name,
		"rarity": rarity,
		"cost": cost,
		"yld": yld,
		"time": time,
		"size": size,
		"text": text,
		"texture": texture.resource_path if texture != null else null,
		"seed_texture": seed_texture,
		"targets": targets,
		"effects": effects.map(func(effect):
			return effect.save_data()),
		"effects2": effects2.map(func(effect):
			return effect.save_data()),
		"strength_increment": strength_increment,
		"size_increment": size_increment,
		"texture_icon_offset": texture_icon_offset,
		"enhances": enhances,
		"strength": strength,
		"animation": animation.resource_path if animation != null else null,
		"delay": delay,
		"anim_on": anim_on
	}
	return save_dict

func load_data(data) -> CardData:
	type = data.type
	name = data.name
	rarity = data.rarity
	cost = data.cost
	yld = data.yld
	time = data.time
	size = data.size
	text = data.text
	texture = load(data.texture) if data.texture != null else null
	seed_texture = data.seed_texture
	targets.assign(data.targets)
	effects.assign(data.effects.map(func(effect):
		var eff = load(effect.path).new()
		eff.load_data(effect)
		return eff))
	effects2.assign(data.effects2.map(func(effect):
		var eff = load(effect.path).new()
		eff.load_data(effect)
		return eff))
	enhances.assign(data.enhances)
	strength_increment = data.strength_increment
	size_increment = data.size_increment
	texture_icon_offset = data.texture_icon_offset
	strength = data.strength
	animation = load(data.animation) if data.animation != null else null
	delay = data.delay
	anim_on = data.anim_on
	return self

# Override with true in subclasses that use the strength member variable
func can_strengthen_custom_effect():
	for effect in effects2:
		if effect.can_strengthen():
			return true
	return false

func preview_yield(tile: Tile):
	var args = EventArgs.HarvestArgs.new(0, tile.purple, false);
	if !tile.card_can_target(self):
		return args
	for eff in effects2:
		eff.preview_yield(tile, args)
	args.yld = round(args.yld)
	args.green = round(args.green)
	return args

func get_long_description():
	var description_tooltip = ""
	for effect in effects:
		if description_tooltip.length() > 0:
			description_tooltip += "\n"
		description_tooltip += effect.get_long_description()
	for effect: Effect2 in effects2:
		var descr = effect.get_long_description()
		if description_tooltip != descr:
			if description_tooltip.length() > 0:
				description_tooltip += "\n"
			description_tooltip += descr
	return description_tooltip

func on_card_drawn(args: EventArgs):
	pass
	
func highlight_effect(effect: Effect2):
	return has_enhance_type(Enhance.Type.Regrow) and effect.effect_type == Enums.EffectType.Regrow\
		or has_enhance_type(Enhance.Type.Echo) and effect.effect_type == Enums.EffectType.Echo\
		or has_enhance_type(Enhance.Type.Spread) and effect.effect_type == Enums.EffectType.Spread\
		or has_enhance_type(Enhance.Type.Frozen) and effect.effect_type == Enums.EffectType.Frozen\
		or has_enhance_type(Enhance.Type.Burn) and effect.effect_type == Enums.EffectType.Burn\
		or has_enhance_type(Enhance.Type.Springbound) and effect.effect_type == Enums.EffectType.Springbound

func has_enhance_type(type: Enhance.Type):
	return enhances.any(func(enh):
		return enh.type == type)
		
func register(listener: Listener):
	listener.id = name + listener.id
	card_listeners.append(listener)

func notify(event_manager: EventManager, type: EventManager.EventType, specific_args: EventArgs.SpecificArgs = null):
	var args = event_manager.get_event_args(specific_args)
	for listener in card_listeners:
		if listener.type == type and !event_manager.turn_manager.is_ritual_complete():
			await listener.invoke(args)
