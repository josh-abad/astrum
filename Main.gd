extends Node

export (PackedScene) var Target
onready var modulate_color = $CanvasModulate.color


func dim_screen():
    $Tween.interpolate_property($CanvasModulate, 'color', $CanvasModulate.color, Color(0, 0, 0), 0.8, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
    $Tween.start()
    
    
func undim_screen():
    $Tween.interpolate_property($CanvasModulate, 'color', Color(0, 0, 0), modulate_color, 0.8, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
    $Tween.start()
    
    
func _ready():
    randomize()
    $AmbientMusic.play()
    dim_screen()


func new_game():
    undim_screen()
    $Ball.set_score(0)
    $HUD.set_label('0')
    $StartTimer.start()
    $Ball.start()
    $BlackHole.appear()


func _on_Ball_dropped():
    $HUD.show_game_over()
    dim_screen()


func _on_Ball_scored():
    $HUD.set_label(str($Ball.get_score()))


func _on_TargetTimer_timeout():
    var camera = $Ball/Camera2D.get_camera_position()
    var viewport = get_viewport()
    var x = camera.x - (randi() % viewport.size.x as int)
    var y = camera.y - (randi() % (camera.y + $Ball.position.y) as int)
    var target = Target.instance()
    add_child(target)
    target.position = Vector2(x, y)
    print('camera.y: ', camera.y)
    print('$Ball.position.y: ', $Ball.position.y)
    print('Spawn y', y, '\n')


func _on_StartTimer_timeout():
    $TargetTimer.start()


func _on_BlackHole_absorb():
    $BlackHole.disappear()
    $Ball.disappear()
    $HUD.show_game_over()
    dim_screen()
