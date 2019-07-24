extends Node

export (PackedScene) var Target
onready var modulate_color: Color = $CanvasModulate.color


func set_dim_screen(on: bool) -> void:
    $Tween.interpolate_property($CanvasModulate, 'color', $CanvasModulate.color, Color(0, 0, 0) if on else modulate_color, 0.8, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
    $Tween.start()


func _ready():
    randomize()
    $AmbientMusic.play()
    set_dim_screen(true)


func new_game() -> void:
    set_dim_screen(false)
    $Ball.set_score(0)
    $HUD.set_label('0')
    $StartTimer.start()
    $Ball.start()


func _on_Ball_dropped():
    $HUD.show_game_over()
    set_dim_screen(true)


func _on_Ball_scored():
    $HUD.set_label(str($Ball.get_score()))


func _on_TargetTimer_timeout():
    var camera = $Ball/Camera2D.get_camera_position() * 2
    var viewport = get_viewport()
    var x = camera.x - (randi() % viewport.size.x as int)
    var y = camera.y - (randi() % (camera.y + $Ball.position.y) as int)
    var target = Target.instance()
    add_child(target)
    target.position = Vector2(x, y)
    # print('camera.y: ', camera.y)
    # print('$Ball.position.y: ', $Ball.position.y)
    # print('target.position.y: ', target.position.y, '\n')


func _on_StartTimer_timeout():
    $TargetTimer.start()
    $BlackHoleTimer.start()


func _on_BlackHole_absorb():
    $BlackHole.disappear()
    $Ball.disappear()
    $HUD.show_game_over()
    set_dim_screen(true)


func _on_BlackHoleTimer_timeout() -> void:
    var x_axes: Array = ['left', 'right']
    var camera = $Ball/Camera2D.get_camera_position() * 2
    var x = camera.x / 2 - (120 if x_axes[randi() % x_axes.size()] == 'right' else -120) as int
    var y = camera.y - (randi() % (camera.y - $Ball.position.y) as int)
    $BlackHole.appear(Vector2(x, y))


func _on_BlackHole_inactive() -> void:
    $BlackHoleTimer.start()
