extends CustomEvent

var options

func _init():
	super._init("Great City of Deviro", \
	"As your struggle agains the Blight grows more difficult, you attempt a divination to locate any sources of power that might help make you stronger. Your scrying leads you to a ruined, overgrown city in the heart of the forest.\n
	At the center of the city is a huge pyramid. Nestled at its peak is a complex mechanism of gears, metal, mirrors and gemstones. Once, this was used to help mage circles cast powerful spells. Now, most of its parts have been pilfered and stolen.\n
	There remain a handful of gemstones left untouched in the array. You can faintly feel remnants of elemental energy emanating from each one.")
	
	var option1 = CustomEvent.Option.new("Consume the Opal gemstone",\
		OptionPreview.instantiate().text_preview("Add a 'Knowledge' spell to your deck. Knowledge spells are cards that draw cards or manipulate your hand of cards."),\
		pick_element_cards_function("Knowledge"))
	
	var option2 = CustomEvent.Option.new("Consume the Quartz gemstone",\
		OptionPreview.instantiate().text_preview("Add a 'Wind' spell to your deck. Wind spells are cards that harvest plants"),\
		pick_element_cards_function("Wind"))
	
	var option3 = CustomEvent.Option.new("Consume the Tourmaline gemstone",\
		OptionPreview.instantiate().text_preview("Add a 'Time' spell to your deck. Time spells are cards that grow plants"),\
		pick_element_cards_function("Time"))
	
	var option4 = CustomEvent.Option.new("Consume the Sapphire gemstone",\
		OptionPreview.instantiate().text_preview("Add a 'Water' spell to your deck. Water spells are cards that water tiles or interact with watered tiles in some way."), \
		pick_element_cards_function("Water"))
	
	var option5 = CustomEvent.Option.new("Consume the Emerald gemstone",\
		OptionPreview.instantiate().text_preview("Add a 'Nature' spell to your deck. Nature spells are cards that manipulate seeds by planting them, spreading them, or adding mana to them."), \
		pick_element_cards_function("Nature"))

	var option6 = CustomEvent.Option.new("Consume the Ruby gemstone",\
		OptionPreview.instantiate().text_preview("Add a 'Fire' spell to your deck. Fire spells relate to Burning cards from your hand and deck."), \
		pick_element_cards_function("Fire"))

	var option7 = CustomEvent.Option.new("Consume the Topaz gemstone.",\
		OptionPreview.instantiate().text_preview("Add a 'Lightning' spell to your deck. Lightning spells relate to gaining and spending Energy."), \
		pick_element_cards_function("Lightning"))
		
	var option8 = CustomEvent.Option.new("Consume the Onyx gemstone.",\
		OptionPreview.instantiate().text_preview("Add an 'Earth' spell to your deck. Earth spells relate to empty or destroyed tiles."), \
		pick_element_cards_function("Earth"))
	
	var opts = [option1, option2, option3, option4, option5, option6, option7, option8]
	opts.shuffle()
	options = opts.slice(0, 3)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_options():
	return options

func pick_element_cards_function(element: String):
	return func():
		var cards: Array = cards_database.get_element_cards(element)
		cards = cards.filter(func(card):
			return Global.FARM_TYPE != "WILDERNESS" or card.type == "ACTION")
		cards.shuffle()
		user_interface.pick_cards_event(cards.slice(0, 3))

func check_prerequisites():
	return true
