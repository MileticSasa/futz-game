extends Node

enum State {IN_PLAY, SCORED, RESET, KICKOF, OVERTIME, GAMEOVER}

const DURATION_GAME_SECONDS := 2 * 60

var countries: Array[String] = ["FRANCE", "USA"]
var current_state : GameState = null
var score := [0, 0]
var state_factory := GameStateFactory.new()
var time_left: float


func _ready() -> void:
	time_left = DURATION_GAME_SECONDS
	switch_state(State.IN_PLAY)


func switch_state(state: State, data: GameStateData = GameStateData.new()) -> void:
	if current_state != null:
		current_state.queue_free()
	current_state = state_factory.get_fresh_state(state)
	current_state.setup(self, data)
	current_state.state_transition_requested.connect(switch_state.bind())
	current_state.name = "GameStateMachine: " + str(state)
	call_deferred("add_child", current_state)

