extends Node
class_name MultiplayerTurn

signal on_end_turn_results_received
signal on_end_explore_results_received

var enabled = false
var multiplayer_ui: MultiplayerUi

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
	"ritual_counter": 10,
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
var game_type: Enums.MultiplayerGameType
var player_count = 0
var living_player_count = 0
var active_player_count = 0

var end_turn_states: Dictionary = {}
var end_explore_states: Dictionary = {}

# id: int
# alive: bool
# lives: int
# name: string
var player_states: Dictionary = {}

var finish_explore_ready = 0

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
var lobby: Lobby

var latest_end_turn_response
var latest_explore_response

func setup(p_lobby: Lobby, p_game_type: Enums.MultiplayerGameType):
	lobby = p_lobby
	player_count = lobby.players.keys().size()
	living_player_count = player_count
	active_player_count = player_count
	game_type = p_game_type
	for key in lobby.players.keys():
		var player_info = lobby.players[key]
		var name = player_info.name
		player_states[key] = {
			"name": name,
			"id": key,
			"alive": true,
			"lives": 3
		}
	enabled = true
	print("Start multiplayer game. " + str(player_count) + " players.")

# A function on the server that peers call when they finish the turn
@rpc("any_peer", "call_local", "reliable")
func notify_turn_ended(data):
	var peer_id = multiplayer.get_remote_sender_id()
	if multiplayer.is_server():
		end_turn_states[peer_id] = data
		print("Server: Peer " + str(peer_id) + " is done turn")
		if end_turn_states.keys().size() >= active_player_count:
			do_end_turn()
			end_turn_states = {}
	pass

func do_end_turn():
	print("Server: Processing end turn")
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
		var damage_map = {}
		for id in group_alive:
			damage_map[id] = {}
		for id in group_alive:
			for id2 in group_alive:
				if id != id2:
					damage_map[id][id2] = 0
					damage_map[id2][id] = 0
		
		for id in group_alive:
			var player_state = player_states[id]
			if !player_state.alive:
				continue
			var turn_state = end_turn_states[id]
			# calculate how much damage taken, or inflicted
			var damage = max(turn_state.blight_attack - turn_state.purple_mana, 0)
			var attack_strength = max(turn_state.ritual_target - turn_state.ritual_counter, 0)
			# take damage
			response_map[id].damage = turn_state.damage + damage
			response_map[id].ritual_counter = turn_state.ritual_target
			# die if dead
			if response_map[id].damage >= 100:
				player_state.alive = false
				player_state.lives -= 1
				response_map[id].defeat = true
				alive_count -= 1
				active_player_count -= 1
			else:
				# deal damage if not dead
				if turn_state.target == -1:
					damage_pool[id] = attack_strength
				else:
					damage_map[turn_state.target][id] += attack_strength
					#damage_map[id][turn_state.target] -= attack_strength
		# if only one player left in the group, they win
		if alive_count == 1:
			for id in group_alive:
				if player_states[id].alive:
					response_map[id].victory = true
					active_player_count -= 1
					
		# if simultaneous death, the winner is the one who took less damage
		if alive_count == 0:
			var best = response_map[group_alive[0]].damage
			var winner = group_alive[0]
			for id in group_alive:
				if response_map[id].damage < best:
					best = response_map[id].damage
					winner = group_alive[id]
			response_map[winner].victory = true

		# distribute damage pool
		for id in damage_pool.keys():
			var divided_damage = round(float(damage_pool[id]) / (alive_count - 1))
			print(str(divided_damage))
			for id2 in group_alive:
				if id2 != id and player_states[id2].alive:
					damage_map[id2][id] += divided_damage
					#damage_map[id][id2] -= divided_damage
		
		# calculate damage for everyone
		for id in group_alive:
			if player_states[id].alive:
				var total_damage = 0
				var map = damage_map[id]
				for key in map:
					if map[key] > 0:
						total_damage += map[key]
				response_map[id].blight_attack = total_damage
	
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
			print("Notifying ID " + str(id) + " of turn results " + JSON.stringify(response_map[id]))
			notify_client_end_turn_results.rpc_id(id, response_map[id])
	

# Functon to call when we're done exploring
@rpc("any_peer", "call_local", "reliable")
func notify_done_exploring():
	if multiplayer.is_server():
		print("Server: " + str(multiplayer.get_remote_sender_id()) + " is done exploring")
		finish_explore_ready += 1
		if finish_explore_ready == player_count:
			start_new_year()
			finish_explore_ready = 0
		else:
			print("Not all players are done exploring yet")
	else:
		print("I am not the server: " + str(multiplayer.get_unique_id()))
	pass

func start_new_year():
	var alive = []
	for key in player_states:
		if player_states[key].alive:
			alive.append(player_states[key])
	alive.shuffle()
	var i = 0
	while i < alive.size():
		if alive.size() - i == 3:
			groups.append([alive[0].id, alive[1].id, alive[2].id])
			i += 3
		else:
			groups.append([alive[0].id, alive[1].id])
			i += 2
	print("Notifying players that exploring is done")
	notify_exploring_results.rpc()

# Server notifying peers that they can do the next turn
@rpc("authority", "call_local", "reliable")
func notify_client_end_turn_results(response):
	print("Client: Received notification that turn is done (ID " + str(multiplayer.get_unique_id()) + ")")
	latest_end_turn_response = response
	on_end_turn_results_received.emit(response)

# Server notifying peers that exploring is done
@rpc("authority", "call_local", "reliable")
func notify_exploring_results():
	print("Client: Received notification that exploring is done")
	latest_explore_response = true
	on_end_explore_results_received.emit(true)

# If the server ends turn last, it synchronously executes the end turn code, and
# will notify the on_end_turn_results_received signal before its own code starts
# awaiting it. Because of this, when the server calls the signal, it also saves
# the result in latest_end_turn_response. That way, when its client code gets
# here, it can grab the results instead of getting stuck waiting for a signal
# that was already sent
func wait_for_end_turn_results():
	var results = latest_end_turn_response
	if results == null:
		multiplayer_ui.set_waiting_visible(true)
		results = await on_end_turn_results_received
		multiplayer_ui.set_waiting_visible(false)
	latest_end_turn_response = null
	return results

func wait_for_explore_results():
	var results = latest_explore_response
	if results == null:
		multiplayer_ui.set_waiting_visible(true)
		await on_end_explore_results_received
		multiplayer_ui.set_waiting_visible(false)
	latest_explore_response = null
	return results
