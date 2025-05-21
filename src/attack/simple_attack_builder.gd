extends Node
class_name SimpleAttackBuilder

var attack: AttackPattern

func _init():
	attack = SimpleAttack.new()

func fortune_once(fortune: Fortune) -> SimpleAttackBuilder:
	attack.fortunes_once.append(fortune)
	return self

func fortune_every_turn(fortune: Fortune) -> SimpleAttackBuilder:
	attack.fortunes_every_turn.append(fortune)
	return self

func fortune_even(fortune: Fortune) -> SimpleAttackBuilder:
	attack.fortunes_even.append(fortune)
	return self

func fortune_odd(fortune: Fortune) -> SimpleAttackBuilder:
	attack.fortunes_odd.append(fortune)
	return self

func fortune_random(fortune: Fortune) -> SimpleAttackBuilder:
	attack.fortunes_random.append(fortune)
	return self

func fortune_at(fortune: Fortune, week: int) -> SimpleAttackBuilder:
	attack.fortunes_at.append({
		"week": week,
		"fortune": fortune
	})
	return self

func fortune_every(fortune: Fortune, weeks: int) -> SimpleAttackBuilder:
	if weeks == 1:
		attack.fortune_every_turn(fortune)
		return self
	for i in range(12):
		if (i + 1) % weeks == 0:
			attack.fortunes_at.append({
				"week": i,
				"fortune": fortune
			})
	return self

func rank(p_rank: int) -> SimpleAttackBuilder:
	attack.rank = p_rank
	return self

func combine(other: SimpleAttackBuilder) -> SimpleAttackBuilder:
	attack.fortunes_once.append_array(other.attack.fortunes_once)
	attack.fortunes_every_turn.append_array(other.attack.fortunes_every_turn)
	attack.fortunes_even.append_array(other.attack.fortunes_even)
	attack.fortunes_odd.append_array(other.attack.fortunes_even)
	return self

func compatible(other: SimpleAttackBuilder) -> bool:
	for fortune in other.attack.fortunes_every_turn:
		if attack.fortunes_every_turn.has(fortune) or attack.fortunes_every_turn.any(func(current):
			return fortune.name.split(" ")[0] == current.name.split(" ")[0]):
			return false
	return true

func easy(week: int):
	attack.difficulty_map["easy"] = week
	return self

func normal(week: int):
	attack.difficulty_map["normal"] = week
	return self

func hard(week: int):
	attack.difficulty_map["hard"] = week
	return self

func mastery(week: int):
	attack.difficulty_map["mastery"] = week
	return self

func absurd(week: int):
	attack.difficulty_map["absurd"] = week
	return self

func damage_multiplier(strength: float):
	attack.damage_multiplier = strength
	return self

func custom_attack(custom_attack: AttackPattern):
	attack = custom_attack
	return self

func build() -> AttackPattern:
	if attack is SimpleAttack:
		attack.fortunes_random.shuffle()
	return attack
