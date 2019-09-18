extends RigidBody2D


func _ready() -> void:
    # $Sprite.set_texture(planets[randi() % planets.size()])
    # _rand_scale()
    hide()


func _on_start_game() -> void:
    queue_free()


func _rand_scale() -> void:
    var scale: float = rand_range(0.5, 1.0)
    $Sprite.set_scale(Vector2(scale, scale))
    $CollisionShape2D.set_scale(Vector2(scale, scale))


func appear(position: Vector2) -> void:
    self.position = position
    $Tween.interpolate_property(self, 'visible', visible, true, 0.8, Tween.TRANS_CIRC, Tween.EASE_IN)
    $Tween.start()


func disappear(to_position: Vector2 = get_position()) -> void:
    $HitSound.play()
    $CollisionShape2D.set_deferred('disabled', true)
    # $Tween.interpolate_property($Sprite, 'scale', $Sprite.scale, Vector2(0, 0), 1, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.interpolate_property(self, 'position', get_position(), to_position, 1, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.interpolate_property(self, 'modulate', modulate, Color(1, 1, 1, 0), 0.01, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.start()
    # Freeze.freeze()        
    yield(get_tree().create_timer(1), 'timeout')
    queue_free()
    
    
func set_gravity(on: bool) -> void:
    gravity_scale = 0.5 if on else 0.0


func _on_Planet_body_entered(body: PhysicsBody2D) -> void:
    if body.is_in_group('Balls'):
        body._on_Comet_body_entered(self)
        disappear()
        Engine.time_scale = 0.125
        yield(get_tree().create_timer(1), "timeout")
        # Engine.time_scale = 1  
