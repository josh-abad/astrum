extends Node

export (PackedScene) var Planet
export (PackedScene) var Spike

var active := false

onready var Spark = load("res://Spark.tscn")
onready var ScoredPopup = load("res://ScoredPopup.tscn")

var score: int = 0
var high_score: int = 0
var multiplier: int = 1
var multiplier_active: bool = false
var music_on: bool = false
var sfx_on: bool = false

onready var sfx: Dictionary = {
    "black_hole_active": $BlackHoleActiveSound,
    "black_hole_transition": $BlackHoleTransitionSound,
    "hit": $HitSound,
    "bounce": $BounceSound,
    "button": $ButtonSound    
}

func _ready() -> void:
    randomize()
    if music_on:
        $AmbientSound.play()
    load_game()
    $HUD.hide_high_score(true)


func save() -> Dictionary:
    return {
        "high_score" : high_score,
    }


func save_game() -> void:
    var save_game = File.new()
    save_game.open("user://savegame.save", File.WRITE)
    save_game.store_line(to_json(save()))
    save_game.close()
    
    
func load_game() -> void:
    var save_game = File.new()
    if not save_game.file_exists("user://savegame.save"):
        return
    
    save_game.open("user://savegame.save", File.READ)
    var line = parse_json(save_game.get_line())
    _update_high_score(line["high_score"])
    save_game.close()


func new_game() -> void:
    _play_sfx("button")
    _update_score(0)
    _update_multiplier(1)
    $HUD.hide_high_score(score >= high_score)
    $StartTimer.start()
    $Player.start()
    active = true
    $Tween.start()
    _dampen_ambient_music(false)
    
    
func _play_sfx(key: String) -> void:
    if sfx_on:
        sfx.get(key).play()
        
        
func _stop_sfx(key: String) -> void:
    sfx.get(key).stop()
    
    
func scored(special: bool, position: Vector2) -> void:
    if not active:
        return
    Engine.time_scale = 0.125
    _update_score(score + (2 if special else 1) * multiplier)
    if multiplier_active:
        _update_multiplier(multiplier + 1)
    else:
        multiplier_active = true
    $ComboTimer.start()
    if score > high_score:
        $HUD.hide_high_score(true)
        _update_high_score(score)
        save_game()

    _play_sfx("hit")
    _play_sfx("bounce")
    var popup = ScoredPopup.instance()
    add_child(popup)
    popup.display(position, (2 if special else 1) * multiplier)
    
    _add_spark(Palette.PINK if special else Palette.ORANGE, position)
    
    
func _add_spark(color: Color, position: Vector2) -> void:
    var spark = Spark.instance()
    add_child(spark)
    spark.set_color(color)
    spark.set_position(position)
    spark.set_emitting(true)
    yield(get_tree().create_timer(6), "timeout")
    spark.queue_free()
    

func _update_score(value: int) -> void:
    score = value
    $HUD.update_score(score)


func _update_high_score(value: int) -> void:
    high_score = value
    $HUD.update_high_score(high_score)


func _update_multiplier(value: int) -> void:
    multiplier = value
    $HUD.update_multiplier(multiplier)
    

func _get_random_position() -> Vector2:
    randomize()
    var x = $Player.position.x + $Player.direction.x + rand_range(100, 300)
    var y = $Player.position.y + $Player.direction.y + rand_range(100, 300)
    return Vector2(x, y)


func _on_PlanetTimer_timeout() -> void:
    if active and $Player.moving:
        var planet = Planet.instance()
        add_child(planet)
        planet.appear(_get_random_position())
        if planet.connect("scored", self, "scored"):
            pass
        if $HUD.connect("start_game", planet, "_on_start_game"):
            pass


func _on_StartTimer_timeout():
    $PlanetTimer.start()
    $BlackHoleTimer.start()
    $SpikeTimer.start()


func _on_BlackHole_absorb() -> void:
    $BlackHole.disappear()
    $Player.disappear()
    $HUD.show_game_over()
    active = false
    _dampen_ambient_music(true)


func _dampen_ambient_music(yes: bool) -> void:
    AudioServer.set_bus_effect_enabled(1, 0, yes)


func _on_BlackHoleTimer_timeout() -> void:
    if active and $Player.moving:
        $HUD.disable_warning(false)
        yield(get_tree().create_timer(1), "timeout")
        _play_sfx("black_hole_transition")
        _play_sfx("black_hole_active")
        $BlackHole.appear(_get_random_position())
    else:
        $BlackHoleTimer.start()


func _on_BlackHole_inactive() -> void:
    if active and $Player.moving:
        _stop_sfx("black_hole_active")
        _play_sfx("black_hole_transition")
        $BlackHoleTimer.set_wait_time(rand_range(2, 4))
        $BlackHoleTimer.start()
        $HUD.disable_warning(true)
        

func _on_Comet_slo_mo() -> void:
    Engine.time_scale = 0.25
    $Tween.interpolate_property($ParallaxBackground/ParallaxLayer/BlurLayer/Blur.material, "shader_param/blurSize", $ParallaxBackground/ParallaxLayer/BlurLayer/Blur.material.get_shader_param("blurSize"), 15, 0.2, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.start()
    $SlowMotionTimer.start()


func _on_Comet_nor_mo() -> void:
    _play_sfx("bounce")
    Engine.time_scale = 1
    $Tween.interpolate_property($ParallaxBackground/ParallaxLayer/BlurLayer/Blur.material, "shader_param/blurSize", $ParallaxBackground/ParallaxLayer/BlurLayer/Blur.material.get_shader_param("blurSize"), 0, 0.2, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.start()


func on_Player_destroyed(player_position) -> void:
    _play_sfx("hit")
    $HUD.show_game_over()
    active = false
    _dampen_ambient_music(true)
    _add_spark(Palette.BLUE, player_position)


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
    _update_multiplier(1)
    multiplier_active = false


func _on_SlowMotionTimer_timeout() -> void:
    print('sanity check')
    Engine.time_scale = 1
