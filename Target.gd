extends RigidBody2D


func _ready():
    $Sprite.set_texture(load("res://Assets/Planets/Planet%d.png" % rand_range(0, 9)))
    hide()


func appear(position: Vector2) -> void:
    show()
    self.position = position
    $Tween.interpolate_property(self, 'scale', Vector2(0, 0), Vector2(1, 1), 0.8, Tween.TRANS_CIRC, Tween.EASE_IN)
    $Tween.interpolate_property(self, 'visible', visible, true, 0.8, Tween.TRANS_CIRC, Tween.EASE_IN)
    $Tween.start()


func disappear() -> void:
    $CollisionShape2D.set_deferred('disabled', true)
    $Tween.interpolate_property(self, 'scale', scale, Vector2(0, 0), 1, Tween.TRANS_CIRC, Tween.EASE_OUT)
    $Tween.interpolate_property(self, 'visible', visible, false, 1, Tween.TRANS_CIRC, Tween.EASE_OUT)
    $Tween.start()
    start_freeze()
    yield(get_tree().create_timer(0.9), 'timeout')
    queue_free()
    

func start_freeze() -> void:
    """Freezes the screen for 7.5 milliseconds"""
    get_tree().paused = true
    $Freeze.start()


func _on_Circle_body_entered(body):
    if body.is_in_group('Balls'):
        $Spark.set_emitting(true)
        $HitSound.play()
        disappear()


func _on_Freeze_timeout():
    get_tree().paused = false
    if $Sprite.get_transform().get_scale().x < 0.25:
        queue_free()
