extends AnimatableBody2D
class_name Ball

enum State {CARRIED, FREEFORM, SHOT}

const BOUNCINESS := 0.8
const DISTANCE_HEIGHT_PASS := 130
const DURATION_TUMBLE_LOCK := 200
const DURATION_PASS_LOCK := 500
const TUMBLE_HEIGHT_VELOCITY := 3.0

#@export var air_connect_min_height: float
#@export var air_connect_max_height: float
@export var friction_air: float
@export var friction_ground: float

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player_detection_area: Area2D = $PlayerDetectionArea
@onready var ball_sprite: Sprite2D = $BallSprite
@onready var scoring_ray_cast: RayCast2D = $ScoringRayCast

var carrier: Player = null
var current_state: BallState = null
var height := 0.0
var height_velocity := 0.0
var state_factory := BallStateFactory.new() 
var velocity := Vector2.ZERO


func _ready() -> void:
	switch_state(State.FREEFORM)


func _process(_delta: float) -> void:
	ball_sprite.position = Vector2.UP * height
	scoring_ray_cast.rotation = velocity.angle()


func switch_state(state: Ball.State, data: BallStateData = BallStateData.new()) -> void:
	if current_state != null:
		current_state.queue_free()
	current_state = state_factory.get_fresh_state(state)
	current_state.setup(self, player_detection_area, carrier, animation_player, ball_sprite, data)
	current_state.state_transition_requested.connect(switch_state.bind())
	current_state.name = "BallStateMachine"
	call_deferred("add_child", current_state)


func shoot(shoot_velocity: Vector2) -> void:
	velocity = shoot_velocity
	carrier = null
	switch_state(Ball.State.SHOT)


func tumble(tumble_velocity: Vector2) -> void:
	velocity = tumble_velocity
	carrier = null
	height_velocity = TUMBLE_HEIGHT_VELOCITY
	switch_state(Ball.State.FREEFORM, BallStateData.build().set_lock_duration(DURATION_TUMBLE_LOCK))


func stop() -> void:
	velocity = Vector2.ZERO


func pass_to(destination: Vector2) -> void:
	var direction := position.direction_to(destination)
	var distance := position.distance_to(destination)
	var intensity := sqrt(2 * distance * friction_ground)
	velocity = intensity * direction
	if distance > DISTANCE_HEIGHT_PASS:
		height_velocity = (BallState.GRAVITY * distance) / (2 * intensity)
		height_velocity *= 1.2 #ovo sam povecao da bi lopta isla oko visine glave igraca
	carrier = null
	switch_state(Ball.State.FREEFORM, BallStateData.build().set_lock_duration(DURATION_PASS_LOCK))


func can_air_interact() -> bool:
	return current_state != null and current_state.can_air_interact()


func can_air_connect(air_connect_min_height: float, air_connect_max_height: float) -> bool:
	return height >= air_connect_min_height and height <= air_connect_max_height


func is_headed_for_scoring_area(scoring_area: Area2D) -> bool:
	if not scoring_ray_cast.is_colliding():
		return false
	return scoring_ray_cast.get_collider() == scoring_area



