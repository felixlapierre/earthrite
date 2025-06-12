extends CenterContainer
class_name PeerDisplay

@onready var name_label = $HBox/NameLabel
@onready var status_rtl = $HBox/Status
@onready var balance_rtl = $HBox/Balance

func update(state: PlayerState, ready: bool, game_type: Enums.MultiplayerGameType):
	name_label.clear()
	name_label.add_image(load(state.farm_icon))
	name_label.add_image(load(state.mage_icon))
	name_label.add_text(state.name)
	status_rtl.clear()
	status_rtl.add_text("Ready" if ready else ". . .")
	balance_rtl.clear()
	
	balance_rtl.add_text(str(100 - state.damage) + " HP")
	return
	var attack_strength = state.blight_attack
	var blue_mana = state.blue_mana
	if attack_strength > 0.0:
		balance_rtl.add_text(str(attack_strength) + Helper.blight_attack_icon())
	elif blue_mana > 0.0:
		balance_rtl.add_text(str(blue_mana) + Helper.blue_mana())
