extends Node

export (PackedScene) var Planet
export (PackedScene) var Star
export (PackedScene) var Shield

var active := false

onready var Spark = load("res://Spark.tscn")
onready var ScoredPopup = load("res://ScoredPopup.tscn")

var score: int = 0
var high_score: int = 0
var power: int = 0
var shield: float = 0
var shield_on: bool = false


func _ready() -> void:
    randomize()
    $AmbientSound.play()


func _process(delta: float) -> void:
    if delta:
        pass
    _set_planet_gravity($BlackHole.active)
    if shield_on:
        _update_shield(shield - 0.1)
        if shield <= 0:
            _disable_shield(true)


func new_game() -> void:
    _update_power(0)
    _update_score(0)
    _update_shield(0)
    $HUD.hide_high_score(score >= high_score)
    $StartTimer.start()
    $Comet.start()
    active = true
    $Tween.start()


func _on_Comet_dropped() -> void:
    $HUD.show_game_over()
    $BlackHole.disappear()
    _update_power(0)
    active = false


func _on_Comet_scored(planet_position: Vector2) -> void:
    if not active:
        return
    _update_score(score + 1)
    if score > high_score:
        $HUD.hide_high_score(true)
        _update_high_score(score)
    _update_power(power + 5)
    
    var popup = ScoredPopup.instance()
    add_child(popup)
    popup.display(planet_position, 1)
    
    var spark = Spark.instance()
    add_child(spark)
    spark.set_position(planet_position)
    spark.set_emitting(true)
    yield(get_tree().create_timer(3), "timeout")
    spark.queue_free()
    

func _update_score(value: int) -> void:
    score = value
    $HUD.update_score(score)


func _update_high_score(value: int) -> void:
    high_score = value
    $HUD.update_high_score(high_score)


func _update_power(value: int) -> void:
    power = value if value <= 100 else 100
    $HUD.update_power(power)


func _update_shield(value: float) -> void:
    shield = value
    $HUD.update_shield(shield)


func _disable_shield(value: bool) -> void:
    shield_on = not value
    $HUD.update_shield_state(shield_on)
    $Comet.enable_shield(shield_on)


func _get_random_position(off_screen: bool = false) -> Vector2:
    randomize()
    var x = $Comet.position.x + rand_range(-50, 50)
    var y = $Comet.position.y - (rand_range(640, 740) if off_screen else rand_range(250, 500))
    return Vector2(x, y)


func _on_PlanetTimer_timeout() -> void:
    if active:
        var planet = Planet.instance()
        add_child(planet)
        planet.appear(_get_random_position(true))
        if $HUD.connect("start_game", planet, "_on_start_game"):
            pass


func _on_StartTimer_timeout():
    $PlanetTimer.start()
    $BlackHoleTimer.start()
    $StarTimer.start()
    $ShieldTimer.start()


func _set_planet_gravity(on: bool) -> void:
    var planets: Array = get_tree().get_nodes_in_group('Planets')
    for planet in planets:
        if is_instance_valid(planet):
            planet.set_gravity(on)
            if not on:
                $Tween.interpolate_property(planet, 'linear_velocity', planet.linear_velocity, Vector2(0, 0), 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
                $Tween.start()


func _on_BlackHole_absorb() -> void:
    $BlackHole.disappear()
    $Comet.disappear()
    $HUD.show_game_over()
    active = false
    _update_power(0)


func _on_BlackHoleTimer_timeout() -> void:
    if score >= 10:
        $HUD.disable_warning(false)
        yield(get_tree().create_timer(1), "timeout")        
        $BlackHole.appear(_get_random_position())
    else:
        $BlackHoleTimer.start()


func _on_BlackHole_inactive() -> void:
    if active:
        $BlackHoleTimer.set_wait_time(rand_range(2, 8))
        $BlackHoleTimer.start()
        $HUD.disable_warning(true)


func _on_Timer_timeout() -> void:
    if active:
        var star: Object = Star.instance()
        if star.connect('collect', self, '_on_Star_collect'):
            pass
        add_child(star)
        star.appear(_get_random_position())
        if $HUD.connect("start_game", star, "_on_start_game"):
            pass
        
        
func _on_Star_collect(star_position: Vector2) -> void:
    if not active:
        return
    _update_score(score + 2)
    if score > high_score:
        _update_high_score(score)
    _update_power(power + 10)        
    $Comet.pulse()
    
    var popup = ScoredPopup.instance()
    add_child(popup)
    popup.display(star_position, 2)
    
    
func _on_Shield_collect() -> void:
    if not active:
        return
    if not shield_on:
        _update_shield(shield + 25)
    $Comet.pulse()
    

func _on_HUD_activate_power() -> void:
    if power >= 10:
        $Comet.use_power()
        _update_power(power - 10)


func _on_Comet_shielded() -> void:
    $BlackHole.disappear(true)


func _on_ShieldTimer_timeout() -> void:
    if active and not shield_on:
        var shield: Object = Shield.instance()
        if shield.connect('collect', self, '_on_Shield_collect'):
            pass
        add_child(shield)
        shield.appear(_get_random_position())
        if $HUD.connect("start_game", shield, "_on_start_game"):
            pass


func _on_HUD_activate_shield() -> void:
    if shield > 0:
        _disable_shield(false)
        