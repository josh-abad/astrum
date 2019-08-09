extends Node

export (PackedScene) var Planet
export (PackedScene) var Star

var active := false
onready var bg_modulate = $ParallaxBackground/ParallaxLayer/BackgroundModulate.color
onready var stars_modulate = $ParallaxStars/ParallaxLayer/StarsModulate.color
onready var main_modulate = $MainModulate.color


func _ready():
    randomize()
    $AmbientMusic.play()


func _process(delta: float) -> void:
    set_planet_gravity($BlackHole.active)


func new_game() -> void:
    $Comet.power = 0
    $HUD.reset_power()
    $Comet.set_score(0)
    $HUD.set_label('0')
    $StartTimer.start()
    $Comet.start()
    active = true
    $ParallaxBackground/ParallaxLayer/BackgroundModulate.color = bg_modulate
    $ParallaxStars/ParallaxLayer/StarsModulate.color = stars_modulate
    $MainModulate.color = main_modulate


func _on_Comet_dropped() -> void:
    $HUD.show_game_over()
    active = false


func _on_Comet_scored(planet_position, points) -> void:
    $HUD.set_label(str($Comet.get_score()))
    $ScoredPopup.display(planet_position, '+' + str(points))
    if ($Comet.power <= 95):
        $Comet.power += 5
        $HUD.increase_power(5)
        brighten($ParallaxBackground/ParallaxLayer/BackgroundModulate)
        brighten($ParallaxStars/ParallaxLayer/StarsModulate)
        brighten($MainModulate)


func brighten(canvas: CanvasModulate) -> void:
    var color = canvas.color
    canvas.color = Color(color.r + 0.05, color.g + 0.05, color.b + 0.05)


func get_random_position(off_screen: bool = false) -> Vector2:
    var x = $Comet.position.x + rand_range(-50, 50)
    var y = $Comet.position.y - (rand_range(640, 740) if off_screen else rand_range(250, 500))
    return Vector2(x, y)


func _on_PlanetTimer_timeout() -> void:
    if active:
        var planet = Planet.instance()
        add_child(planet)
        planet.appear(get_random_position(true))
        $HUD.connect("start_game", planet, "_on_start_game")


func _on_StartTimer_timeout():
    $PlanetTimer.start()
    $BlackHoleTimer.start()
    $StarTimer.start()


func set_planet_gravity(on: bool) -> void:
    var planets: Array = get_tree().get_nodes_in_group('Planets')
    for planet in planets:
        if is_instance_valid(planet):
            planet.set_gravity(on)
            if not on:
                # TODO: planets should gravitate towards black hole even if they're past it
                # TODO: add juice to black hole expansion
                $Tween.interpolate_property(planet, 'linear_velocity', planet.linear_velocity, Vector2(0, 0), 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
                $Tween.start()


func _on_BlackHole_absorb():
    $BlackHole.disappear()
    $Comet.disappear()
    $HUD.show_game_over()
    $Comet.dropped_sound_transition()
    active = false


func _on_BlackHoleTimer_timeout() -> void:
    if $Comet.get_score() >= 10:
        $BlackHole.appear(get_random_position())
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
        star.appear(get_random_position())
        $HUD.connect("start_game", star, "_on_start_game")
        
        
func _on_Star_collect(star_position) -> void:
    $Comet.set_score($Comet.get_score() + 2)
    $Comet._start_tween()
    $HUD.set_label(str($Comet.get_score()))
    $ScoredPopup.display(star_position, '+2')
    if ($Comet.power <= 90):
        $Comet.power += 10
        $HUD.increase_power(10)
    

func _on_Comet_used_power() -> void:
    $Comet.power -= 10
    $HUD.decrease_power(10)