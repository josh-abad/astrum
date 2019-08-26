extends CanvasLayer

signal start_game
signal activate_power
signal activate_shield

onready var over_on_texture = load("res://Assets/HUD/ShieldOverOn.png")
onready var progress_on_texture = load("res://Assets/HUD/ShieldProgressOn.png")
onready var over_off_texture = load("res://Assets/HUD/Shield.png")
onready var progress_off_texture = load("res://Assets/HUD/ShieldOn.png")

const RESTART_ICON := preload("res://Assets/HUD/Restart.png")
const TRANSPARENT = Color(1, 1, 1, 0)

func _ready():
    $ScoreLabel.modulate = TRANSPARENT
    $GameOverLabel.modulate = TRANSPARENT
    $HighScore/Label.modulate = TRANSPARENT
    $HighScore/HighScoreLabel.modulate = TRANSPARENT
    $Shield.modulate = TRANSPARENT
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
    fade(true, $Shield)
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
        
        
func update_shield(shield: float) -> void:
    $Tween.interpolate_property($Shield, 'value', $Shield.value, shield, 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.start()
    
    
func _on_StartButton_pressed():
    fade(false, $ScoreLabel)
    fade(false, $HighScore/Label)
    fade(false, $HighScore/HighScoreLabel)
    fade(false, $Shield)
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


func _on_Shield_gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.button_index == 1 and event.is_pressed() and !event.is_echo():
        emit_signal("activate_shield")
        
        
func update_shield_state(on: bool) -> void:
    if on:
        $Shield.texture_over = over_on_texture
        $Shield.texture_progress = progress_on_texture
    else:
        $Shield.texture_over = over_off_texture
        $Shield.texture_progress = progress_off_texture
                