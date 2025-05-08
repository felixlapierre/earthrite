extends Node
class_name AttackDatabase

var add_10_weeds = AddWeeds.new(10)
var add_blightroot = AddBlightroot.new(1)
var add_deathcap = AddDeathcap.new(1)
var burn_rightmost = EndTurnBurn.new()
var weeds_entire_farm = WeedsEntireFarm.new()
var weeds_every_card = WeedsEveryCard.new(1)
var weeds_2_every_card = WeedsEveryCard.new(2)

var add_corpse_flower = AddCorpseFlower.new(1)

var destroy_one_plant = DestroyPlants.new(1)
var destroy_two_plants = DestroyPlants.new(2)
var destroy_plant_every_card = DestroyPlantOnCard.new(1)
var destroy_one_tile = DestroyTiles.new(1)
var destroy_two_tiles = DestroyTiles.new(2)

var destroy_row = DestroyRow.new()
var destroy_col = DestroyCol.new()

#var end_turn_swap = EndTurnSwapColors.new()
#var end_turn_rotate = EndTurnRotateColors.new()
#var end_turn_randomize = EndTurnRandomizeColors.new()

var increase_ritual_10 = IncreaseRitualTarget.new(10.0)
var block_ritual = BlockRitual.new(1.0)
var cold_snap = ColdSnap.new()
var counter3 = Counter.new(3)
var counter5 = Counter.new(5)

var two_dark_thorns = AddDarkThornsDeck.new(2)
var two_blood_thorns = AddBloodThornsDeck.new(2)
var one_dark_thorn = AddDarkThornsDeck.new(1)
var one_blood_thorn = AddBloodThornsDeck.new(1)

# Store first by difficulty then week, then a list of AttackPattern
var database: Dictionary = {}

func simple_every(fortune: Fortune) -> SimpleAttackBuilder:
	return SimpleAttackBuilder.new().fortune_every_turn(fortune)

func simple_every_list(fortunes: Array[Fortune]) -> SimpleAttackBuilder:
	var builder = SimpleAttackBuilder.new()
	for fortune in fortunes:
		builder.fortune_every_turn(fortune)
	return builder

func get_attacks(difficulty: String, week: int) -> Array[AttackPattern]:
	var result: Array[AttackPattern] = []
	var diff = database.get(difficulty)
	var options = diff.get(week + 1)
	if !diff.has(week + 1):
		options = diff.get(8)
	result.assign(options)
	return result

func remove_attack(attack: AttackPattern, difficulty: String, week: int):
	var options: Array = database[difficulty][week + 1]
	options.erase(attack)

func add(attack: AttackPattern):
	for difficulty in attack.difficulty_map.keys():
		if !database.has(difficulty):
			database[difficulty] = {}
		var map = database[difficulty]
		var week = attack.difficulty_map[difficulty]
		if !map.has(week):
			map[week] = []
		map[week].append(attack)

# Create every single attack in the game lol
func populate_database():
	add(SimpleAttackBuilder.new().easy(1).build())
	# Easy week 2
	add(SimpleAttackBuilder.new().fortune_once(add_10_weeds)\
		.easy(2).normal(1).hard(1).mastery(1).build())
	add(SimpleAttackBuilder.new().fortune_once(add_blightroot)\
		.easy(2).normal(1).hard(1).mastery(1).build())
	
	# Easy first boss
	add(simple_every(destroy_one_plant)\
		.easy(3).normal(2).hard(2).mastery(2).build())
	add(SimpleAttackBuilder.new().fortune_every_turn(add_blightroot)\
		.easy(3).normal(2).hard(2).mastery(2).build())
	#add(simple_every(end_turn_swap)
	#	.easy(3).normal(2).hard(2).mastery(2).build())
	add(simple_every(DestroyTiles.new(1))
		.easy(3).normal(2).hard(2).mastery(2).build())
	add(simple_every(IncreaseRitualTarget.new(10.0))\
		.easy(3).normal(2).hard(2).mastery(2).build())
	
	# Easy year 4-5 / Normal first boss
	add(simple_every(DestroyPlants.new(1)).fortune_once(EndTurnRandomizeColors.new())\
		.easy(4).normal(3).build())
	add(SimpleAttackBuilder.new().fortune_once(weeds_entire_farm)\
		.easy(4).normal(3).build())
	add(simple_every(add_blightroot).fortune_once(add_10_weeds)\
		.easy(4).normal(3).build())
	add(SimpleAttackBuilder.new().fortune_once(DestroyTiles.new(7))\
		.easy(4).normal(3).build())
	add(simple_every(DestroyPlants.new(1)).fortune_once(EndTurnRandomizeColors.new())\
		.easy(5).build())
	add(SimpleAttackBuilder.new().fortune_once(weeds_entire_farm)\
		.easy(5).build())
	add(simple_every(add_blightroot).fortune_once(add_10_weeds)\
		.easy(5).build())
	#TODO One more at least
	
	# Easy 2nd boss
	add(simple_every(burn_rightmost)\
		.easy(6).normal(5).hard(5).mastery(4).build())
	add(SimpleAttackBuilder.new().fortune_every_turn(add_deathcap)\
		.easy(6).normal(5).hard(5).mastery(4).build())
	#add(simple_every(end_turn_rotate)\
	#	.easy(6).normal(5).hard(5).mastery(4).build())
	add(simple_every(destroy_two_plants)\
		.easy(6).normal(5).hard(5).mastery(4).build())
	#TODO More
	
	# Easy year 7
	add(SimpleAttackBuilder.new().fortune_even(Helper.pick_random([destroy_row, destroy_col]))\
		.easy(7).build())
	add(SimpleAttackBuilder.new().fortune_odd(add_corpse_flower)\
		.easy(7).build())
	add(SimpleAttackBuilder.new().fortune_every_turn(IncreaseBlightStrength.new(0.5)).damage_multiplier(1.5)\
		.easy(7).build())
	
	# Easy final boss
	add(simple_every(add_corpse_flower)\
		.easy(8).hard(7).mastery(6).build())
	add(simple_every(Helper.pick_random([destroy_row, destroy_col]))\
		.easy(8).hard(7).mastery(6).build())
	add(SimpleAttackBuilder.new().fortune_every_turn(IncreaseBlightStrength.new(1.0)).damage_multiplier(2.0)\
		.easy(8).hard(7).build())
	add(simple_every(destroy_two_tiles)
		.easy(8).hard(7).mastery(6).build())
	add(simple_every_list([burn_rightmost, add_deathcap])\
		.easy(8).normal(7).hard(6).mastery(5).build())
	
	# Normal-Hard-Mastery turns 1-2 are already done
	
	# Normal 3: thorns are new
	add(simple_every(increase_ritual_10).fortune_once(Helper.pick_random([two_blood_thorns, two_dark_thorns]))\
		.normal(3).build())
	
	# Two easy 1st bosses: Normal 4, Hard 3, Mastery 3
	add(simple_every_list([destroy_one_plant, add_blightroot])\
		.normal(4).hard(3).mastery(3).build())
	add(simple_every_list([destroy_one_tile, increase_ritual_10])\
		.normal(4).hard(3).mastery(3).build())
	add(simple_every_list([add_blightroot, increase_ritual_10])\
		.normal(4).hard(3).mastery(3).build())
	add(simple_every_list([destroy_one_plant, increase_ritual_10])\
		.normal(4).hard(3).mastery(3).build())
	
	# Normal 5 is already done, it's easy second boss
	# Normal 2nd boss
	add(simple_every_list([burn_rightmost, add_blightroot])\
		.normal(6).hard(5).mastery(4).build())
	add(simple_every(Helper.pick_random([one_blood_thorn, one_dark_thorn]))\
		.normal(6).hard(5).mastery(4).build())
	add(simple_every(WeedsEveryCard.new(1)).fortune_every_turn(destroy_one_plant)\
		.normal(6).hard(5).mastery(4).build())
	add(simple_every_list([add_deathcap, AddWeeds.new(2)])\
		.normal(6).hard(5).mastery(4).build())
	add(simple_every_list([destroy_two_plants, increase_ritual_10])\
		.normal(6).hard(5).mastery(4).build())
	
	# Normal week 7
	add(simple_every_list([Helper.pick_random([one_dark_thorn, one_blood_thorn]), add_10_weeds])\
		.normal(7).build())
	# We also have burn + deathcap from easy final boss
	
	# Normal year 8 final boss
	add(simple_every(Helper.pick_random([destroy_row, destroy_col])).fortune_once(Helper.pick_random([AddBloodThornsDeck.new(3), AddDarkThornsDeck.new(3)]))\
		.normal(8).mastery(6).build())
	add(simple_every_list([add_corpse_flower, add_blightroot])\
		.normal(8).mastery(6).build())
	add(simple_every_list([IncreaseBlightStrength.new(1.0), increase_ritual_10]).damage_multiplier(2.0)\
		.normal(8).hard(8).mastery(7).build())
	add(simple_every_list([destroy_two_tiles, add_10_weeds])\
		.normal(8).mastery(6).build())
	
	# Hard: Year 4
	add(simple_every(weeds_2_every_card).hard(4).build())
	add(simple_every(weeds_every_card).fortune_even(block_ritual).hard(4).build())
	add(SimpleAttackBuilder.new().fortune_every(cold_snap, 4).hard(4).build())
	add(SimpleAttackBuilder.new().fortune_every(counter3, 3).hard(4).build())
	add(SimpleAttackBuilder.new().fortune_every(destroy_plant_every_card, 3).hard(4).build())
	
	# Hard year 5 is normal 2nd boss, already done
	add(SimpleAttackBuilder.new().fortune_every_turn(AddBlightroot.new(1))\
		.fortune_odd(EndTurnSwapColors.new())\
		.fortune_even(EndTurnBurn.new())
		.hard(5).mastery(4).build())
	add(SimpleAttackBuilder.new().fortune_every_turn(DestroyPlants.new(1))\
		.fortune_random(EndTurnBurn.new())\
		.fortune_random(AddBlightroot.new(1))\
		.fortune_random(AddDeathcap.new(1))\
		.normal(6).hard(5).mastery(4).build())

	# Hard 2nd boss
	add(SimpleAttackBuilder.new().fortune_every_turn(weeds_entire_farm).fortune_once(Helper.pick_random([two_blood_thorns, two_dark_thorns]))\
		.hard(6).mastery(5).build())
	add(SimpleAttackBuilder.new().fortune_even(counter3).fortune_odd(block_ritual)\
		.hard(6).mastery(5).build())
	add(simple_every(add_deathcap).fortune_once(AddDeathcap.new(8))\
		.hard(6).mastery(5).build())
	add(SimpleAttackBuilder.new().fortune_even(destroy_plant_every_card).fortune_every(cold_snap, 4)\
		.hard(6).mastery(5).build())
	add(simple_every_list([destroy_two_plants, burn_rightmost])\
		.hard(6).mastery(5).build())
	
	# Hard year 7 is done earlier (easy final boss mostly)
	add(SimpleAttackBuilder.new().fortune_every_turn(Helper.pick_random([EndTurnBurn.new(), EndTurnRotateColors.new(), AddDeathcap.new(1)]))\
				.fortune_even(DestroyPlants.new(2)).hard(7).mastery(6).build())

	# Hard final boss
	add(simple_every_list([Helper.pick_random([destroy_row, destroy_col]), weeds_entire_farm])\
		.hard(8).mastery(7).build())
	add(SimpleAttackBuilder.new().fortune_every_turn(Helper.pick_random([destroy_row, destroy_col, AddCorpseFlower.new()]))\
		.fortune_even(Helper.pick_random([EndTurnBurn.new(), BlockRitual.new(1.0), Counter.new(3)]))\
		.hard(8).mastery(7).build())
	add(SimpleAttackBuilder.new().custom_attack(CounterAttackPattern.new())\
		.hard(8).mastery(7).build())
	add(simple_every_list([burn_rightmost, Helper.pick_random([one_blood_thorn, one_dark_thorn])])\
		.hard(8).mastery(7).build())
	add(SimpleAttackBuilder.new().fortune_even(cold_snap)\
		.hard(8).mastery(7).build())
	add(simple_every_list([destroy_two_tiles, increase_ritual_10])\
		.hard(8).mastery(7).build())
	
	#TODO: Mastery 8 (just a copy of above for now)
	add(simple_every_list([Helper.pick_random([destroy_row, destroy_col]), weeds_entire_farm])\
		.mastery(8).build())
	add(SimpleAttackBuilder.new().fortune_every_turn(Helper.pick_random([destroy_row, destroy_col, AddCorpseFlower.new()]))\
		.fortune_even(Helper.pick_random([EndTurnBurn.new(), BlockRitual.new(1.0), Counter.new(3)]))\
		.mastery(8).build())
	add(SimpleAttackBuilder.new().custom_attack(CounterAttackPattern.new())\
		.mastery(8).build())
	add(simple_every_list([burn_rightmost, Helper.pick_random([one_blood_thorn, one_dark_thorn])])\
		.mastery(8).build())
	add(SimpleAttackBuilder.new().fortune_even(cold_snap)\
		.mastery(8).build())
	add(simple_every_list([destroy_two_tiles, increase_ritual_10])\
		.mastery(8).build())
	add(simple_every(IncreaseBlightStrength.new(1.5)).damage_multiplier(2.5)\
		.mastery(8).build())
