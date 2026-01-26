extends GameState
class_name GameStateScored

const DURATION_CELEBRATION := 2000

var time_since_celebration := Time.get_ticks_msec()


func _enter_tree() -> void:
	manager.increase_score(game_state_data.country_scored_on)
	#GameEvents.score_changed.emit()
	time_since_celebration = Time.get_ticks_msec()


func _process(_delta: float) -> void:
	if Time.get_ticks_msec() - time_since_celebration > DURATION_CELEBRATION:
		transition_state(GameManager.State.RESET, game_state_data)

