extends Node
class_name BallState

signal state_transition_requested(new_state: Ball.State)

var animation_player: AnimationPlayer = null
var ball: Ball = null
var ball_sprite: Sprite2D = null
var carrier: Player = null
var player_detection_area: Area2D = null


func setup(context_ball: Ball, context_player_detection: Area2D, context_carrier: Player, context_anim_player: AnimationPlayer, context_sprite: Sprite2D) -> void:
	ball = context_ball
	player_detection_area = context_player_detection
	carrier = context_carrier
	animation_player = context_anim_player
	ball_sprite = context_sprite


