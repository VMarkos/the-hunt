extends CanvasLayer

signal start_game

func _ready() -> void:
	hide()

func show_message(text) -> void:
	$Message.text = text
	$Message.show()
	
func show_game_over() -> void:
	show()
	show_message('Get Ready...')

func _on_start_button_pressed() -> void:
	hide()
	start_game.emit()
