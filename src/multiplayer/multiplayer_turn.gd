extends Node
class_name MultiplayerTurn

signal on_end_turn_results_received
signal on_end_explore_results_received

var example_end_turn = {
	"ritual_counter": 10,
	"ritual_target": 100,
	"blight_attack": 10,
	"purple_mana": 50,
	"target": -1, #-1 for no specific target, otherwise ID of the peer under attack
	"damage": 0
}

var example_response = {
	"damage": 15,
	"blight_attack": 50,
	"victory": false,
	"defeat": false,
	"opponents": {
		"2": {
			"name": "felix",
			"damage": 50,
			"target": -1,
			"blight_attack": 10,
			"purple_mana": 50
		}
	}
}

# Settings
var game_type
var player_count = 0
var living_player_count = 0

var end_turn_states: Dictionary = {}
var end_explore_states: Dictionary = {}

# id: int
# alive: bool
# lives: int
# name: string
var player_states: Dictionary = {}

var groups = [] # 2D array with all the groups in the lobby

# Set me up with 
# Game type
# List of player IDs
# Number of lives
#
# Then I can set up
# Starting player states
# Living player count, player count
# Assign players to groups
#
# Then I wait for players to end their first turn

# A function on the server that peers call when they finish the turn
@rpc("any_peer", "call_local", "reliable")
func notify_turn_ended(data):
	var peer_id = multiplayer.get_remote_sender_id()
	if multiplayer.is_server():
		end_turn_states[peer_id] = data
		if end_turn_states.keys() >= living_player_count:
			do_end_turn()
	pass

func do_end_turn():
	var response_map = {}
	for group in groups:
		var damage_pool = {}
		var group_alive = []
		for id in group:
			if player_states[id].alive:
				response_map[id] = {
					"damage": 0,
					"blight_attack": 0,
					"victory": false,
					"defeat": false,
					"opponents": {}
				}
			group_alive.append(id)
		var alive_count = group_alive.size()
		
		for id in group_alive:
			var player_state = player_states[id]
			if !player_state.alive:
				continue
			var turn_state = end_turn_states[id]
			# calculate how much damage taken, or inflicted
			var damage = max(turn_state.blight_attack - turn_state.purple_mana, 0)
			var attack_strength = max(turn_state.purple_mana - turn_state.blight_attack, 0)
			# take damage
			response_map[id].damage = turn_state.damage + damage
			# die if dead
			if response_map[id].damage >= 100:
				player_state.alive = false
				player_state.lives -= 1
				response_map[id].defeat = true
				alive_count -= 1
			else:
				# deal damage if not dead
				if turn_state.target == -1:
					damage_pool[id] = attack_strength
				else:
					response_map[turn_state.target].blight_attack += attack_strength
		# if only one player left in the group, they win
		if alive_count == 1:
			for id in group_alive:
				if player_states[id].alive:
					response_map[id].victory = true

		# distribute damage pool
		for id in damage_pool.keys():
			var divided_damage = round(float(damage_pool[id]) / (alive_count - 1))
			for id2 in group_alive:
				if id2 != id and player_states[id2].alive:
					response_map[id2].blight_attack += divided_damage
	
		# update everyone on their opponent statuses
		for id in group_alive:
			for id2 in group:
				if id2 != id:
					var opponent = {
						"name": player_states[id2].name,
						"damage": 100 if !player_states[id2].alive else response_map[id2].damage
					}
					opponent.target = end_turn_states[id2].target
					opponent.blight_attack = end_turn_states[id2].blight_attack
					opponent.purple_mana = end_turn_states[id2].purple_mana
					response_map[id].opponents[id2] = opponent

		# ok we're done!
		for id in group_alive:
			notify_client_end_turn_results.rpc_id(id, response_map[id])

# Functon to call when we're done exploring
@rpc("any_peer", "call_local", "reliable")
func notify_done_exploring():
	if multiplayer.is_server():
		pass
	pass

# Server notifying peers that they can do the next turn
@rpc("authority", "call_local", "reliable")
func notify_client_end_turn_results(response):
	pass

# Server notifying peers that exploring is done
@rpc("authority", "call_local", "reliable")
func exploring_results():
	pass
