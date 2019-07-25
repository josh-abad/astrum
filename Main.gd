extends Node

export (PackedScene) var Target

var active := false


func _ready():
    randomize()
    $AmbientMusic.play()


func new_game() -> void:
    $Ball.set_score(0)
    $HUD.set_label('0')
    $StartTimer.start()
    $Ball.start()
    active = true


func _on_Ball_dropped():
    $HUD.show_game_over()
    active = false


func _on_Ball_scored():
    $HUD.set_label(str($Ball.get_score()))


func get_random_position() -> Vector2:
    var x = $Ball.position.x + rand_range(-50, 50)
    var y = $Ball.position.y - rand_range(250, 500)
    return Vector2(x, y)


func _on_TargetTimer_timeout():
    if active:
        var target = Target.instance()
        add_child(target)
        target.appear(get_random_position())


func _on_StartTimer_timeout():
    $TargetTimer.start()
    $BlackHoleTimer.start()


func _on_BlackHole_absorb():
    $BlackHole.disappear()
    $Ball.disappear()
    $HUD.show_game_over()
    $Ball.dropped_sound_transition()
    active = false


func _on_BlackHoleTimer_timeout() -> void:
    $BlackHole.appear(get_random_position())


func _on_BlackHole_inactive() -> void:
    if active:
        $BlackHoleTimer.set_wait_time(rand_range(2, 8))
        $BlackHoleTimer.start()
