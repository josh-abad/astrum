extends Node

export (PackedScene) var Target


func _ready():
    randomize()
    $AmbientMusic.play()
    $HUD.set_label(str($Ball.get_score()))
    $TargetTimer.start()


func _on_Ball_dropped():
    $Ball.unfocus_camera()
    $Ball.turn_off_light()
    $Ball.stop_bounce()
    $Ball.remove()
    $HUD.set_label('Game Over')
    $HUD.start_tween()


func _on_Ball_scored():
    $HUD.set_label(str($Ball.get_score()))


func _on_TargetTimer_timeout():
    $TargetPath/TargetSpawnLocation.set_offset(randi())
    var target = Target.instance()
    add_child(target)
    var direction = $TargetPath/TargetSpawnLocation.rotation + PI / 2
    target.position = $TargetPath/TargetSpawnLocation.position
    direction += rand_range(-PI / 4, PI / 4)
    target.rotation = direction