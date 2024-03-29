extends Node

signal save_loaded

export (PackedScene) var Planet
export (PackedScene) var Spike
export (PackedScene) var Collectible
export (PackedScene) var Spark
export (PackedScene) var ScoredPopup

const MAX_ENEMIES: int = 15

var max_multiplier: int = 2
var COUNTDOWN_RATE_FAST: float = 50.0
var COUNTDOWN_RATE_NORMAL: float = 30.0

var bh_wait_time_upper: int = 6
var bh_wait_time_lower: int = 3

var active := false

var score: int = 0
var high_score: int = 0
var multiplier: int = 1
var health: float = 100
var enemies_spawned: int = 0
var combo: bool = false
var ignorata: bool = false
var save_loaded = false
var player_moved = false


func _ready() -> void:
    if connect("save_loaded", $HUD, "_on_save_loaded"):
        pass
    if CreditManager.connect("changed", self, "_on_credits_changed"):
        pass
    if SettingsManager.connect("changed", self, "_on_settings_changed"):
        pass
    if UpgradeManager.connect("changed", self, "_on_upgrades_changed"):
        pass
    randomize()
    load_game()    
    $AmbientSound.play()
    $HUD.hide_high_score(true)
    _reset_achievements()
    _enable_background_blur(true, 0)


func _on_credits_changed() -> void:
    if save_loaded:
        save_game()


func _on_settings_changed() -> void:
    _mute_music(not SettingsManager.is_music_on())
    _mute_sfx(not SettingsManager.is_sfx_on())
    if save_loaded:
        save_game()


func _on_upgrades_changed(upgrade_name: String) -> void:
    _apply_upgrades(upgrade_name)
    if save_loaded:
        save_game()


func _on_completed_achievements_changed(achievement_name: String) -> void:
    if achievement_name:
        pass
    if save_loaded:
        save_game()


func _process(delta: float) -> void:
    if active and player_moved:
        _update_health(health - (COUNTDOWN_RATE_NORMAL if $Player.moving else COUNTDOWN_RATE_FAST) * delta)
    
    if round(health) == 0:
        $BlackHole.disappear()
        $Player.disappear()
        _game_over()


func save() -> Dictionary:
    return {
        "credits": CreditManager.get_credits(),
        "high_score": high_score,
        "music_on": SettingsManager.is_music_on(),
        "sfx_on": SettingsManager.is_sfx_on(),
        "upgrades": UpgradeManager.get_upgrades()
    }


func save_game() -> void:
    var save_game := File.new()
    if save_game.open("user://savegame.save", File.WRITE):
        pass
    save_game.store_line(to_json(save()))
    save_game.close()
    
    
func load_game() -> void:
    var save_game = File.new()
    if not save_game.file_exists("user://savegame.save"):
        return
    
    save_game.open("user://savegame.save", File.READ)
    var line = parse_json(save_game.get_line())
    if line.has("credits"):
        CreditManager.set_credits(line["credits"])
    if line.has("high_score"):
        _update_high_score(line["high_score"])
    if line.has("music_on") and line.has("sfx_on"):
        SettingsManager.set_music_on(line["music_on"])
        SettingsManager.set_sfx_on(line["sfx_on"])
    if line.has("upgrades"):
        UpgradeManager.set_upgrades(line["upgrades"])
    save_game.close()
    save_loaded = true
    emit_signal("save_loaded")


func new_game() -> void:
    player_moved = false
    enemies_spawned = 0
    _enable_background_blur(false)
    _update_score(0)
    _update_health(100)
    _update_multiplier(0)
    $HUD.hide_high_score(score >= high_score)
    $StartTimer.start()
    $Player.start()
    $Tween.start()
    _dampen_sfx(false)
    _dampen_ambient_music(false)
    
   
func _reset_achievements() -> void:
    """ These achievements must be completed in one round """
    $HUD.reset_achievement("score10Points")    
    $HUD.reset_achievement("score100Points")
    $HUD.reset_achievement("score1000Points")
    $HUD.reset_achievement("rosea")
    $HUD.reset_achievement("ignorata")
    
    
func _game_over() -> void:
    Engine.time_scale = 1
    $HUD.show_game_over()
    _enable_background_blur(true, 0)    
    active = false
    _dampen_sfx(true)
    _dampen_ambient_music(true)
    
    $HUD.increment_achievement("stella_mortem", 1)
    
    # These achievements must be completed in one round
    _reset_achievements()

    
func scored(special: bool, position: Vector2) -> void:
    if not active:
        return
        
    if special:
        $HUD.increment_achievement("rosea", 1)
    else:
        $HUD.reset_achievement("rosea")
        
    var points = (2 if special else 1) * (multiplier if multiplier != 0 else 1)
    $HUD.increment_achievement("score10Points", points)
    $HUD.increment_achievement("score100Points", points)
    $HUD.increment_achievement("score1000Points", points)
    
    if ignorata:
        $HUD.increment_achievement("ignorata", 1)
    else:
        $HUD.reset_achievement("ignorata")
        ignorata = true
    
    _update_health(health + (COUNTDOWN_RATE_FAST / 1.5 if special else COUNTDOWN_RATE_NORMAL / 1.5))
    enemies_spawned -= 1
    combo = true
    Engine.time_scale = 0.25
    _update_score(score + points)
    _update_multiplier(multiplier + 1)
    if multiplier == 8:
        $HUD.increment_achievement("sequentia", 1)
    $ComboTimer.start()
    if score > high_score:
        $HUD.hide_high_score(true)
        _update_high_score(score)
        save_game()

    $HitSound.play()
    var popup = ScoredPopup.instance()
    if $HUD.connect("start_game", popup, "_on_start_game"):
        pass
    add_child(popup)
    popup.display(position, points, Palette.PINK if special else Palette.ORANGE)
    _add_spark(Palette.PINK if special else Palette.ORANGE, position)
    
    
func _add_spark(color: Color, position: Vector2) -> void:
    var spark = Spark.instance()
    add_child(spark)    
    if $HUD.connect("start_game", spark, "_on_start_game"):
        pass
    spark.set_color(color)
    spark.set_position(position)
    spark.set_emitting(true)
    

func _update_score(value: int) -> void:
    score = value
    $HUD.update_score(score)


func _update_high_score(value: int) -> void:
    high_score = value
    $HUD.update_high_score(high_score)


func _update_health(value: float) -> void:
    if value < 0 or value > 100:
        return 
    health = value
    $HUD.update_health_bar(health)


func _update_multiplier(value: int) -> void:
    if value <= max_multiplier:
        multiplier = value
        $HUD.update_multiplier(multiplier)
    
    
func _get_random_position() -> Vector2:
    randomize()
    var x = $Player.position.x + $Player.direction.x + rand_range(100, 300)
    var y = $Player.position.y + $Player.direction.y + rand_range(100, 300)
    return Vector2(x, y)


func _on_PlanetTimer_timeout() -> void:
    if active and $Player.moving and enemies_spawned <= MAX_ENEMIES:
        enemies_spawned += 1
        var planet = Planet.instance()
        add_child(planet)
        planet.appear(_get_random_position())
        if planet.connect("scored", self, "scored"):
            pass
        if planet.connect("disappeared", self, "_planet_disappeared"):
            pass
        if $HUD.connect("start_game", planet, "_on_start_game"):
            pass


func _planet_disappeared() -> void:
    enemies_spawned -= 1


func _on_StartTimer_timeout():
    active = true    
    $PlanetTimer.start()
    $BlackHoleTimer.start()
    $SpikeTimer.start()
    $CollectibleTimer.start()


func _on_BlackHole_absorb() -> void:
    $BlackHole.disappear()
    $Player.disappear()
    _game_over()


func _dampen_ambient_music(yes: bool) -> void:
    AudioServer.set_bus_effect_enabled(1, 0, yes)


func _dampen_sfx(yes: bool) -> void:
    AudioServer.set_bus_effect_enabled(3, 0, yes)
    

func _on_BlackHoleTimer_timeout() -> void:
    if active and $Player.moving:
        $HUD.disable_warning(false)
        yield(get_tree().create_timer(1), "timeout")
        $BlackHoleTransitionSound.play()
        $BlackHoleActiveSound.play()
        $BlackHole.appear(_get_random_position())
    else:
        $BlackHoleTimer.start()


func _on_BlackHole_inactive() -> void:
    $BlackHoleActiveSound.stop()
    if active and $Player.moving:
        $BlackHoleTransitionSound.play()
        $BlackHoleTimer.set_wait_time(_update_bh_wait_time())
        $BlackHoleTimer.start()
        $HUD.disable_warning(true)
        

func _update_bh_wait_time() -> float:
    var modifier: int = 0
    if score > 50:
        modifier += 1
        if score > 100:
            modifier += 1
            if score > 150:
                modifier += 1
    return rand_range(bh_wait_time_lower - modifier, bh_wait_time_upper - modifier)


func _enable_background_blur(yes: bool, layer: int = -2) -> void:
    $Tween.interpolate_property(
        $ParallaxBackground/ParallaxLayer/BlurLayer/Blur.material,
        "shader_param/blurSize",
        $ParallaxBackground/ParallaxLayer/BlurLayer/Blur.material.get_shader_param("blurSize"),
        20 if yes else 0,
        0.2,
        Tween.TRANS_QUAD,
        Tween.EASE_OUT
    )
    $Tween.start()
    $ParallaxBackground/ParallaxLayer/BlurLayer.layer = layer
    $Shade.visible = layer == 0


func _on_Comet_slo_mo(temporary: bool = true) -> void:
    Engine.time_scale = 0.25
    _enable_background_blur(true)
    if temporary:
        $SlowMotionTimer.start()


func _on_Comet_nor_mo() -> void:
    player_moved = true
    $BounceSound.play()
    Engine.time_scale = 1
    _enable_background_blur(false)
    ignorata = false
    if combo:
        combo = false
    else:
        _reset_combo()
        
        
func _reset_combo() -> void:
    _update_multiplier(0)


func on_Player_destroyed(player_position: Vector2) -> void:
    $HitSound.play()
    _add_spark(Palette.BLUE, player_position)    
    _game_over()


func _on_SpikeTimer_timeout() -> void:
    if active and $Player.moving:
        var spike = Spike.instance()
        add_child(spike)
        spike.position = _get_random_position()
        if spike.connect("destroyed_player", self, "on_Player_destroyed"):
            pass
        if $HUD.connect("start_game", spike, "_on_start_game"):
            pass


func _on_ComboTimer_timeout() -> void:
    _reset_combo()


func _on_SlowMotionTimer_timeout() -> void:
    Engine.time_scale = 1
    if active:
        $Tween.interpolate_property($ParallaxBackground/ParallaxLayer/BlurLayer/Blur.material, "shader_param/blurSize", $ParallaxBackground/ParallaxLayer/BlurLayer/Blur.material.get_shader_param("blurSize"), 0, 0.2, Tween.TRANS_QUAD, Tween.EASE_OUT)
        $Tween.start()


func _mute_sfx(yes: bool) -> void:
    AudioServer.set_bus_mute(3, yes)
    AudioServer.set_bus_mute(2, yes)


func _mute_music(yes: bool) -> void:
    AudioServer.set_bus_mute(1, yes)    


func _on_CollectibleTimer_timeout() -> void:
    if active and $Player.moving and enemies_spawned <= MAX_ENEMIES:
        var collectible = Collectible.instance()
        add_child(collectible)
        collectible.appear(_get_random_position())
        if collectible.connect("collected", self, "_on_Collectible_collected"):
            pass
        if $HUD.connect("start_game", collectible, "_on_start_game"):
            pass
    $CollectibleTimer.set_wait_time(rand_range(2, 4))
    $CollectibleTimer.start()


func _on_Collectible_collected(is_health: bool) -> void:
    $CollectibleSound.play()
    if is_health:
        _update_health(100)
    else:
        CreditManager.set_credits(CreditManager.get_credits() + 100)


func _apply_upgrades(upgrade_name) -> void:
    if upgrade_name == "speed" or upgrade_name == UpgradeManager.ALL:
        var speed_level: float = UpgradeManager.get_upgrade("speed")["level"]
        match speed_level:
            1.0:
                $Player.speed = 1250
            2.0:
                $Player.speed = 1500
            3.0:
                $Player.speed = 1750
    
    if upgrade_name == "health" or upgrade_name == UpgradeManager.ALL:        
        var health_level: float = UpgradeManager.get_upgrade("health")["level"]      
        match health_level:
            1.0:
                COUNTDOWN_RATE_FAST = 40
                COUNTDOWN_RATE_NORMAL = 20
            2.0:
                COUNTDOWN_RATE_FAST = 30
                COUNTDOWN_RATE_NORMAL = 10
            3.0:
                COUNTDOWN_RATE_FAST = 20
                COUNTDOWN_RATE_NORMAL = 0
            
    if upgrade_name == "combo" or upgrade_name == UpgradeManager.ALL:
        var combo_level: float = UpgradeManager.get_upgrade("combo")["level"]         
        match combo_level:
            1.0:
                max_multiplier = 4
            2.0:
                max_multiplier = 6
            3.0:
                max_multiplier = 8
            