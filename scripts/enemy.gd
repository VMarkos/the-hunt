extends Area2D

@export var speed = 400 # Export variable speed
var screen_size

func _ready() -> void:
	screen_size = get_viewport_rect().size
	hide()
	

func _process(delta: float) -> void:
	# Initial velocity is zero - the palyer is not moving.
	var velocity = Vector2.ZERO
	
	# Make a random movement decision
	velocity.x = randi() % 3 - 1
	velocity.y = randi() % 3 - 1	
		
	# Normalize velocity and play animations
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
		
	# Update player position
	position += velocity * delta
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


func disable() -> void:
	hide()
	$CollisionShape2D.set_deferred('disabled', true)
