extends CustomEvent

var options

func _init():
	super._init("The Spire", "You find an area of woods where the Blight's creeping roots stop, as though abutting against an invisible wall. Curious, you venter into this untouched space.\n
		Immediately, your skin crawls and your hair stands on edge. The plants here grow in erratic, zig-zagging patterns that make no sense. Clouds of deformed insects buzz chaotically around your head, and everything spins.\n
		At the center of it all, a huge chunk of stone with faint bluish spiral patterns sits in the center of a clearing. Chaos magic radiates outwards like the deadly heat of a bonfire.")
	
	var option1 = CustomEvent.Option.new("Leave, before this place can affect you further",\
	OptionPreview.instantiate().text_preview("Choose a card from your deck to Transform into a random card"), func():
		user_interface.pick_card_from_deck_event("Choose a card to Transform into a random card", func(card_data):
			user_interface.deck.erase(card_data)
			var new_card = cards_database.get_random_cards(null, 1)
			user_interface.deck.append_array(new_card)))
	
	var option3 = CustomEvent.Option.new("Stay a bit longer and search for something useful",\
	OptionPreview.instantiate().text_preview("Transform a random card in your Deck. Choose a Blessing"), func():
			var index = randi() % user_interface.deck.size()
			user_interface.deck.remove_at(index)
			var new_card = cards_database.get_random_cards(null, 1)
			user_interface.deck.append_array(new_card)
			user_interface.pick_blessing("Pick a blessing to gain", []))

	var option2 = CustomEvent.Option.new("Give in to the chaos",\
	OptionPreview.instantiate().text_preview("Transform all [color=aqua]non-enhanced[/color] cards in your deck into random cards.\nSeed cards will be transformed into Seed cards, Cards that Harvest will be transformed into other cards that Harvest, and Action cards will be transformed into Action cards."), func(): 
		ChaosMageFortune.randomize_deck(user_interface.deck))

	options = [option1, option3, option2]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_options():
	return options

func check_prerequisites():
	return turn_manager.year > 3
