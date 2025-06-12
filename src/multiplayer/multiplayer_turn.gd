extends Node
class_name MultiplayerTurn

signal on_end_turn_results_received
signal on_end_explore_results_received
signal player_state_updated

var enabled = false
var multiplayer_ui: MultiplayerUi
var turn_manager: TurnManager

var example_end_turn = {
	"ritual_counter": 10,
	"ritual_target": 100,
	"blight_attack": 10,
	"blue_mana": 50,
	"target": -1, #-1 for no specific target, otherwise ID of the peer under attack
	"damage": 0
}

var example_response = {
	"damage": 15,
	"blight_attack": 50,
	"ritual_counter": 10,
	"victory": false,
	"defeat": false,
	"lives": 2,
	"opponents": {
		"2": {
			"name": "felix",
			"damage": 50,
			"target": -1,
			"blight_attack": 10,
			"blue_mana": 50
		}
	}
}

# Settings
var game_type: Enums.MultiplayerGameType
var player_count = 0
var living_player_count = 0
var active_player_count = 0
var farm_swap = true

var end_turn_states: Dictionary = {}
var end_explore_states: Dictionary = {}

# id: int
# alive: bool (false when all lives run out)
# active: bool (false when they are done the current year)
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

func setup(p_lobby: Lobby, p_game_info: Dictionary):
	lobby = p_lobby
	player_count = lobby.players.keys().size()
	living_player_count = player_count
	active_player_count = player_count
	game_type = p_game_info.type
	farm_swap = p_game_info.farm_swap
	for key in lobby.players.keys():
		var player_info = lobby.players[key]
		var name = player_info.name
		var state: PlayerState = PlayerState.new(name, key, player_info.farm_icon, player_info.mage_icon)
		state.lives = p_game_info.starting_lives
		player_states[key] = state
	enabled = true
	print("Start multiplayer game. " + str(player_count) + " players.")
	if is_coop():
		start_new_year_coop()

# A function on the server that peers call when they finish the turn
@rpc("any_peer", "call_local", "reliable")
func notify_turn_ended(data: Dictionary):
	var state = PlayerState.decode(data)
	var peer_id = multiplayer.get_remote_sender_id()
	state.is_ready = true
	player_states[peer_id] = state
	player_state_updated.emit()
	if multiplayer.is_server():
		end_turn_states[peer_id] = state
		print("Server: Peer " + str(peer_id) + " is done turn")
		if end_turn_states.keys().size() >= active_player_count:
			do_end_turn()
			end_turn_states = {}
	pass

func do_end_turn():
	print("Server: Processing end turn")
	if is_coop():
		do_end_turn_coop()
		return
	for group in groups:
		var damage_pool = {}
		var group_active = []
		for id in group:
			if player_states[id].active:
				group_active.append(id)
		var active_count = group_active.size()
		var damage_map = {}
		for id in group_active:
			damage_map[id] = {}
		for id in group_active:
			for id2 in group_active:
				if id != id2:
					damage_map[id][id2] = 0
					damage_map[id2][id] = 0
		
		for id in group_active:
			var state = player_states[id]
			if !state.active:
				continue
			# calculate how much damage taken, or inflicted
			var damage = max(state.blight_attack - state.blue_mana, 0)
			var attack_strength = max(state.ritual_target - state.ritual_counter, 0)
			# take damage
			state.damage += damage
			state.ritual_counter = state.ritual_target
			# die if dead
			if state.damage >= 100:
				state.lives -= 1
				if state.lives <= 0:
					state.alive = false
					living_player_count -= 1
					print("Player " + str(id) + " has been eliminated")
				state.defeat = true
				state.active = false
				active_count -= 1
				active_player_count -= 1
			else:
				# deal damage if not dead
				if state.target == -1:
					damage_pool[id] = attack_strength
				else:
					damage_map[state.target][id] += attack_strength

		# if only one player left in the group, they win
		if active_count == 1:
			for id in group_active:
				if player_states[id].active:
					player_states[id].victory = true
					active_player_count -= 1

		# if simultaneous death, the winner is the one who took less damage
		# TODO: Deal with ties
		if active_count == 0:
			var best = player_states[group_active[0]].damage
			var winner = group_active[0]
			for id in group_active:
				if player_states[id].damage < best:
					best = player_states[id].damage
					winner = group_active[id]
			player_states[winner].victory = true
		
		# Final winner of the match
		if groups.size() == 1 and active_count == 0 and living_player_count == 1:
			for key in player_states:
				if player_states[key].alive and player_states[key].victory:
					player_states[key].winner = true

		# distribute damage pool
		for id in damage_pool.keys():
			var divided_damage = round(float(damage_pool[id]) / (active_count - 1))
			for id2 in group_active:
				if id2 != id and player_states[id2].alive:
					damage_map[id2][id] += divided_damage
		
		# calculate damage for everyone
		for id in group_active:
			if player_states[id].alive:
				var total_damage = 0
				var map = damage_map[id]
				for key in map:
					if map[key] > 0:
						total_damage += map[key]
				player_states[id].blight_attack = total_damage

		var response = {}
		for id in group_active:
			response[id] = player_states[id].encode()
		print("Notifying players of turn results")
		notify_client_end_turn_results.rpc(response)

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
	if is_coop():
		start_new_year_coop()
		return
	var alive = []
	for key in player_states:
		if player_states[key].alive:
			alive.append(player_states[key])
			player_states[key].active = true
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
	var states = {}
	for key in player_states:
		states[key] = player_states[key].encode()
	notify_exploring_results.rpc(groups, states)

# Server notifying peers that they can do the next turn
@rpc("authority", "call_local", "reliable")
func notify_client_end_turn_results(response):
	print("Client: Received notification that turn is done (ID " + str(multiplayer.get_unique_id()) + ")")
	latest_end_turn_response = response
	latest_explore_response = null
	for key in response:
		player_states[key] = PlayerState.decode(response[key])
	player_state_updated.emit()
	on_end_turn_results_received.emit(response)

# Server notifying peers that exploring is done
@rpc("authority", "call_local", "reliable")
func notify_exploring_results(p_groups, states):
	print("Client: Received notification that exploring is done")
	latest_explore_response = p_groups
	groups = p_groups
	for key in states:
		player_states[key] = PlayerState.decode(states[key])
	player_state_updated.emit()
	on_end_explore_results_received.emit(p_groups)

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
		results = await on_end_explore_results_received
		multiplayer_ui.set_waiting_visible(false)
	latest_explore_response = null
	return results

func get_my_state():
	return player_states[multiplayer.get_unique_id()]

func is_coop():
	return game_type == Enums.MultiplayerGameType.Cooperative

func start_new_year_coop():
	var group = []
	var states = {}
	for id in player_states.keys():
		group.append(id)
		states[id] = player_states[id].encode()
	group.shuffle()
	groups = [group]
	print("Notifying players of new year (coop)")
	notify_exploring_results.rpc(groups, states)

func do_end_turn_coop():
	var group = groups[0]
	var extra_yellow = 0.0
	var extra_blue = 0.0
	# Share excess mana (need 2 passes so last player can share with the one before them)
	for i in range(2):
		for id in group:
			var state: PlayerState = player_states[id]
			if state.ritual_counter < 0:
				extra_yellow -= state.ritual_counter
				state.ritual_counter = 0
			elif extra_yellow > 0.0:
				var use = min(extra_yellow, state.ritual_counter)
				state.ritual_counter -= use
				extra_yellow -= use
			if state.blue_mana < state.blight_attack:
				if extra_blue > 0.0:
					var use = min(extra_blue, state.blight_attack - state.blue_mana)
					extra_blue -= use
					state.blue_mana += use
			elif state.blue_mana > state.blight_attack:
				extra_blue += state.blue_mana - state.blight_attack
				state.blue_mana = state.blight_attack
	# Check for win
	var win = true
	var defeat = false
	for id in group:
		var state: PlayerState = player_states[id]
		if state.ritual_counter > 0.0:
			win = false
	if win:
		for id in group:
			if turn_manager.year == Global.FINAL_YEAR:
				player_states[id].winner = true
			else:
				player_states[id].victory = true
	else:
		# Damage after sharing
		for id in group:
			var state: PlayerState = player_states[id]
			if state.blue_mana < state.blight_attack:
				state.damage += state.blight_attack - state.blue_mana
				if state.damage >= 100:
					defeat = true
		if defeat:
			for id in group:
				player_states[id].defeat = true
	var results = {}
	for id in group:
		results[id] = player_states[id].encode()
	print("Notifying players of turn results (coop)")
	notify_client_end_turn_results.rpc(results)
