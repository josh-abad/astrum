extends CanvasLayer

signal start_game

const RESTART_ICON: Resource = preload("res://Assets/HUD/Restart.png")
const AUDIO_ON_ICON: Resource = preload("res://Assets/HUD/AudioOn.png")
const AUDIO_OFF_ICON: Resource = preload("res://Assets/HUD/AudioOff.png")
const MUSIC_ON_ICON: Resource = preload("res://Assets/HUD/MusicOn.png")
const MUSIC_OFF_ICON: Resource = preload("res://Assets/HUD/MusicOff.png")
const TRANSPARENT := Color(1, 1, 1, 0)

var save_loaded: bool = false
var main_screen_hidden: bool = false
var on_start_screen: bool = true


func _ready() -> void:
    if CreditManager.connect("changed", self, "_on_credits_changed"):
        pass
    if SettingsManager.connect("changed", self, "_on_settings_changed"):
        pass
    if UpgradeManager.connect("changed", self, "_on_upgrades_changed"):
        pass
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
    
    
func _on_save_loaded() -> void:
    save_loaded = true
    
    
func _on_credits_changed() -> void:
    $Tween.interpolate_property($Credits/Label, 'modulate', $Credits/Label.modulate, Color(1, 1, 1, 0), 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.interpolate_property($Credits/Label, 'modulate', Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.start()
    $Credits/Label.set_text(str(CreditManager.get_credits()))
    
    
func _on_settings_changed() -> void:
    var music_icon: Resource = MUSIC_ON_ICON if SettingsManager.is_music_on() else MUSIC_OFF_ICON
    var sfx_icon: Resource = AUDIO_ON_ICON if SettingsManager.is_sfx_on() else AUDIO_OFF_ICON
    
    _disable_toggle($MusicToggle, music_icon, not SettingsManager.is_music_on())
    _disable_toggle($SFXToggle, sfx_icon, not SettingsManager.is_sfx_on())
    
    if save_loaded:
        $ButtonSound.play()
    
    
func _on_upgrades_changed(upgrade_name: String) -> void:
    if upgrade_name:
        pass
    if save_loaded:
        $ButtonSound.play()
    
    
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
    
    
func hide_high_score(yes: bool) -> void:
    fade(yes, $HighScore)
    
    
func show_game_over() -> void:
    main_screen_hidden = false
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
    main_screen_hidden = true
    on_start_screen = false
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
    $Warning.active = not yes
                    

func _on_CheevoButton_pressed() -> void:
    _hide_main_screen(true)
    $CheevoButton.disabled = true    
    Input.action_press("achievement_interface_open_close")
    $ButtonSound.play()


func _on_SFXToggle_pressed() -> void:    
    SettingsManager.set_sfx_on(not SettingsManager.is_sfx_on())


func _on_MusicToggle_pressed() -> void:
    SettingsManager.set_music_on(not SettingsManager.is_music_on())


func _disable_toggle(toggle: Button, icon: Resource, yes: bool) -> void:
    toggle.icon = icon
    toggle.modulate = Color(1, 1, 1, 0.25 if yes else 1.0)


func _on_AchievementsInterface_achievement_complete(achievement_name: String) -> void:
    emit_signal("achievement_complete", achievement_name)


func _hide_main_screen(hide_credits: bool = false) -> void:
    main_screen_hidden = not main_screen_hidden
    fade(true, $StartLabel if on_start_screen else $GameOverLabel)
    fade(true, $StartButton)
    fade(true, $CheevoButton)
    fade(true, $UpgradesButton)
    $SFXToggle.hide()
    $MusicToggle.hide()
    fade(true, $HighScore)
    if hide_credits:
        fade(true, $Credits)
    $Tween.start()


func _on_UpgradesButton_pressed() -> void:
    $UpgradeInterface._display(true)
    $UpgradesButton.disabled = true
    _hide_main_screen()
    $ButtonSound.play()


func _on_interface_closed() -> void:
    $CheevoButton.disabled = false
    $UpgradesButton.disabled = false
    $ButtonSound.play()
    fade(false, $StartLabel if on_start_screen else $GameOverLabel)
    fade(false, $StartButton)
    fade(false, $CheevoButton)
    fade(false, $UpgradesButton)
    $SFXToggle.show()
    $MusicToggle.show()
    fade(on_start_screen, $HighScore)
    fade(false, $Credits)
    $Tween.start()


func _on_AchievementsInterface_display_popup(achievement_name: String) -> void:
    if save_loaded:
        print('popup displayed')
        fade(false, $CheevoUnlocked)
        $CheevoUnlocked/CheevoLabel.set_text(achievement_name)
        yield(get_tree().create_timer(2), "timeout")
        fade(true, $CheevoUnlocked)