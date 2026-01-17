extends BallState
class_name BallStateFreeform

const MAX_CAPTURE_HEIHGT := 25

var time_since_freerorm := Time.get_ticks_msec()


func _enter_tree() -> void:
	player_detection_area.body_entered.connect(on_player_entered.bind())
	time_since_freerorm = Time.get_ticks_msec()


func _process(delta: float) -> void:
	player_detection_area.monitoring = (Time.get_ticks_msec() - time_since_freerorm > state_data.lock_duration)
	set_ball_animation_from_velocity()
	var friction := ball.friction_air if ball.height > 0 else ball.friction_ground
	ball.velocity = ball.velocity.move_toward(Vector2.ZERO, friction * delta)
	process_gravity(delta, ball.BOUNCINESS)
	move_and_bounce(delta)


func on_player_entered(body: Player) -> void:
	if body.can_carry_ball() and ball.height < MAX_CAPTURE_HEIHGT:
		ball.carrier = body
		body.control_ball()
		transition_state(Ball.State.CARRIED)


func can_air_interact() -> bool:
	return true

