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

var destroy_entire_farm = DestroyEntireFarm.new()
var corrupt_random = CorruptRandom.new()
var corrupt_two_random = CorruptRandom.new(2)
var corrupt_best = CorruptBest.new()

#var end_turn_swap = EndTurnSwapColors.new()
#var end_turn_rotate = EndTurnRotateColors.new()
#var end_turn_randomize = EndTurnRandomizeColors.new()

var double_ritual_target = MultiplyRitualTarget.new(1.0)
var ritual_target_50p = MultiplyRitualTarget.new(0.5)
var increase_ritual_10 = MultiplyRitualTarget.new(0.1)
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
	add(SimpleAttackBuilder.new().fortune_odd(block_ritual).easy(1).build())
	
	# ====================
	# DESTROY
	# =====
	
	add(simple_every(destroy_one_plant)\
		.easy(3).normal(2).hard(2).mastery(2).absurd(1).build())
	# Destroy 1 plant and minor ones (weeds once, blightroot once)
	add(simple_every(destroy_one_plant).fortune_once([add_blightroot, add_10_weeds].pick_random())\
		.easy(4).hard(3).mastery(3).absurd(2).build())
	# Destroy 1 plant and first boss combo
	add(simple_every_list([destroy_one_plant, add_blightroot])\
		.easy(5).hard(4).mastery(4).absurd(3).build())
	
	# Destroy 2 plants (2nd boss)
	add(simple_every(destroy_two_plants)\
		.easy(6).hard(5).mastery(4).absurd(3).build())
	# Combine with some minor stuff
	add(simple_every(destroy_two_plants).fortune_every_turn([add_blightroot, destroy_one_tile].pick_random())\
		.easy(7).hard(5).mastery(4).absurd(4).build())
	add(simple_every(destroy_two_plants).fortune_once(ritual_target_50p)\
		.easy(7).hard(5).mastery(4).absurd(4).build())
	
	# Destroy row or column
	add(SimpleAttackBuilder.new().fortune_even(Helper.pick_random([destroy_row, destroy_col]))\
		.easy(7).build())
	add(SimpleAttackBuilder.new().fortune_every([destroy_col, destroy_row].pick_random(), 2)\
		.hard(6).mastery(5).absurd(4).build())

	add(simple_every([destroy_col, destroy_row].pick_random())\
		.easy(8).hard(7).mastery(6).absurd(5).build())
	add(simple_every_list([destroy_col, destroy_row])\
		.mastery(8).absurd(7).build())
	
	# Mark a plant to be destroyed per card played
	add(simple_every(destroy_plant_every_card).hard(6).mastery(5).absurd(4).build())

	add(simple_every_list([destroy_plant_every_card, add_blightroot]).hard(7).mastery(6).absurd(5).build())

	add(SimpleAttackBuilder.new().fortune_every(destroy_plant_every_card, 3)\
		.hard(4).mastery(3).absurd(2).build())
	
	# ======
	# PLANTS
	# =====

	add(SimpleAttackBuilder.new().fortune_once(add_10_weeds)\
		.easy(2).normal(1).hard(1).mastery(1).build())
	add(SimpleAttackBuilder.new().fortune_once(add_blightroot)\
		.easy(2).normal(1).hard(1).mastery(1).build())
	
	add(SimpleAttackBuilder.new().fortune_every_turn(add_blightroot)\
		.easy(3).normal(2).hard(2).mastery(2).absurd(1).build())
		
	add(SimpleAttackBuilder.new().fortune_once(weeds_entire_farm)\
		.easy(4).hard(3).mastery(2).absurd(1).build())
	add(simple_every(add_blightroot).fortune_once(add_10_weeds)\
		.easy(4).hard(3).mastery(2).absurd(1).build())

	add(simple_every(add_blightroot).fortune_once(add_10_weeds)\
		.easy(5).build())
	
	add(simple_every_list([destroy_one_plant, add_blightroot])\
		.easy(6).hard(5).mastery(4).absurd(3).build())
		
	add(SimpleAttackBuilder.new().fortune_every_turn(add_deathcap)\
		.easy(6).normal(5).hard(5).mastery(4).absurd(3).build())
		
	add(SimpleAttackBuilder.new().fortune_odd(add_corpse_flower)\
		.easy(7).hard(6).mastery(5).absurd(4).build())

	add(simple_every(add_corpse_flower)\
		.easy(8).hard(7).mastery(6).absurd(5).build())

	add(simple_every(WeedsEveryCard.new(1)).fortune_every_turn(destroy_one_plant)\
		.hard(5).mastery(4).absurd(3).build())

	add(simple_every_list([add_deathcap, AddWeeds.new(2)])\
		.normal(6).hard(5).mastery(4).absurd(3).build())

	add(simple_every_list([add_corpse_flower, add_blightroot])\
		.hard(8).mastery(7).absurd(6).build())

	add(simple_every(weeds_2_every_card)\
		.hard(4).mastery(3).absurd(2).build())

	add(simple_every(weeds_every_card).fortune_even(block_ritual)\
		.hard(4).mastery(3).absurd(2).build())

	# =====
	# DESTROY TILES
	# =====
	
	add(simple_every(destroy_one_tile)\
		.easy(3).hard(3).mastery(2).absurd(1).build())
	
	add(SimpleAttackBuilder.new().fortune_once(DestroyTiles.new(7))\
		.easy(4).normal(3).mastery(2).absurd(1).build())

	add(SimpleAttackBuilder.new().fortune_once(DestroyTiles.new(10))\
		.hard(3).mastery(3).absurd(2).build())

	add(simple_every(destroy_two_tiles)
		.easy(8).hard(7).mastery(6).absurd(5).build())

	add(simple_every_list([destroy_two_tiles, add_10_weeds])\
		.hard(8).mastery(7).absurd(6).build())
	
	# =====
	# NUMBERS
	# =====
	
	add(SimpleAttackBuilder.new().fortune_once(MultiplyRitualTarget.new(0.50))\
		.easy(3).normal(2).hard(2).mastery(2).build())

	add(SimpleAttackBuilder.new().fortune_every_turn(IncreaseBlightStrength.new(0.5)).damage_multiplier(1.5)\
		.easy(7).hard(7).mastery(7).absurd(6).build())
		
	add(SimpleAttackBuilder.new().fortune_every_turn(IncreaseBlightStrength.new(1.0)).damage_multiplier(2.0)\
		.easy(8).hard(7).mastery(7).absurd(7).build())

	add(simple_every(IncreaseBlightStrength.new(1.0)).damage_multiplier(2.0)\
		.hard(8).mastery(8).absurd(8).build())

	add(SimpleAttackBuilder.new().fortune_every(counter3, 3)\
		.hard(4).mastery(3).absurd(3).build())
	
	# =====
	# DECK MANIPULATION
	# =====

	add(simple_every(burn_rightmost)\
		.easy(6).hard(5).mastery(4).absurd(3).build())

	add(simple_every_list([burn_rightmost, add_blightroot])\
		.hard(5).mastery(4).absurd(3).build())

	add(simple_every_list([burn_rightmost, add_deathcap])\
		.easy(8).hard(7).mastery(5).absurd(4).build())
		
	add(SimpleAttackBuilder.new().fortune_once(Helper.pick_random([two_blood_thorns, two_dark_thorns]))\
		.hard(2).mastery(1).absurd(1).build())

	add(simple_every(Helper.pick_random([one_blood_thorn, one_dark_thorn]))\
		.normal(6).hard(5).mastery(4).absurd(3).build())

	add(simple_every_list([Helper.pick_random([one_dark_thorn, one_blood_thorn]), add_10_weeds])\
		.hard(7).mastery(5).absurd(4).build())

	add(SimpleAttackBuilder.new().fortune_every_turn(weeds_entire_farm)\
		.fortune_every_turn([one_blood_thorn, one_dark_thorn].pick_random())\
		.hard(6).mastery(5).absurd(4).build())
	
	# =====
	# FREEZE
	# =====
	
	add(SimpleAttackBuilder.new().fortune_every(cold_snap, 4)\
		.hard(4).mastery(3).absurd(2).build())
	
	add(SimpleAttackBuilder.new().fortune_every(cold_snap, 3)\
		.hard(6).mastery(5).absurd(4).build())
	
	add(SimpleAttackBuilder.new().fortune_even(cold_snap)\
		.mastery(8).absurd(7).build())

	add(simple_every(cold_snap).absurd(8).build())

	# =====
	# Big Combinations
	# =====

	add(SimpleAttackBuilder.new().fortune_every_turn(AddBlightroot.new(1))\
		.fortune_odd(destroy_one_plant)\
		.fortune_even(EndTurnBurn.new())\
		.hard(5).mastery(4).build())

	add(SimpleAttackBuilder.new().fortune_every_turn(DestroyPlants.new(1))\
		.fortune_random(EndTurnBurn.new())\
		.fortune_random(AddBlightroot.new(1))\
		.fortune_random(AddDeathcap.new(1))\
		.normal(6).hard(5).mastery(4).build())

	# Hard 2nd boss
	add(SimpleAttackBuilder.new().fortune_even(counter3).fortune_odd(block_ritual)\
		.hard(6).mastery(5).absurd(4).build())
	add(simple_every(add_deathcap).fortune_once(AddDeathcap.new(8))\
		.hard(6).mastery(5).absurd(4).build())
	add(SimpleAttackBuilder.new().fortune_even(destroy_plant_every_card).fortune_every(cold_snap, 4)\
		.hard(6).mastery(5).absurd(4).build())
	add(simple_every_list([destroy_two_plants, burn_rightmost])\
		.hard(6).mastery(5).absurd(4).build())
	
	# Hard final boss
	add(simple_every_list([Helper.pick_random([destroy_row, destroy_col]), weeds_entire_farm])\
		.hard(8).mastery(7).absurd(6).build())
	add(SimpleAttackBuilder.new().fortune_every_turn(Helper.pick_random([destroy_row, destroy_col, AddCorpseFlower.new()]))\
		.fortune_even(Helper.pick_random([EndTurnBurn.new(), BlockRitual.new(1.0), Counter.new(3)]))\
		.hard(8).mastery(7).absurd(6).build())
	add(SimpleAttackBuilder.new().custom_attack(CounterAttackPattern.new())\
		.hard(8).mastery(7).absurd(6).build())
	add(simple_every_list([burn_rightmost, Helper.pick_random([one_blood_thorn, one_dark_thorn])])\
		.hard(8).mastery(7).absurd(6).build())

	# ======
	# Destroy entire farm
	# ======
	add(SimpleAttackBuilder.new().fortune_every(destroy_entire_farm, 3)\
		.mastery(8).absurd(7).build())
	add(SimpleAttackBuilder.new().fortune_odd(destroy_entire_farm)\
		.absurd(8).build())
	
	# ========
	# Corrupt plants
	# ========
	add(SimpleAttackBuilder.new().fortune_odd(corrupt_random).absurd(3).build())
	add(simple_every(corrupt_random)\
		.hard(7).mastery(6).absurd(5).build())
	add(simple_every(corrupt_two_random)\
		.mastery(8).absurd(7).build())
	add(simple_every(corrupt_best)
		.mastery(8).absurd(7).build())

	# =====
	# Multiply ritual target
	# =====
	add(SimpleAttackBuilder.new().fortune_once(double_ritual_target)\
		.easy(8).hard(8).mastery(6).absurd(6).build())
	add(SimpleAttackBuilder.new().fortune_once(MultiplyRitualTarget.new(2.0))\
		.mastery(8).absurd(8).build())
	
	# My most absurd creations
	add(simple_every_list([AddCorpseFlower.new(2), weeds_entire_farm])\
		.absurd(8).build())
	
	add(simple_every_list([destroy_two_plants, corrupt_two_random])\
		.absurd(8).build())

	add(SimpleAttackBuilder.new().fortune_once(AddBloodThornsDeck.new(20))\
		.absurd(8).build())
