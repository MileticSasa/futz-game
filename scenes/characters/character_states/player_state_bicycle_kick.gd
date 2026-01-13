extends PlayerState
class_name PlayerStateBicycleKick

const BALL_HEIGHT_MIN := 5.0
const BALL_HEIGHT_MAX := 25.0
const BONUS_POWER := 2


func _enter_tree() -> void:
	animation_player.play("bicycle_kick")
	ball_detection_area.body_entered.connect(on_ball_entered.bind())


func on_ball_entered(contact_ball: Ball) -> void:
	if contact_ball.can_air_connect(BALL_HEIGHT_MIN, BALL_HEIGHT_MAX):
		var target_destination := target_goal.get_random_target_position()
		var direction := contact_ball.position.direction_to(target_destination)
		contact_ball.shoot(direction * player.power * BONUS_POWER)


func on_animation_complete() -> void:
	transition_state(Player.State.RECOVERING)

