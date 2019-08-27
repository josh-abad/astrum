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

const RESTART_ICON: Resource = preload("res://Assets/HUD/Restart.png")
const TRANSPARENT = Color(1, 1, 1, 0)

var power_disabled = false


func _ready() -> void:
    $ScoreLabel.modulate = TRANSPARENT
    $GameOverLabel.modulate = TRANSPARENT
    $HighScore/Label.modulate = TRANSPARENT
    $HighScore/HighScoreLabel.modulate = TRANSPARENT
    $Shield.modulate = TRANSPARENT
    $Warning.modulate = TRANSPARENT
    $Power.modulate = TRANSPARENT
    $PowerLight.energy = 0
    $HighScoreLight.energy = 0
    $ShieldLight.energy = 0
    $WarningLight.energy = 0


func fade(out: bool, object: Object, light: Light2D = null, duration: float = 0.4) -> void:
    $Tween.interpolate_property(object, 'modulate', object.modulate, Color(1, 1, 1, 0 if out else 1), duration, Tween.TRANS_QUAD, Tween.EASE_OUT)
    if light:
        $Tween.interpolate_property(light, 'energy', light.energy, 0 if out else 1, duration, Tween.TRANS_QUAD, Tween.EASE_OUT)
    
    
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
    fade(yes, $HighScore, $HighScoreLight)
    
    
func show_game_over() -> void:
    hide_high_score(false)
    fade(true, $ScoreLabel)
    fade(false, $GameOverLabel)
    fade(true, $Shield, $ShieldLight)
    fade(true, $Warning, $WarningLight)    
    $StartButton.set_button_icon(RESTART_ICON)
    $Tween.start()
    $StartButton.show()
    

func update_power(power: int) -> void:
    $Tween.interpolate_property($Power, 'value', $Power.value, power, 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.start()
    if power_disabled != (power < 10) or power == 0:
        fade(power < 10, $Power, $PowerLight)
    power_disabled = power < 10
        
        
func update_shield(shield: float) -> void:
    $Tween.interpolate_property($Shield, 'value', $Shield.value, shield, 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.start()
    
    
func _on_StartButton_pressed() -> void:
    fade(false, $ScoreLabel)
    fade(false, $HighScore/Label, $HighScoreLight)
    fade(false, $HighScore/HighScoreLabel)
    fade(false, $Shield, $ShieldLight)
    fade(false, $Power, $PowerLight)
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
        _press_button($Shield)
        $Shield.texture_over = over_on_texture
        $Shield.texture_progress = progress_on_texture
        $Tween.interpolate_property($ShieldLight, 'color', $ShieldLight.color, Color("#03f6da"), 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
    else:
        $Shield.texture_over = over_off_texture
        $Shield.texture_progress = progress_off_texture
        $Tween.interpolate_property($ShieldLight, 'color', $ShieldLight.color, Color("#f7a757"), 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)        
    $Tween.start()
    
        
func _press_button(button: Control) -> void:
    $Tween.interpolate_property(button, 'rect_scale', button.rect_scale, Vector2(0.9, 0.9), 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.interpolate_property(button, 'rect_scale', Vector2(0.9, 0.9), Vector2(1, 1), 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.start()
        
        
func disable_warning(yes: bool) -> void:
    fade(yes, $Warning, $WarningLight)
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
