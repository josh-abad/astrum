extends Node

export (PackedScene) var Planet
export (PackedScene) var Star

var active := false
onready var bg_modulate = $ParallaxBackground/ParallaxLayer/BackgroundModulate.color
onready var stars_modulate = $ParallaxStars/ParallaxLayer/StarsModulate.color
onready var main_modulate = $MainModulate.color

var score: int = 0
var high_score: int = 0
var power: int = 0

func _ready() -> void:
    randomize()
    # $AmbientMusic.play()


func _process(delta: float) -> void:
    _set_planet_gravity($BlackHole.active)


func new_game() -> void:
    _update_power(0)
    _update_score(0)
    $StartTimer.start()
    $Comet.start()
    active = true
    $Tween.interpolate_property($ParallaxBackground/ParallaxLayer/BackgroundModulate, 'color', $ParallaxBackground/ParallaxLayer/BackgroundModulate.color, bg_modulate, 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)    
    $Tween.interpolate_property($ParallaxStars/ParallaxLayer/StarsModulate, 'color', $ParallaxStars/ParallaxLayer/StarsModulate.color, stars_modulate, 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)    
    $Tween.interpolate_property($MainModulate, 'color', $MainModulate.color, main_modulate, 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)    
    $Tween.start()


func _on_Comet_dropped() -> void:
    $HUD.show_game_over()
    $BlackHole.disappear()
    active = false


func _on_Comet_scored(planet_position) -> void:
    _update_score(score + 1)
    if score > high_score:
        _update_high_score(score)
    $ScoredPopup.display(planet_position, '+1')
    $PlanetSpark.set_position(planet_position)
    $PlanetSpark.set_emitting(true)
    _update_power(power + 5)
    _brighten($ParallaxBackground/ParallaxLayer/BackgroundModulate)
    _brighten($ParallaxStars/ParallaxLayer/StarsModulate)
    _brighten($MainModulate)


func _update_score(value: int) -> void:
    score = value
    $HUD.update_score(score)


func _update_high_score(value: int) -> void:
    high_score = value
    $HUD.update_high_score(high_score)


func _update_power(value: int) -> void:
    power = value if value <= 100 else 100
    $HUD.update_power(power)


func _brighten(canvas: CanvasModulate) -> void:
    var color = canvas.color
    if color.r <= 0.95:
        $Tween.interpolate_property(canvas, 'color', canvas.color, Color(color.r + 0.05, color.g + 0.05, color.b + 0.05), 0.4, Tween.TRANS_QUAD, Tween.EASE_IN)
        $Tween.start()


func _get_random_position(off_screen: bool = false) -> Vector2:
    var x = $Comet.position.x + rand_range(-50, 50)
    var y = $Comet.position.y - (rand_range(640, 740) if off_screen else rand_range(250, 500))
    return Vector2(x, y)


func _on_PlanetTimer_timeout() -> void:
    if active:
        var planet = Planet.instance()
        add_child(planet)
        planet.appear(_get_random_position(true))
        $HUD.connect("start_game", planet, "_on_start_game")


func _on_StartTimer_timeout():
    $PlanetTimer.start()
    $BlackHoleTimer.start()
    $StarTimer.start()


func _set_planet_gravity(on: bool) -> void:
    var planets: Array = get_tree().get_nodes_in_group('Planets')
    for planet in planets:
        if is_instance_valid(planet):
            planet.set_gravity(on)
            if not on:
                $Tween.interpolate_property(planet, 'linear_velocity', planet.linear_velocity, Vector2(0, 0), 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
                $Tween.start()


func _on_BlackHole_absorb():
    $BlackHole.disappear()
    $Comet.disappear()
    $HUD.show_game_over()
    $Comet.dropped_sound_transition()
    active = false


func _on_BlackHoleTimer_timeout() -> void:
    if score >= 10:
        $BlackHole.appear(_get_random_position())
    else:
        $BlackHoleTimer.start()


func _on_BlackHole_inactive() -> void:
    if active:
        $BlackHoleTimer.set_wait_time(rand_range(2, 8))
        $BlackHoleTimer.start()


func _on_Timer_timeout() -> void:
    if active:
        var star: Object = Star.instance()
        star.connect('collect', self, '_on_Star_collect')
        add_child(star)
        star.appear(_get_random_position())
        $HUD.connect("start_game", star, "_on_start_game")
        
        
func _on_Star_collect(star_position) -> void:
    _update_score(score + 2)
    if score > high_score:
        _update_high_score(score)
    $Comet.pulse()
    $ScoredPopup.display(star_position, '+2')
    _update_power(power + 10)
    

func _on_HUD_activate_power() -> void:
    if power >= 10:
        $Comet.use_power()
        _update_power(power - 10)
