extends Resource
class_name Enhance

const CLASS_NAME = "Enhance"

enum Type {
	Strength,
	Discount,
	Size,
	GrowSpeed,
	Echo,
	Burn,
	Mana,
	Regrow,
	Frozen,
	Spread,
	Springbound,
	RemoveBurn
}


@export var name: String
@export var type: Type
@export var rarity: String
@export var strength: float
# Optional
@export var targets: Array[String]
@export var texture: Texture2D


func _init(p_name = "name", p_rarity = "common", p_strength = 1.0, p_targets = [], p_texture = null, p_type = Type.Strength):
	name = p_name
	rarity = p_rarity
	strength = p_strength
	targets.assign(p_targets)
	texture = p_texture
	type = p_type

func copy():
	var n_targets = []
	for target in targets:
		n_targets.append(target)
	return Enhance.new(name, rarity, strength, n_targets, texture, type)

func is_card_eligible(card: CardData):
	if card.cost == 99:
		return false
	if card.enhances.size() > 1 - Mastery.less_enhance():
		return false
	if card.enhances.any(func(enh): 
			return type == enh.type):
		return false
	match type:
		Type.Size:
			return card.size < 9 and card.size > 0
		Type.Discount:
			return card.cost > 0
		Type.GrowSpeed:
			return card.type == "SEED" and card.time > 1
		Type.Mana, Type.Regrow:
			return card.type == "SEED"
		Type.Spread:
			return !card.has_effect(Enums.EffectType.Spread)and card.type == "SEED"
		Type.Frozen:
			return !card.has_effect(Enums.EffectType.Frozen)
		Type.Springbound:
			return !card.has_effect(Enums.EffectType.Springbound)
		Type.Burn:
			return !card.has_effect(Enums.EffectType.Burn)
		Type.Echo:
			return !card.has_effect(Enums.EffectType.Echo)
		Type.RemoveBurn:
			return card.has_effect(Enums.EffectType.Burn)
		Type.Strength:
			if card.can_strengthen_custom_effect():
				return true
			for effect in card.effects:
				if effect.strength != 0:
					return true
			return false
		_:
			return true

func get_description():
	match type:
		Type.Size:
			return "Increase the size of the area affected by a card" + (" twice" if strength == 2 else "")
		Type.Discount:
			return "Reduce a card's Cost by " + str(strength)
		Type.GrowSpeed:
			return "Make a seed grow " + str(strength) + " week(s) faster"
		Type.Mana:
			return "Increase a seed's " + Helper.mana_icon() + " by " + str(strength)
		Type.Spread:
			return "Give a seed 50% chance to spread on grow" if strength == 0.5 else "Make a seed spread on grow"
		Type.Frozen:
			return "Add Frozen to a card (Card is not discarded at the end of the turn)"
		Type.Springbound:
			return "Add Springbound to a card (Card will always be drawn on the first week of Spring)"
		Type.Burn:
			return "Add Burn to a card (Card is temporarily removed from your deck when played)"
		Type.RemoveBurn:
			return "Remove Burn from a card"
		Type.Strength:
			var text = "Increase the strength of a card's special effects" + (" twice" if strength == 2 else "")
			if rarity == "uncommon" and strength == 2:
				text += ". Increase card's Cost by 1"
			return text
		Type.Regrow:
			return "Add Regrow" + (" and 1 week [img]res://assets/custom/Time.png[/img] of grow time to a card " if strength == 1 else " to a card")
		Type.Echo:
			return "Add Echo to a card (When played, add a non-zero-cost Fleeting copy of the card to your hand)"
		_:
			return "TODO"

func save_data() -> Dictionary:
	var data = {
		"path": get_script().get_path(),
		"name": name,
		"rarity": rarity,
		"strength": strength,
		"targets": targets,
		"texture": texture.resource_path if texture != null else null,
		"type": type
	}
	return data

func load_data(data: Dictionary) -> Enhance:
	name = data.name
	rarity = data.rarity
	strength = data.strength
	targets.assign(data.targets)
	texture = load(data.texture) if data.texture != null else null
	type = data.type
	return self
