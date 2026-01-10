extends PlayerState
class_name PlayerStateMoving


func _process(_delta: float) -> void:
	if player.control_scheme == Player.ControlScheme.CPU:
		pass #ovo ce da kontrolise AI
	else:
		handle_human_movement()
	
	player.set_heading()
	player.set_movement_animation()


func handle_human_movement() -> void:
	#var direction := Input.get_vector("p1_left", "p1_right", "p1_up", "p1_down")
	var direction := KeyUtils.get_input_vector(player.control_scheme)
	player.velocity = direction * player.speed
	
	if player.velocity != Vector2.ZERO and KeyUtils.is_action_just_pressed(player.control_scheme, KeyUtils.Action.SHOOT):
		state_transition_requested.emit(Player.State.TACKLING)


