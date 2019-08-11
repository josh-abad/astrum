extends CanvasLayer

signal start_game

const RESTART_ICON := preload("res://Assets/HUD/Restart.png")


func _ready():
    $ScoreLabel.modulate = Color(1, 1, 1, 0)
    $GameOverLabel.modulate = Color(1, 1, 1, 0)
    $HighScore/Label.modulate = Color(1, 1, 1, 0)
    $HighScore/HighScoreLabel.modulate = Color(1, 1, 1, 0)


func fade(out: bool, object: Object) -> void:
    $Tween.interpolate_property(object, 'modulate', object.modulate, Color(1, 1, 1, 0 if out else 1), 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
    
    
func update_score(score: int) -> void:
    if not $Tween.is_active():
        $Tween.interpolate_property($ScoreLabel, 'modulate', $ScoreLabel.modulate, Color(1, 1, 1, 0), 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
        $Tween.interpolate_property($ScoreLabel, 'modulate', Color(1, 1, 1, 0), $ScoreLabel.modulate, 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
        $Tween.start()
    $ScoreLabel.set_text(str(score))
    
    
func update_high_score(high_score: int) -> void:
    if not $Tween.is_active():
        $Tween.interpolate_property($HighScore/HighScoreLabel, 'modulate', $HighScore/HighScoreLabel.modulate, Color(1, 1, 1, 0), 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
        $Tween.interpolate_property($HighScore/HighScoreLabel, 'modulate', Color(1, 1, 1, 0), $HighScore/HighScoreLabel.modulate, 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
        $Tween.start()
    $HighScore/HighScoreLabel.set_text(str(high_score))
    
    
func show_game_over() -> void:
    fade(true, $ScoreLabel)
    fade(false, $GameOverLabel)
    $StartButton.set_button_icon(RESTART_ICON)
    $Tween.start()
    $StartButton.visible = true
    

func update_power(power: int) -> void:
    $Tween.interpolate_property($TextureProgress, 'value', $TextureProgress.value, power, 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.start()
    
    
func _on_StartButton_pressed():
    fade(false, $ScoreLabel)
    fade(false, $HighScore/Label)
    fade(false, $HighScore/HighScoreLabel)
    fade(true, $GameOverLabel)
    fade(true, $StartLabel)
    $Tween.start()
    $StartButton.visible = false
    $ButtonSound.play()
    emit_signal('start_game')
