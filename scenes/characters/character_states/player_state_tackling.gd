extends PlayerState
class_name PlayerStateTackling

const PRIOR_TACKLE_DURATION := 200
const GROUND_FRICTION := 250.0

var time_finish_tackle := Time.get_ticks_msec()
var is_tackling_complete: bool = false


func _enter_tree() -> void:
	animation_player.play("tackle")


func _process(delta: float) -> void:
	if not is_tackling_complete:
		player.velocity = player.velocity.move_toward(Vector2.ZERO, GROUND_FRICTION * delta)
		if player.velocity == Vector2.ZERO:
			is_tackling_complete = true
			time_finish_tackle = Time.get_ticks_msec()
	elif Time.get_ticks_msec() - time_finish_tackle > PRIOR_TACKLE_DURATION:
		transition_state(Player.State.RECOVERING)

