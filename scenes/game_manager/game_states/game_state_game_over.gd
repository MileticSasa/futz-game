extends GameState
class_name GameStateGameOver


func _enter_tree() -> void:
	var country_winner := manager.get_winner_country()
	GameEvents.game_over.emit(country_winner)

