extends Screen
class_name TeamSelectionScreen

const FLAG_ANCHOR_POINT := Vector2(35, 80)
const FLAG_SELECTOR_PREFAB := preload("res://scenes/screens/team_selection/flag_selector.tscn")
const COL_NUMBER := 4
const ROW_NUMBER := 2

@onready var flags_container: Control = %FlagsContainer

var move_dirs: Dictionary[KeyUtils.Action, Vector2i] = {
	KeyUtils.Action.UP : Vector2i.UP,
	KeyUtils.Action.DOWN : Vector2i.DOWN,
	KeyUtils.Action.LEFT : Vector2i.LEFT,
	KeyUtils.Action.RIGHT : Vector2i.RIGHT
}
var selection: Array[Vector2i] = [Vector2i.ZERO, Vector2i.ZERO]
var flag_selectors: Array[FlagSelector] = []


func _ready() -> void:
	place_flags()
	place_selectors()


func _process(_delta: float) -> void:
	for i in range(flag_selectors.size()):
		var selector = flag_selectors[i]
		if not selector.is_selected:
			for action: KeyUtils.Action in move_dirs.keys():
				if KeyUtils.is_action_just_pressed(selector.control_scheme, action):
					try_navigate(i, move_dirs[action])
	if not flag_selectors[0].is_selected and KeyUtils.is_action_just_pressed(Player.ControlScheme.P1, KeyUtils.Action.PASS):
		SoundPlayer.play(SoundPlayer.Sound.UI_NAV)
		transition_screen(SoccerGame.ScreenType.MAIN_MENU)


func place_flags() -> void:
	for i in range(ROW_NUMBER):
		for j in range(COL_NUMBER):
			var flag_texture := TextureRect.new()
			flag_texture.position = FLAG_ANCHOR_POINT + Vector2(55 * j, 50 * i)
			var country_index := 1 + j + COL_NUMBER * i #jedan na pocetku je zato sto preskacem prvu default drzavu
			var country := DataLoader.get_countries()[country_index]
			flag_texture.texture = FlagHelper.get_texture(country)
			flag_texture.scale = Vector2(2, 2)
			flag_texture.z_index = 1
			flags_container.add_child(flag_texture)


func try_navigate(selector_index: int, direction: Vector2i) -> void:
	var rect: Rect2i = Rect2i(0, 0, COL_NUMBER, ROW_NUMBER)
	if rect.has_point(selection[selector_index] + direction):
		selection[selector_index] += direction
		var flag_index := selection[selector_index].x +selection[selector_index].y * COL_NUMBER
		GameManager.player_setup[selector_index] = DataLoader.get_countries()[1 + flag_index] #dodajem 1 jer mi je prva zemlja default
		flag_selectors[selector_index].position = flags_container.get_child(flag_index).position
		SoundPlayer.play(SoundPlayer.Sound.UI_NAV)


func place_selectors() -> void:
	add_selector(Player.ControlScheme.P1)
	if not GameManager.player_setup[1].is_empty():
		add_selector(Player.ControlScheme.P2)


func add_selector(cs: Player.ControlScheme) -> void:
	var selector := FLAG_SELECTOR_PREFAB.instantiate()
	selector.position = flags_container.get_child(0).position
	selector.control_scheme = cs
	selector.selected.connect(on_selector_selected.bind())
	flag_selectors.append(selector)
	flags_container.add_child(selector)


func on_selector_selected() -> void:
	for selector in flag_selectors:
		if not selector.is_selected:
			return
	var country_p1 := GameManager.player_setup[0]
	var country_p2 := GameManager.player_setup[1]
	if not country_p2.is_empty() and country_p1 != country_p2:
		GameManager.countries = [country_p2, country_p1]
		transition_screen(SoccerGame.ScreenType.IN_GAME)


