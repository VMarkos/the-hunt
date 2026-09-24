extends Node2D

@onready var ground: TileMapLayer = $Ground
@onready var camera: Camera2D = $MainCamera
@onready var player: Area2D = $Player
@export var time_scale: float = 1.0
@export var wrap_world: bool = false

func _ready() -> void:
	#new_game() # Uncomment just for debugging
	fit_viewport_to_ground()
	Engine.time_scale = time_scale
	$HUD.show()


func game_over():
	$Enemy.hide()
	$HUD.show_game_over()


func new_game():
	$Player.start($PlayerSpawn.position)
	$Player.wrap_world = wrap_world
	$Enemy.start($EnemySpawn.position)
	$Enemy.wrap_world = wrap_world
	$Enemy.setup(player)


func fit_viewport_to_ground() -> void:
	var used_rect: Rect2i = ground.get_used_rect()
	if used_rect.size == Vector2i.ZERO:
		return # No tiles in tilemap
	
	var tile_size: Vector2 = ground.tile_set.tile_size
	var map_pixel_size: Vector2 = Vector2(used_rect.size) * tile_size
	var map_pixel_pos: Vector2 = Vector2(used_rect.position) * tile_size
	
	var map_center: Vector2 = map_pixel_pos + (map_pixel_size / 2.0)
	camera.position = map_center
	
	camera.zoom = Vector2.ONE
	
	var new_window_size = Vector2i(map_pixel_size)
	DisplayServer.window_set_size(new_window_size)
	
	var screen_center = DisplayServer.screen_get_position() +\
		DisplayServer.screen_get_size() / 2
	DisplayServer.window_set_position(screen_center - new_window_size / 2)
	
