extends RigidBody2D


func _ready():
    $Sprite.set_texture(load("res://Assets/Planets/Planet%d.png" % floor(rand_range(0, 9))))
    hide()


func _on_start_game() -> void:
    queue_free()


func appear(position: Vector2) -> void:
    self.position = position
    $Tween.interpolate_property(self, 'scale', Vector2(0, 0), Vector2(1, 1), 0.8, Tween.TRANS_CIRC, Tween.EASE_IN)
    $Tween.interpolate_property(self, 'visible', visible, true, 0.8, Tween.TRANS_CIRC, Tween.EASE_IN)
    $Tween.start()


func disappear(animate: bool, to_position: Vector2 = get_position()) -> void:
    $HitSound.play()
    $CollisionShape2D.set_deferred('disabled', true)
    $Tween.interpolate_property(self, 'scale', scale, Vector2(0, 0), 1, Tween.TRANS_CIRC, Tween.EASE_OUT)
    $Tween.interpolate_property(self, 'position', get_position(), to_position, 1, Tween.TRANS_CIRC, Tween.EASE_OUT)
    $Tween.interpolate_property(self, 'modulate', modulate, Color(1, 1, 1, 0), 0.5, Tween.TRANS_CIRC, Tween.EASE_OUT)
    $Tween.start()
    start_freeze()
    yield(get_tree().create_timer(1), 'timeout')
    queue_free()
    
    
func set_gravity(on: bool) -> void:
    gravity_scale = 0.5 if on else 0.0
    
    
func start_freeze() -> void:
    """Freezes the screen for 7.5 milliseconds"""
    get_tree().paused = true
    $Freeze.start()


func _on_Planet_body_entered(body):
    if body.is_in_group('Balls'):
        $CollisionShape2D.set_deferred('disabled', true)
        disappear(true)


func _on_Freeze_timeout():
    get_tree().paused = false
