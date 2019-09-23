extends CanvasLayer

signal start_game
signal sfx_toggled
signal music_toggled
signal achievement_complete(achievement_name)
signal upgraded(upgrade_name, level, upgrade_cost)

const RESTART_ICON: Resource = preload("res://Assets/HUD/Restart.png")
const AUDIO_ON_ICON: Resource = preload("res://Assets/HUD/AudioOn.png")
const AUDIO_OFF_ICON: Resource = preload("res://Assets/HUD/AudioOff.png")
const MUSIC_ON_ICON: Resource = preload("res://Assets/HUD/MusicOn.png")
const MUSIC_OFF_ICON: Resource = preload("res://Assets/HUD/MusicOff.png")
const TRANSPARENT = Color(1, 1, 1, 0)

var sfx_on := true
var music_on := true


func _ready() -> void:
    $ScoreLabel.modulate = TRANSPARENT
    $GameOverLabel.modulate = TRANSPARENT
    $HighScore/Label.modulate = TRANSPARENT
    $HighScore/HighScoreLabel.modulate = TRANSPARENT
    $Warning.modulate = TRANSPARENT
    $MultiplierLabel.modulate = TRANSPARENT
    $HealthBar.modulate = TRANSPARENT
    $CheevoUnlocked.modulate = TRANSPARENT


func increment_achievement(achievement_name, amount):
    $AchievementsInterface.increment_achievement(achievement_name, amount)


func reset_achievement(achievement_name):
    $AchievementsInterface.reset_achievement(achievement_name)


func fade(out: bool, object: Object, duration: float = 0.4) -> void:
    $Tween.interpolate_property(object, 'modulate', object.modulate, Color(1, 1, 1, 0 if out else 1), duration, Tween.TRANS_QUAD, Tween.EASE_OUT)
    
    
func update_score(score: int) -> void:
    $Tween.interpolate_property($ScoreLabel, 'modulate', $ScoreLabel.modulate, Color(1, 1, 1, 0), 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.interpolate_property($ScoreLabel, 'modulate', Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.start()
    $ScoreLabel.set_text(str(score))
    
    
func update_credits(credits: int) -> void:
    $Tween.interpolate_property($Credits/Label, 'modulate', $Credits/Label.modulate, Color(1, 1, 1, 0), 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.interpolate_property($Credits/Label, 'modulate', Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.start()
    $Credits/Label.set_text(str(credits))
    $UpgradeInterface.update_credits(credits)
    
    
func update_high_score(high_score: int) -> void:
    $Tween.interpolate_property($HighScore/HighScoreLabel, 'modulate', $HighScore/HighScoreLabel.modulate, Color(1, 1, 1, 0), 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.interpolate_property($HighScore/HighScoreLabel, 'modulate', Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.start()
    $HighScore/HighScoreLabel.set_text(str(high_score))
    
    
func update_health_bar(health: float) -> void:
    $Tween.interpolate_property($HealthBar, 'value', $HealthBar.value, health, 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.start()

    
func update_multiplier(multiplier: int) -> void:
    if multiplier <= 1:
        fade(true, $MultiplierLabel, 0.1)
    else:
        $Tween.interpolate_property($MultiplierLabel, 'modulate', $MultiplierLabel.modulate, Color(1, 1, 1, 0), 0.4, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
        $Tween.interpolate_property($MultiplierLabel, 'modulate', Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.4, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
        $Tween.start()
        $MultiplierLabel.set_text('×' + str(multiplier))
    
    
func init_toggles(sfx: bool, music: bool) -> void:
    sfx_on = sfx
    music_on = music
    _disable_toggle($SFXToggle, AUDIO_ON_ICON if sfx_on else AUDIO_OFF_ICON, not sfx_on)
    _disable_toggle($MusicToggle, MUSIC_ON_ICON if music_on else MUSIC_OFF_ICON, not music_on)
    
    
func set_sfx_on(value: bool) -> void:
    if sfx_on != value:
        _on_SFXToggle_pressed()
    
    
func set_music_on(value: bool) -> void:
    if music_on != value:
        _on_MusicToggle_pressed()
    
    
func hide_high_score(yes: bool) -> void:
    fade(yes, $HighScore)
    
    
func hide_achievement_unlocked(yes: bool) -> void:
    fade(yes, $CheevoUnlocked)
    
    
func display_achievement_unlocked(achievement_name: String) -> void:
    fade(false, $CheevoUnlocked)
    $CheevoUnlocked/CheevoLabel.set_text(achievement_name)
    yield(get_tree().create_timer(2), "timeout")
    fade(true, $CheevoUnlocked)
    
    
func show_game_over() -> void:
    hide_high_score(false)
    fade(true, $ScoreLabel)
    fade(true, $MultiplierLabel)
    fade(true, $HealthBar)
    fade(false, $GameOverLabel)
    fade(true, $Warning)    
    $StartButton.set_button_icon(RESTART_ICON)
    $Tween.start()
    $StartButton.show()
    $CheevoButton.show()
    $UpgradesButton.show()
    $SFXToggle.show() 
    $MusicToggle.show() 
    
    
func _on_StartButton_pressed() -> void:
    fade(false, $ScoreLabel)
    fade(false, $HighScore/Label)
    fade(false, $HighScore/HighScoreLabel)
    fade(false, $HealthBar)
    fade(true, $GameOverLabel)
    fade(true, $StartLabel)
    $Tween.start()
    $StartButton.hide()
    $CheevoButton.hide()
    $UpgradesButton.hide()
    $SFXToggle.hide()
    $MusicToggle.hide()
    $ButtonSound.play()
    emit_signal('start_game')
    
        
func _press_button(button: Control) -> void:
    $Tween.interpolate_property(button, 'rect_scale', button.rect_scale, Vector2(0.9, 0.9), 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.interpolate_property(button, 'rect_scale', Vector2(0.9, 0.9), Vector2(1, 1), 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.start()
        
        
func disable_warning(yes: bool) -> void:
    fade(yes, $Warning)
    $Tween.start()
                    

func _on_CheevoButton_pressed() -> void:
    Input.action_press("achievement_interface_open_close")
    $ButtonSound.play()


func _on_SFXToggle_pressed() -> void:    
    emit_signal("sfx_toggled")
    sfx_on = not sfx_on
    _disable_toggle($SFXToggle, AUDIO_ON_ICON if sfx_on else AUDIO_OFF_ICON, not sfx_on)
    $ButtonSound.play()


func _on_MusicToggle_pressed() -> void:
    emit_signal("music_toggled")
    music_on = not music_on
    _disable_toggle($MusicToggle, MUSIC_ON_ICON if music_on else MUSIC_OFF_ICON, not music_on)
    $ButtonSound.play()


func _disable_toggle(toggle: Button, icon: Resource, yes: bool) -> void:
    toggle.icon = icon
    toggle.modulate = Color(1, 1, 1, 0.25 if yes else 1.0)


func _on_AchievementsInterface_achievement_complete(achievement_name: String) -> void:
    emit_signal("achievement_complete", achievement_name)


func _on_UpgradesButton_pressed() -> void:
    Input.action_press("upgrade_interface_open_close")
    $ButtonSound.play()


func _on_UpgradeInterface_upgraded(upgrade_name: String, level: float, upgrade_cost: int) -> void:
    emit_signal("upgraded", upgrade_name, level, upgrade_cost)
    $ButtonSound.play()


func load_upgrades(upgrades: Dictionary) -> void:
    $UpgradeInterface.load_upgrades(upgrades)


func _on_interface_closed() -> void:
    $ButtonSound.play()