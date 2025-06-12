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
	status_rtl.append_text(" - Ready - " if state.is_ready else " - Thinking - ")
	balance_rtl.clear()
	
	balance_rtl.append_text(str(100 - state.damage) + " HP")
	if game_type == Enums.MultiplayerGameType.Cooperative and state.is_ready:
		var diff = state.blue_mana - state.blight_attack
		if diff < 0:
			balance_rtl.append_text(", [color=orangered]" + str(0+diff) + Helper.blight_attack_icon())
		elif diff > 0:
			balance_rtl.append_text(", " + str(diff) + Helper.blue_mana())
