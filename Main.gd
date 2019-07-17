extends Node


func _ready():
    $AmbientMusic.play()
    $HUD.set_label(str($Ball.get_score()))


func _on_Ball_dropped():
    $Ball.unfocus_camera()
    $Ball.turn_off_light()
    $Ball.stop_bounce()
    $Ball.remove()
    $HUD.set_label('Game Over')
    $HUD.start_tween()


func _on_Ball_scored():
    $HUD.set_label(str($Ball.get_score()))
