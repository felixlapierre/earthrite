extends Node
class_name PlayerState

var id: int

var farm_icon: String
var mage_icon: String

var ritual_counter: float = 0.0
var ritual_target: float = 0.0
var blue_mana: float = 0.0
var blight_attack: float = 0.0
var damage: int = 0
var target: int = -1

var alive: bool = true
var active: bool = false
var victory: bool = false
var defeat: bool = false
var winner: bool = false
var lives: int = 0

static var property_list = ["id", "name", "farm_icon", "mage_icon", "ritual_counter", "ritual_target", "blue_mana", "blight_attack", "damage", "target", "alive", "active", "lives", "victory", "defeat", "winner"]

func _init(p_name, p_id, p_farm_icon, p_mage_icon):
	name = p_name
	id = p_id
	farm_icon = p_farm_icon
	mage_icon = p_mage_icon

func encode():
	var result = {}
	for property in property_list:
		result[property] = self[property]
	return result

static func decode(data) -> PlayerState:
	var decoded = PlayerState.new(data.name, data.id, data.farm_icon, data.mage_icon)
	for property in property_list:
		decoded[property] = data[property]
	return decoded
	
func copy() -> PlayerState:
	var other = PlayerState.new(name, id, farm_icon, mage_icon)
	for property in property_list:
		other[property] = self[property]
	return other
