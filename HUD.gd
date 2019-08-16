extends CanvasLayer

signal start_game
signal activate_power

const RESTART_ICON := preload("res://Assets/HUD/Restart.png")


func _ready():
    $ScoreLabel.modulate = Color(1, 1, 1, 0)
    $GameOverLabel.modulate = Color(1, 1, 1, 0)
    $HighScore/Label.modulate = Color(1, 1, 1, 0)
    $HighScore/HighScoreLabel.modulate = Color(1, 1, 1, 0)
    $PowerButton.hide()


func fade(out: bool, object: Object) -> void:
    $Tween.interpolate_property(object, 'modulate', object.modulate, Color(1, 1, 1, 0 if out else 1), 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
    
    
func update_score(score: int) -> void:
    $Tween.interpolate_property($ScoreLabel, 'modulate', $ScoreLabel.modulate, Color(1, 1, 1, 0), 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.interpolate_property($ScoreLabel, 'modulate', Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.start()
    $ScoreLabel.set_text(str(score))
    
    
func update_high_score(high_score: int) -> void:
    $Tween.interpolate_property($HighScore/HighScoreLabel, 'modulate', $HighScore/HighScoreLabel.modulate, Color(1, 1, 1, 0), 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.interpolate_property($HighScore/HighScoreLabel, 'modulate', Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.start()
    $HighScore/HighScoreLabel.set_text(str(high_score))
    
    
func show_game_over() -> void:
    fade(true, $ScoreLabel)
    fade(false, $GameOverLabel)
    $StartButton.set_button_icon(RESTART_ICON)
    $Tween.start()
    $StartButton.show()
    

func update_power(power: int) -> void:
    $Tween.interpolate_property($TextureProgress, 'value', $TextureProgress.value, power, 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.start()
    if power < 10:
        $PowerButton.hide()
    else:
        $PowerButton.show()    
    
    
func _on_StartButton_pressed():
    fade(false, $ScoreLabel)
    fade(false, $HighScore/Label)
    fade(false, $HighScore/HighScoreLabel)
    fade(true, $GameOverLabel)
    fade(true, $StartLabel)
    $Tween.start()
    $PowerButton.show()
    $StartButton.hide()
    $ButtonSound.play()
    emit_signal('start_game')


func _on_PowerButton_pressed() -> void:
    emit_signal("activate_power")
    $PowerButton.disabled = true
    yield(get_tree().create_timer(2), "timeout")
    $PowerButton.disabled = false