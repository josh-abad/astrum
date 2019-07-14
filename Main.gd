extends Node


func _on_Ball_dropped():
	$Ball.unfocus_camera()
	$Ball.remove()
	$HUD.set_label('LOST')