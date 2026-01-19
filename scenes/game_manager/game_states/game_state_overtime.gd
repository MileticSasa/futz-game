extends GameState
class_name GameStateOvertime


func _enter_tree() -> void:
	GameEvents.team_scored.connect(on_team_scored.bind())


func on_team_scored(team_scored_on: String) -> void:
	manager.increase_score(team_scored_on)
	transition_state(GameManager.State.GAMEOVER)

