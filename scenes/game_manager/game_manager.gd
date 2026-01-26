extends Node

enum State {IN_PLAY, SCORED, RESET, KICKOF, OVERTIME, GAMEOVER}

const DURATION_IMPACT_PAUSE := 100
const DURATION_GAME_SECONDS := 2 * 60

var current_match: Match = null
#var countries: Array[String] = ["FRANCE", "USA"]
var current_state : GameState = null
var player_setup: Array[String] = ["FRANCE", ""]
#var score: Array[int] = [0, 0]
var state_factory := GameStateFactory.new()
var time_left: float
var time_since_impact_paused := Time.get_ticks_msec()


func _init() -> void:
	process_mode = ProcessMode.PROCESS_MODE_ALWAYS #ovo je da bi process mogao da radi i kad je pauzirano


func _ready() -> void:
	time_left = DURATION_GAME_SECONDS
	GameEvents.impact_received.connect(on_impact_received.bind())


func _process(_delta: float) -> void:
	if get_tree().paused and Time.get_ticks_msec() - time_since_impact_paused > DURATION_IMPACT_PAUSE:
		get_tree().paused = false


func start_game() -> void:
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
	current_match.increase_score(country_scored_on)
	GameEvents.score_changed.emit()


func get_winner_country() -> String:
	assert(not current_match.is_tied())
	return current_match.winner


func is_time_up() -> bool:
	return time_left <= 0


func is_coop_mode() -> bool:
	return player_setup[0] == player_setup[1]


func is_single_player_mode() -> bool:
	return player_setup[1].is_empty()


func on_impact_received(_impact_pos: Vector2, is_high_impact: bool) -> void:
	if is_high_impact:
		time_since_impact_paused = Time.get_ticks_msec()
		get_tree().paused = true


