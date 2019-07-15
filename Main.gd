extends Node

var score = 0


func _ready():
	$AudioStreamPlayer2.play()
	$HUD.set_label(str(score))


func _on_Ball_dropped():
	$Ball.unfocus_camera()
	$Ball.turn_off_light()
	$Ball.stop_bounce()
	$Ball.remove()
	$HUD.set_label('LOST')


func _on_Circle_hit():
	get_tree().paused = true
	score += 1
	$HUD.set_label(str(score))
	$Freeze.start()


func _on_Freeze_timeout():
	get_tree().paused = false
