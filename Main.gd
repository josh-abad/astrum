extends Node

export (PackedScene) var Planet
export (PackedScene) var Star

var active := false


func _ready():
    randomize()
    $AmbientMusic.play()


func _process(delta: float) -> void:
    set_planet_gravity($BlackHole.active)


func new_game() -> void:
    $Comet.set_score(0)
    $HUD.set_label('0')
    $StartTimer.start()
    $Comet.start()
    active = true


func _on_Comet_dropped() -> void:
    $HUD.show_game_over()
    active = false


func _on_Comet_scored(planet_position, points) -> void:
    $HUD.set_label(str($Comet.get_score()))
    $ScoredPopup.display(planet_position, '+' + str(points))


func get_random_position(off_screen: bool = false) -> Vector2:
    var x = $Comet.position.x + rand_range(-50, 50)
    var y = $Comet.position.y - (rand_range(640, 740) if off_screen else rand_range(250, 500))
    return Vector2(x, y)


func _on_PlanetTimer_timeout() -> void:
    if active:
        var planet = Planet.instance()
        add_child(planet)
        planet.appear(get_random_position(true))


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
                # TODO: tween the planets' braking
                # TODO: planets should gravitate towards black hole even if they're past it
                # TODO: add juice to black hole expansion
                # TODO: expand black hole past scale of 1.25
                planet.set_linear_velocity(Vector2(0, 0))


func _on_BlackHole_absorb():
    $BlackHole.disappear()
    $Comet.disappear()
    $HUD.show_game_over()
    $Comet.dropped_sound_transition()
    active = false


func _on_BlackHoleTimer_timeout() -> void:
    $BlackHole.appear(get_random_position())


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
        
        
func _on_Star_collect(star_position) -> void:
    $Comet.set_score($Comet.get_score() + 2)
    $Comet._start_tween()
    $HUD.set_label(str($Comet.get_score()))
    $ScoredPopup.display(star_position, '+2')
