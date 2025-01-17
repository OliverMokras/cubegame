extends Control

@onready var stop_watch: Label = $StopWatch
var time = 0.0
var stopped = false

func _process(delta: float) -> void:
	if !stopped:
		time += delta
		# Display the formated string
		stop_watch.text = time_to_string()

func reset():
	time = 0.0

func time_to_string() -> String:
	var msec = fmod(time, 1) * 100
	var sec = fmod(time, 60)
	var mins = time / 60
	var format_string = "%02d : %02d : %02d"
	var string = format_string % [mins, sec, msec]
	return string
