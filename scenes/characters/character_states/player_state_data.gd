extends Node
class_name PlayerStateData

var shot_direction: Vector2
var shot_power: float


static func build() -> PlayerStateData:
	return PlayerStateData.new()


func set_shot_direction(dir: Vector2) -> PlayerStateData:
	shot_direction = dir
	return self


func set_shot_power(power: float) -> PlayerStateData:
	shot_power = power
	return self

