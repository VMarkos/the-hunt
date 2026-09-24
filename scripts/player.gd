extends Area2D

signal hit # Whether the player has hit something or not.

@export var speed = 400 / sqrt(2) # How fast the player moves
var wrap_world = false
var screen_size

func _ready() -> void:
	screen_size = get_viewport_rect().size
	hide()
	

func _process(delta: float) -> void:
	# Initial velocity is zero - the palyer is not moving.
	var velocity = Vector2.ZERO
	
	# Check for user input, if any
	if Input.is_action_pressed('move_right'):
		velocity.x += 1
	if Input.is_action_pressed('move_left'):
		velocity.x -= 1
	if Input.is_action_pressed('move_up'):
		velocity.y -= 1
	if Input.is_action_pressed('move_down'):
		velocity.y += 1
		
	# Normalize velocity and play animations
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
		
	# Update player position
	position += velocity * delta
	if wrap_world:
		position = Vector2(
			fposmod(position.x, screen_size.x),
			fposmod(position.y, screen_size.y)
		)
	else:
		position = position.clamp(Vector2.ZERO, screen_size)
	
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


func _on_area_entered(area: Area2D) -> void:
	hide()
	hit.emit()
	$CollisionShape2D.set_deferred('disabled', false)
