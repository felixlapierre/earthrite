extends CustomEvent

var vessel_bound = load("res://src/cards/data/unique/vessel_bound.tres")
var strength = preload("res://src/enhance/data/strength.tres")

func _init():
	super._init("Vessel Stone", "You come across a small abandoned town built around a plaza with a cracked stone fountain. There are no dead; clearly, the residents had time to escape before the Blight spread this far.\n
		A huge cluster of overgrown, pulsing roots prompts you to investigate an abandoned house. As you cut the roots away with magic, raw magical energy bursts out of the house, threatening to vaporize you through your hastily-cast shield spell\n
		Upon further investigation, it seems the Blight has been feeding on a vast source of power buried underneath this home.")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_options():
	var cards: Array[Node] = []
	var card1 = ShopCard.instantiate()
	card1.card_data = vessel_bound
	cards.append(card1)
	
	var display2: Array[Node] = []
	var new_node = ShopDisplay.instantiate()
	new_node.set_data(strength)
	display2.append(new_node)
	
	var option1 = CustomEvent.Option.new("Draw the boundless energy of the Vessel Stone", nodes_preview("Add a Rare enhance to a card in your deck. Add 'Vessel Bound' to your deck", cards), func():
		user_interface.pick_enhance_event("rare")
		user_interface.deck.append(vessel_bound)
	)
	var option2 = CustomEvent.Option.new("Draw a small amount of energy", nodes_preview("Add 'Strength' to a card in your deck", display2), func():
		user_interface.apply_enhance_event(strength)
		)
	var option3 = CustomEvent.Option.new("Leave", text_preview("Leave"), func():
		user_interface.explore.show_window())
	return [option1, option2, option3]

func check_prerequisites():
	return turn_manager.year > 3
