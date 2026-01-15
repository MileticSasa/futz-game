extends Node
class_name PlayerState


signal state_transition_requested(new_state: Player.State, state_data: PlayerStateData)

var ai_behavior: AIBehavior = null
var animation_player: AnimationPlayer = null
var ball: Ball = null
var ball_detection_area: Area2D = null
var own_goal: Goal = null
var player: Player = null
var state_data: PlayerStateData = PlayerStateData.new()
var target_goal: Goal = null
var tackle_dmg_emitter_area: Area2D = null
var teammate_detection_area: Area2D = null


func setup(context_player: Player, context_data: PlayerStateData, context_animation_player: AnimationPlayer, context_ball: Ball, context_area: Area2D, context_ball_detection: Area2D, context_own: Goal, context_target: Goal,context_tackle_area: Area2D, context_ai: AIBehavior) -> void:
	player = context_player
	animation_player = context_animation_player
	state_data = context_data
	ball = context_ball
	teammate_detection_area = context_area
	ball_detection_area = context_ball_detection
	own_goal = context_own
	target_goal = context_target
	ai_behavior = context_ai
	tackle_dmg_emitter_area = context_tackle_area


func transition_state(new_state: Player.State, psd: PlayerStateData = PlayerStateData.new()) -> void:
	state_transition_requested.emit(new_state, psd)


func on_animation_complete() -> void:
	pass

