extends Node
class_name BallStateData

var lock_duration: int


static func build() ->BallStateData:
	return BallStateData.new()


func set_lock_duration(dur: int) -> BallStateData:
	lock_duration = dur
	return self

