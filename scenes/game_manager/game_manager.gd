extends Node

enum State {IN_PLAY, SCORED, RESET, KICKOF, OVERTIME, GAMEOVER}

const DURATION_GAME_SECONDS := 2 * 60

var countries: Array[String] = ["FRANCE", "USA"]
var current_state : GameState = null
var player_setup: Array[String] = ["FRANCE", ""]
var score: Array[int] = [0, 1]
var state_factory := GameStateFactory.new()
var time_left: float


func _ready() -> void:
	time_left = DURATION_GAME_SECONDS
	switch_state(State.RESET)


func switch_state(state: State, data: GameStateData = GameStateData.new()) -> void:
	if current_state != null:
		current_state.queue_free()
	current_state = state_factory.get_fresh_state(state)
	current_state.setup(self, data)
	current_state.state_transition_requested.connect(switch_state.bind())
	current_state.name = "GameStateMachine: " + str(state)
	call_deferred("add_child", current_state)


func increase_score(country_scored_on: String) -> void:
	var index := 1 if country_scored_on == countries[0] else 0
	score[index] += 1
	GameEvents.score_changed.emit()


func get_winner_country() -> String:
	assert(not is_game_tied())
	return countries[0] if score[0] > score[1] else countries[1]


func is_game_tied() -> bool:
	return score[0] == score[1]


func is_time_up() -> bool:
	return time_left <= 0


func is_coop_mode() -> bool:
	return player_setup[0] == player_setup[1]


func is_single_player_mode() -> bool:
	return player_setup[1].is_empty()


func has_someone_scored() -> bool:
	return score[0] > 0 or score[1] > 0


