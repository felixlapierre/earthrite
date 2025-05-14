extends Node

class_name Statistics

static var records_map = {}

static func get_best_win(mage: String, farm: String):
	if records_map.has(mage):
		var mage_map = records_map[mage]
		if mage_map.has(farm):
			var record = mage_map[farm]
			return int_to_result(record)
	return null

static func get_best_win_mage(mage: String):
	if records_map.has(mage):
		var mage_map: Dictionary = records_map[mage]
		var best = -1
		for key in mage_map.keys():
			var value = mage_map[key]
			if int(value) > best:
				best = int(value)
		return int_to_result(str(best)) if best >= 0 else null
	return null

static func get_best_win_farm(farm: String):
	var best = -1
	for key in records_map.keys():
		if records_map[key].has(farm):
			var value = records_map[key][farm]
			if int(value) > best:
				best = int(value)
	return int_to_result(str(best)) if best >= 0 else null

static func record_win(mage: String, farm: String, difficulty: int):
	if difficulty == -1:
		return
	var difficulty_int = difficulty

	if records_map.has(mage):
		var mage_map = records_map[mage]
		if mage_map.has(farm):
			var previous_record = mage_map[farm]
			if int(previous_record) < difficulty_int:
				mage_map[farm] = str(difficulty_int)
		else:
			mage_map[farm] = {}
			mage_map[farm] = str(difficulty_int)
	else:
		records_map[mage] = {}
		records_map[mage][farm] = str(difficulty_int)
	save_stats()

static func int_to_result(i):
	match i:
		"0":
			return "Easy"
		"1":
			return "Normal"
		"2":
			return "Hard"
	if int(i) >= 3:
		return "Mastery" + str(int(i) - 2)

static func save_stats():
	var stats_json = {
		"records_map": records_map
	}
	var stats = FileAccess.open("user://stats.save", FileAccess.WRITE)
	stats.store_line(JSON.stringify(stats_json))
	
static func load_stats():
	if not FileAccess.file_exists("user://stats.save"):
		return null
	var settings_fileread = FileAccess.open("user://stats.save", FileAccess.READ)
	var settings_data = settings_fileread.get_line()
	var json = JSON.new()
	var parse_result = json.parse(settings_data)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message())
		return
		
	var stats_json = json.get_data()
	records_map = stats_json.records_map
