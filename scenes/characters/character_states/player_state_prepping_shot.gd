extends PlayerState
class_name PlayerStatePreppingShoot

const DURATION_MAX_BONUS := 1000.0 #OVO JE JEDNA SEKUNDA
const EASE_REWARD_FACTOR := 2.0 # OVO KORISTIM ZA VREDNOST KRIVE U GRAFIKONU

var shot_direction := Vector2.ZERO
var time_start_shoot := Time.get_ticks_msec()


func _enter_tree() -> void:
	animation_player.play("prep_kick")
	player.velocity = Vector2.ZERO
	time_start_shoot = Time.get_ticks_msec()


func _process(delta: float) -> void:
	shot_direction += KeyUtils.get_input_vector(player.control_scheme) * delta
	if KeyUtils.is_action_just_released(player.control_scheme, KeyUtils.Action.SHOOT):
		var press_duration := clampf(Time.get_ticks_msec() - time_start_shoot, 0.0, DURATION_MAX_BONUS)
		var ease_time := press_duration / DURATION_MAX_BONUS
		var bonus := ease(ease_time, EASE_REWARD_FACTOR)
		var shot_power := player.power * (1 + bonus)
		shot_direction = shot_direction.normalized()
		#print(shot_power, shot_direction)
		#var state_data := PlayerStateData.new()
		#state_data.shot_direction = shot_direction
		#state_data.shot_power = shot_power
		var data = PlayerStateData.build().set_shot_direction(shot_direction).set_shot_power(shot_power)
		#state_transition_requested.emit(Player.State.SHOOTING)
		transition_state(Player.State.SHOOTING, data)

