extends CanvasLayer

signal start_game
signal activate_power
signal activate_shield

onready var over_on_texture = load("res://Assets/HUD/ShieldOverOn.png")
onready var progress_on_texture = load("res://Assets/HUD/ShieldProgressOn.png")
onready var over_off_texture = load("res://Assets/HUD/Shield.png")
onready var progress_off_texture = load("res://Assets/HUD/ShieldOn.png")
onready var power_pressed_texture = load("res://Assets/HUD/PowerPressed.png")
onready var power_under_texture = load("res://Assets/HUD/PowerUnder.png")

const RESTART_ICON := preload("res://Assets/HUD/Restart.png")
const TRANSPARENT = Color(1, 1, 1, 0)

var power_disabled = false

func _ready():
    $ScoreLabel.modulate = TRANSPARENT
    $GameOverLabel.modulate = TRANSPARENT
    $HighScore/Label.modulate = TRANSPARENT
    $HighScore/HighScoreLabel.modulate = TRANSPARENT
    $Shield.modulate = TRANSPARENT
    $Warning.modulate = TRANSPARENT
    $Power.modulate = TRANSPARENT


func fade(out: bool, object: Object, duration: float = 0.4) -> void:
    $Tween.interpolate_property(object, 'modulate', object.modulate, Color(1, 1, 1, 0 if out else 1), duration, Tween.TRANS_QUAD, Tween.EASE_OUT)
    
    
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
    
    
func hide_high_score(yes: bool) -> void:
    fade(yes, $HighScore)
    
    
func show_game_over() -> void:
    hide_high_score(false)
    fade(true, $ScoreLabel)
    fade(false, $GameOverLabel)
    fade(true, $Shield)
    fade(true, $Warning)    
    $StartButton.set_button_icon(RESTART_ICON)
    $Tween.start()
    $StartButton.show()
    

func update_power(power: int) -> void:
    $Tween.interpolate_property($Power, 'value', $Power.value, power, 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.start()
    if power_disabled != (power < 10) or power == 0:
        fade(power < 10, $Power)
    power_disabled = power < 10
        
        
func update_shield(shield: float) -> void:
    $Tween.interpolate_property($Shield, 'value', $Shield.value, shield, 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.start()
    
    
func _on_StartButton_pressed():
    fade(false, $ScoreLabel)
    fade(false, $HighScore/Label)
    fade(false, $HighScore/HighScoreLabel)
    fade(false, $Shield)
    fade(false, $Power)
    fade(true, $GameOverLabel)
    fade(true, $StartLabel)
    $Tween.start()
    $StartButton.hide()
    $ButtonSound.play()
    emit_signal('start_game')


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
        
        
func disable_warning(yes: bool) -> void:
    fade(yes, $Warning)
    $Tween.start()
                

func _disable_power() -> void:
    $Power.texture_under = power_pressed_texture      
    yield(get_tree().create_timer(0.1), "timeout")   
    $Power.texture_under = power_under_texture              
    $Power.modulate = Color(1, 1, 1, 0.5)
    power_disabled = true
    yield(get_tree().create_timer(1.5), "timeout")
    $Power.modulate = Color(1, 1, 1, 1)
    power_disabled = false


func _on_Power_gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.button_index == 1 and event.is_pressed() and !event.is_echo() and not power_disabled:
        emit_signal("activate_power")
        _disable_power()
