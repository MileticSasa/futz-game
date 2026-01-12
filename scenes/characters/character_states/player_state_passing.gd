extends PlayerState
class_name PlayerStatePassing


func _enter_tree() -> void:
	animation_player.play("kick")
	player.velocity = Vector2.ZERO


func on_animation_complete() -> void:
	var pass_target := find_teammate_in_view()
	print(pass_target)
	var target := Vector2(10, 10)
	#var pass_direction := ball.position.direction_to(target)
	#var pass_distance := ball.position.distance_to(target)
	#var pass_velocity := sqrt(2 * pass_distance * BallStateFreeform.FRICTION_GROUND)
	ball.pass_to(target)
	transition_state(Player.State.MOVING)


func find_teammate_in_view() -> Player:
	var players_in_view := teammate_detection_area.get_overlapping_bodies()
	var teammates_in_view := players_in_view.filter(
		func(p: Player): return p != player #izbacujem sebe iz liste
	)
	teammates_in_view.sort_custom(
		func(p1: Player, p2: Player): return p1.position.distance_squared_to(player.position) < p2.position.distance_squared_to(player.position)
	)
	if teammates_in_view.size() > 0:
		return teammates_in_view[0]
	return null

