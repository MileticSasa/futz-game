extends CharacterBody2D
class_name Player

signal swap_requested(player: Player)

enum ControlScheme {CPU, P1, P2}
enum Role {GOALIE, DEFENSE, MIDFIELD, OFFENSE}
enum SkinColor {LIGHT, MEDIUM, DARK}
enum State {MOVING, TACKLING, RECOVERING, PASSING, PREPPING_SHOT, SHOOTING, HEADER, VOLLEY_KICK, BICYCLE_KICK, CHEST_CONTROL, HURT, DIVING, CELEBRATING, MOURNING, RESETING}

const BALL_CONTROL_HEIGHT_MAX := 20.0
const CONTROL_SCHEME_MAP: Dictionary = {
	ControlScheme.CPU: preload("res://assets/art/props/cpu.png"),
	ControlScheme.P1: preload("res://assets/art/props/1p.png"),
	ControlScheme.P2: preload("res://assets/art/props/2p.png")
}
#const COUNTRIES := ["DEFAULT", "FRANCE", "ARGENTINA", "BRAZIL", "ENGLAND", "GERMANY", "ITALY", "SPAIN", "USA"]
const GRAVITY := 8.0
const WALK_ANIM_THRESHOLD := 0.6

@export var ball: Ball
@export var control_scheme: ControlScheme
@export var own_goal: Goal
@export var target_goal: Goal
@export var power: float
@export var speed: float 

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var ball_detection_area: Area2D = $BallDetectionArea
@onready var control_sprite: Sprite2D = $PlayerSprite/ControlSprite
@onready var goalie_hands_collider: CollisionShape2D = $GoalieHands/GoalieHandsCollider
@onready var opponent_detect_area: Area2D = $OpponentDetectArea
@onready var permanent_damage_emit_area: Area2D = $PermanentDamageEmitArea
@onready var player_sprite: Sprite2D = $PlayerSprite
@onready var teammate_detection_area: Area2D = $TeammateDetectionArea
@onready var tackle_dmg_emmiter_area: Area2D = $TackleDmgEmmiterArea
@onready var root_particles: Node2D = $RootParticles
@onready var run_particles: GPUParticles2D = $RootParticles/RunParticles

var ai_behavior_factory: AIBehaviorFactory = AIBehaviorFactory.new()
var country := ""
var current_ai_behavior: AIBehavior = null
var fullname := ""
var heading := Vector2.RIGHT
var height := 0.0
var height_velocity := 0.0
var kickoff_position := Vector2.ZERO
var current_state: PlayerState = null
var state_factory := PlayerStateFactory.new()
var role := Player.Role.MIDFIELD
var skin_color := Player.SkinColor.MEDIUM
var spawn_position := Vector2.ZERO
var weight_on_duty_steering := 0.0 # ovo mi odredjuje faktor koji utice na igraca da krene ka lopti


func _ready() -> void:
	set_control_texture()
	setup_ai_behavior()
	switch_state(State.MOVING)
	set_shader_properties()
	permanent_damage_emit_area.monitoring = role == Player.Role.GOALIE
	goalie_hands_collider.disabled = role != Player.Role.GOALIE
	tackle_dmg_emmiter_area.body_entered.connect(on_tackle_player.bind())
	permanent_damage_emit_area.body_entered.connect(on_tackle_player.bind())
	spawn_position = position
	GameEvents.team_scored.connect(on_team_scored.bind())
	GameEvents.game_over.connect(on_game_over.bind())
	var initial_position := kickoff_position if country == GameManager.current_match.country_home else spawn_position
	switch_state(State.RESETING, PlayerStateData.new().set_reset_position(initial_position))


func _process(delta: float) -> void:
	flip_sprites()
	set_sprite_visibility()
	process_gravity(delta)
	
	move_and_slide()


func set_shader_properties() -> void:
	player_sprite.material.set_shader_parameter("skin_color", skin_color)
	var countries := DataLoader.get_countries()
	var country_color := countries.find(country)
	country_color = clampi(country_color, 0, countries.size() - 1)
	player_sprite.material.set_shader_parameter("team_color", country_color)


func initialize(context_pos: Vector2, context_ball: Ball, context_own_goal: Goal, context_target_goal: Goal, context_data: PlayerResource, context_country: String, context_kickoff: Vector2) -> void:
	position = context_pos
	ball = context_ball
	target_goal = context_target_goal
	own_goal = context_own_goal
	speed = context_data.speed
	power = context_data.power
	role = context_data.role
	skin_color = context_data.skin_color
	fullname = context_data.full_name
	heading = Vector2.LEFT if target_goal.position.x < position.x else Vector2.RIGHT
	country = context_country
	kickoff_position = context_kickoff


func setup_ai_behavior() -> void:
	current_ai_behavior = ai_behavior_factory.get_ai_behavior(role)
	current_ai_behavior.setup(self, ball, opponent_detect_area, teammate_detection_area)
	current_ai_behavior.name = "AI Behavior"
	#call_deferred("add_child", ai_behavior)
	add_child(current_ai_behavior)


func switch_state(state: State, state_data: PlayerStateData = PlayerStateData.new()) -> void:
	if current_state != null:
		current_state.queue_free()
	
	current_state = state_factory.get_fresh_state(state)
	current_state.setup(self, state_data, animation_player, ball, teammate_detection_area, ball_detection_area, own_goal, target_goal, tackle_dmg_emmiter_area, current_ai_behavior)
	current_state.state_transition_requested.connect(switch_state.bind())
	current_state.name = "PlayerStateMachine: " + str(state)
	call_deferred("add_child", current_state)


func set_movement_animation() -> void:
	var vel_length := velocity.length()
	if vel_length < 1:
		animation_player.play("idle")
	elif vel_length < speed * WALK_ANIM_THRESHOLD:
		animation_player.play("walk")
	else :
		animation_player.play("run")


func process_gravity(delta) -> void:
	if height > 0:
		height_velocity -= GRAVITY * delta
		height += height_velocity
		if height <= 0: 
			height = 0
	player_sprite.position = Vector2.UP * height


func set_heading() -> void:
	if velocity.x > 0:
		heading = Vector2.RIGHT
	elif velocity.x < 0:
		heading = Vector2.LEFT


func face_towards_target_goal() -> void:
	if not is_facing_target_goal():
		heading = heading * -1


func flip_sprites() -> void:
	if heading == Vector2.RIGHT:
		player_sprite.flip_h = false
		tackle_dmg_emmiter_area.scale.x = 1
		opponent_detect_area.scale.x = 1
		root_particles.scale.x = 1
	elif heading == Vector2.LEFT:
		player_sprite.flip_h = true
		tackle_dmg_emmiter_area.scale.x = -1
		opponent_detect_area.scale.x = -1
		root_particles.scale.x = -1


func set_control_scheme(scheme: ControlScheme) -> void: 
	control_scheme = scheme
	set_control_texture()


func set_sprite_visibility() -> void:
	control_sprite.visible = has_ball() or not control_scheme == ControlScheme.CPU
	run_particles.emitting = velocity.length() == speed


func get_hurt(hurt_origin: Vector2) -> void:
	switch_state(Player.State.HURT, PlayerStateData.build().set_hurt_direction(hurt_origin))


func has_ball() -> bool:
	return ball.carrier == self


func set_control_texture() -> void:
	control_sprite.texture = CONTROL_SCHEME_MAP[control_scheme]


func get_pass_request(player: Player) -> void:
	if ball.carrier == self and current_state != null and current_state.can_pass():
		switch_state(Player.State.PASSING, PlayerStateData.build().set_pass_target(player))


func is_facing_target_goal() -> bool:
	var direction_to_target_goal := position.direction_to(target_goal.position)
	return heading.dot(direction_to_target_goal) > 0 #dot mi vraca kosinus ugla izmedju dva vektora. kosinus je pozitivan ako je ugao izmedju -90 i 90


func can_carry_ball() -> bool:
	return current_state != null and current_state.can_carry_ball()


func control_ball() -> void:
	if ball.height > BALL_CONTROL_HEIGHT_MAX:
		switch_state(Player.State.CHEST_CONTROL)


func is_ready_for_kickoff() -> bool:
	return current_state != null and current_state.is_ready_for_kickoff()


func on_game_over(country_winner: String) -> void:
	if country == country_winner:
		switch_state(Player.State.CELEBRATING)
	else:
		switch_state(Player.State.MOURNING)


func on_tackle_player(player: Player) -> void:
	if player != self and player.country != country and player == ball.carrier:
		player.get_hurt(position.direction_to(player.position))


func on_team_scored(team_scored_on: String) -> void:
	if country == team_scored_on:
		switch_state(Player.State.MOURNING)
	else:
		switch_state(Player.State.CELEBRATING)


func on_animation_complete() -> void:
	if current_state != null:
		current_state.on_animation_complete()


