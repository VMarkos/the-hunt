extends Area2D

@onready var q_learning = $QLearningAgent
@onready var player: Area2D
@export var speed = 400 # Export variable speed
var wrap_world = false
var screen_size

# Q learning params
@export var pretrain: bool = false # Whether to pretrain the Q-Learning agent
var current_state: Vector2i
var current_dist: float
const TILE_SIZE: float = 32.0
const DX_LIM: int = 8
var bounds: Vector2i

func _ready() -> void:
	screen_size = get_viewport_rect().size
	bounds = Vector2i(screen_size / TILE_SIZE)
	hide()


func setup(player_ref: Area2D) -> void:
	player = player_ref
	current_state = calculate_dist()
	current_dist = current_state.length()
	

func _process(delta: float) -> void:
	# Initial velocity is zero - the palyer is not moving.
	var velocity = Vector2.ZERO
	
	# Make a q-learning movement
	if not player or not visible:
		return
	
	position = take_turn(delta)
	
	# Pick the correct animation
	if velocity.x > 0:
		$AnimatedSprite2D.animation = 'right'
	elif velocity.x < 0:
		$AnimatedSprite2D.animation = 'left'
	elif velocity.y > 0:
		$AnimatedSprite2D.animation = 'down'
	elif velocity.y < 0:
		$AnimatedSprite2D.animation = 'up'


func start(pos: Vector2) -> void:
	position = pos
	show()
	$CollisionShape2D.disabled = false


func disable() -> void:
	hide()
	$CollisionShape2D.set_deferred('disabled', true)
	
# Q-Learning related functionality

func take_turn(delta: float) -> Vector2:
	var valid_actions = get_valid_actions(delta)
	var chosen_action = q_learning.choose_action(current_state, valid_actions, pretrain)
	var next_state = calculate_dist()
	var reward = calculate_reward()
	q_learning.update_q(current_state, chosen_action, reward, next_state, pretrain)
	current_state = next_state
	return execute_action(chosen_action, delta)


# Reward function
func calculate_reward() -> float:
	if current_state == Vector2i.ZERO:
		return -10.0
	var reward: float = 0.1 + calculate_dist().length() / screen_size.length()
	#var previous_dist = current_dist
	#current_dist = calculate_dist().length()
	#if current_dist > previous_dist:
		#reward += 0.5
	#elif current_dist < previous_dist:
		#reward -= 0.5
	if current_dist <= 3.0:
		reward -= 1.0
	
	return reward


func execute_action(a, delta) -> Vector2:
	var velocity = Vector2i.ZERO
	match a:
		q_learning.Action.UP:
			velocity.y -= 1
		q_learning.Action.DOWN:
			velocity.y += 1
		q_learning.Action.RIGHT:
			velocity.x += 1
		q_learning.Action.LEFT:
			velocity.x -= 1
	var temp_pos = position + velocity * speed * delta
	if wrap_world:
		return Vector2(
			fposmod(temp_pos.x, screen_size.x),
			fposmod(temp_pos.y, screen_size.y)
		)
	return temp_pos.clamp(Vector2.ZERO, screen_size)

# Find relative distance between player and enemy
func calculate_dist() -> Vector2i:
	if wrap_world:
		return calculate_wrapper_vec()
	return calculate_unwrapped_vec()
	
func calculate_unwrapped_vec() -> Vector2i:
	var player_pos = player.position
	var pixel_diff = player_pos - position
	
	var grid_offset = Vector2i(pixel_diff / TILE_SIZE)
	
	return Vector2i(
		clampi(grid_offset.x, -DX_LIM, DX_LIM),
		clampi(grid_offset.y, -DX_LIM, DX_LIM)
	)
	

func calculate_wrapper_vec() -> Vector2i:
	var player_pos = player.position
	var pixel_diff = player_pos - position
	
	var grid_offset = Vector2i(pixel_diff / TILE_SIZE)
	if abs(grid_offset.x) > bounds.x * 0.5:
		grid_offset.x -= bounds.x * sign(grid_offset.x)
	if abs(grid_offset.y) > bounds.y * 0.5:
		grid_offset.y -= bounds.y * sign(grid_offset.y)
	return grid_offset

# Mask out invalid moves
func get_valid_actions(delta: float) -> Array:
	var valid: Array = []
	var next_pos: Vector2
	var clamped_pos: Vector2
	
	for a in q_learning.Action.values():
		next_pos = execute_action(a, delta)
		clamped_pos = next_pos.clamp(Vector2.ZERO, screen_size)
		if next_pos.is_equal_approx(clamped_pos):
			valid.append(a)
	
	return valid
