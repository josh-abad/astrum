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
    $Ball.start($StartPosition.position)
    $Ball.turn_on_light()
    $Ball.focus_camera()
    $Ball.enable_bounce()
    $StartTimer.start()


func _on_Ball_dropped():
    $HUD.show_game_over()
    $Ball.unfocus_camera()
    $Ball.turn_off_light()
    $Ball.stop_bounce()
    $Ball.remove()
    dim_screen()


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


func _on_StartTimer_timeout():
    $TargetTimer.start()
