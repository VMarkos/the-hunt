extends Node2D


func _ready() -> void:
	#new_game() # Uncomment just for debugging
	$HUD.show()


func game_over():
	$Enemy.hide()
	$HUD.show_game_over()


func new_game():
	$Player.start($PlayerSpawn.position)
	$Enemy.start($EnemySpawn.position)
