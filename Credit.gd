extends RigidBody2D

signal collected


func appear(position: Vector2) -> void:
    self.position = position
    $Tween.interpolate_property(self, 'scale', Vector2(0, 0), Vector2(1, 1), 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
    # $Tween.interpolate_property(self, 'visible', visible, true, 0.8, Tween.TRANS_CIRC, Tween.EASE_IN)
    $Tween.start()


func _on_start_game() -> void:
    queue_free()


func _disappear() -> void:
    $CollisionShape2D.set_deferred('disabled', true)
    $Tween.interpolate_property($Sprite, 'scale', $Sprite.scale, Vector2(0, 0), 0.2, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
    $Tween.interpolate_property(self, 'position', get_position(), get_position(), 1, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.start()
    yield(get_tree().create_timer(0.8), 'timeout')
    queue_free()


func _on_Credit_body_entered(body: Node) -> void:
    if body.is_in_group('Balls'):
        emit_signal("collected")
        body.play_effect()
        _disappear()
