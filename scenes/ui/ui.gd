extends CanvasLayer
class_name UI

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player_label: Label = $UIContainer/ColorRect/BoxContainer/PlayerLabel
@onready var home_flag_texture: TextureRect = $UIContainer/ColorRect/BoxContainer/HomeFlagTexture
@onready var score_label: Label = $UIContainer/ColorRect/BoxContainer/ScoreLabel
@onready var away_flag_texture: TextureRect = $UIContainer/ColorRect/BoxContainer/AwayFlagTexture
@onready var time_label: Label = $UIContainer/ColorRect/BoxContainer/TimeLabel
@onready var mask: ColorRect = $UIContainer/Mask
@onready var goal_texture: TextureRect = $UIContainer/GoalTexture
@onready var goal_score_label: Label = $UIContainer/GoalScoreLabel
@onready var score_info_label: Label = $UIContainer/ScoreInfoLabel

# flag_textures: Array[TextureRect] = [home_flag_texture, away_flag_texture]
var last_ball_carrier: String = ""


func _ready() -> void:
	update_score()
	update_flags()
	update_clock()
	player_label.text = ""
	GameEvents.ball_possesed.connect(on_ball_possesed.bind())
	GameEvents.ball_released.connect(on_ball_released.bind())
	GameEvents.score_changed.connect(on_score_changed.bind())
	GameEvents.team_reset.connect(on_team_reset.bind())
	GameEvents.game_over.connect(on_game_over.bind())


func _process(_delta: float) -> void:
	update_clock()


func update_score() -> void:
	score_label.text = ScoreHelper.get_score_text(GameManager.current_match)


func update_flags() -> void:
	#for i in flag_textures.size():
		#flag_textures[i].texture = FlagHelper.get_texture(GameManager.countries[i])
	home_flag_texture.texture = FlagHelper.get_texture(GameManager.current_match.country_home)
	away_flag_texture.texture = FlagHelper.get_texture(GameManager.current_match.county_away)


func update_clock() -> void:
	if GameManager.time_left < 0:
		time_label.modulate = Color.YELLOW
	time_label.text = TimeHelper.get_time_text(GameManager.time_left)


func on_ball_possesed(player_name: String) -> void:
	player_label.text = player_name
	last_ball_carrier = player_name


func on_ball_released() -> void:
	player_label.text = ""


func on_score_changed() -> void:
	if not GameManager.is_time_up():
		goal_score_label.text = "%s SCORED!" % [last_ball_carrier]
		score_info_label.text = ScoreHelper.get_current_score_info(GameManager.current_match)
		animation_player.play("goal_appear")
	update_score()


func on_team_reset() -> void:
	if GameManager.current_match.has_someone_scored():
		animation_player.play("goal_hide")


func on_game_over(_winner: String) -> void:
	score_info_label.text = ScoreHelper.get_final_score_info(GameManager.current_match)
	animation_player.play("game_over")


