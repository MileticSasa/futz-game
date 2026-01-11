extends BallState
class_name BallStateFreeform


func _enter_tree() -> void:
	player_detection_area.body_entered.connect(on_player_entered.bind())
	animation_player.play("idle")


func on_player_entered(body: Player) -> void:
	ball.carrier = body
	state_transition_requested.emit(Ball.State.CARRIED)

