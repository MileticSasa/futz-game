extends Node
class_name GameState

signal state_transition_requested(new_state: GameManager.State, data: GameStateData)

var game_state_data: GameStateData = null
var manager: GameManager = null


func setup(context_manager: GameManager, context_data: GameStateData) -> void:
	manager = context_manager
	game_state_data = context_data


func transition_state(state: GameManager.State, data: GameStateData = GameStateData.new()) -> void:
	state_transition_requested.emit(state, data)

