extends CanvasLayer

signal start_game

const RESTART_ICON := preload("res://Assets/HUD/Restart.png")


func _ready():
    $ScoreLabel.modulate = Color(1, 1, 1, 0)
    $GameOverLabel.modulate = Color(1, 1, 1, 0)


func fade(out: bool, object: Object) -> void:
    $Tween.interpolate_property(object, 'modulate', object.modulate, Color(1, 1, 1, 0 if out else 1), 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)


func set_label(text: String) -> void:
    if not $Tween.is_active():
        $Tween.interpolate_property($ScoreLabel, 'modulate', $ScoreLabel.modulate, Color(1, 1, 1, 0), 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
        $Tween.interpolate_property($ScoreLabel, 'modulate', Color(1, 1, 1, 0), $ScoreLabel.modulate, 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
        $Tween.start()
    $ScoreLabel.set_text(text)
    
    
func show_game_over() -> void:
    fade(true, $ScoreLabel)
    fade(false, $GameOverLabel)
    $StartButton.set_button_icon(RESTART_ICON)
    $Tween.start()
    $StartButton.visible = true
    
    
func reset_power() -> void:
    $TextureProgress.value = 0
    
    
func increase_power(value: int) -> void:
    $TextureProgress.value += value
    
    
func decrease_power(value: int) -> void:
    $TextureProgress.value -= value
    
    
func _on_StartButton_pressed():
    fade(false, $ScoreLabel)
    fade(true, $GameOverLabel)
    fade(true, $StartLabel)
    $Tween.start()
    $StartButton.visible = false
    $ButtonSound.play()
    emit_signal('start_game')
