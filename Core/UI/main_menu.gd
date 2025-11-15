extends CanvasLayer

@onready var timer: Label = $Timer

var countdown_active = false;
var time_elapsed : float = 3

func _process(delta: float) -> void:
	if countdown_active:
		var text = "%d" % floor(time_elapsed + 0.7)
		timer.text = text
		time_elapsed -= delta

func _on_start_game_timer_timeout() -> void:
	timer.hide()
	countdown_active = false


func _on_level_on_timer_started() -> void:
	time_elapsed = 3
	countdown_active = true;
	timer.show()


func _on_level_on_timer_stopped() -> void:
	countdown_active = false;
	timer.hide()
