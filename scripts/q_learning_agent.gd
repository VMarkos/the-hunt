extends Node

# Q-Table represented as Dictionary: Vector2i(dx, dy) -> [Q_UP, Q_DOWN, Q_LEFT, Q_RIGHT]
var q_table: Dictionary = {}

# Hyperparameters exposed to the Inspector
@export_range(0.0, 1.0) var alpha: float = 0.1       # Learning Rate
@export_range(0.0, 1.0) var gamma: float = 0.95      # Discount Factor
@export_range(0.0, 1.0) var epsilon: float = 0.2     # Exploration Rate

enum Action { UP, DOWN, LEFT, RIGHT }

# Gets Q-values for a state, initializing to 0.0 if new
func _get_q_values(state: Vector2i, pretrain: bool=false) -> Array:
	if not q_table.has(state):
		if pretrain:
			q_table[state] = _pretrain_q_values(state)
		else:
			q_table[state] = [0.0, 0.0, 0.0, 0.0]
	return q_table[state]
	

func _pretrain_q_values(state: Vector2i) -> Array:
	'''Returns a pretrained value for the Q-table, favoring movement away from
	the player.'''
	var dx: float = 0.0
	var dy: float = 0.0
	if abs(state.x) > abs(state.y): # Move mostly on the x and secondarily on the y axis
		dx += 1.0
		dy += 0.5
	else:
		dy += 1.0
		dx += 0.5
	# Assuming the state points from the agent to the player!
	var action_values = [
		sign(state.y) * dy,
		-sign(state.y) * dy,
		sign(state.x) * dx,
		sign(state.x) * dx
	]
	return action_values

# Selects action using epsilon-greedy strategy with Action Masking
func choose_action(state: Vector2i, valid_actions: Array, pretrain: bool=false):
	if valid_actions.is_empty():
		return Action.UP
		
	# Exploration: pick a random VALID action
	if randf() < epsilon:
		return valid_actions.pick_random()
	
	# Exploitation: pick VALID action with highest Q-value
	var q_vals = _get_q_values(state, pretrain)
	var best_action = valid_actions[0]
	var max_q = -INF
	
	for a in valid_actions:
		if q_vals[a] > max_q:
			max_q = q_vals[a]
			best_action = a
			
	return best_action

# Standard Q-learning update step
func update_q(state: Vector2i, action: Action, reward: float, next_state: Vector2i, pretrain: bool=false):
	var q_vals = _get_q_values(state, pretrain)
	var next_q_vals = _get_q_values(next_state, pretrain)
	
	var max_next_q = next_q_vals.max()
	var current_q = q_vals[action]
	
	# Q(s, a) = Q(s, a) + alpha * (reward + gamma * max(Q(s', a')) - Q(s, a))
	q_table[state][action] = current_q + alpha * (reward + (gamma * max_next_q) - current_q)
