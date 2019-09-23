extends RigidBody2D

signal scored(special, position)
signal disappeared

onready var special: bool = rand_range(0, 100) <= 30


func _ready() -> void:
    $Sprite.self_modulate = Palette.PINK if special else Palette.ORANGE
    gravity_scale = 1 if randi() % 2 == 1 else -1
    # hide()


func _on_start_game() -> void:
    queue_free()


func appear(position: Vector2) -> void:
    self.position = position
    $Tween.interpolate_property(self, 'scale', Vector2(0, 0), Vector2(1, 1), 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
    # $Tween.interpolate_property(self, 'visible', visible, true, 0.8, Tween.TRANS_CIRC, Tween.EASE_IN)
    $Tween.start()
    $VisibilityTimer.start()


func disappear() -> void:
    $CollisionShape2D.set_deferred('disabled', true)
    $Tween.interpolate_property($Sprite, 'scale', $Sprite.scale, Vector2(0, 0), 0.2, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
    $Tween.interpolate_property(self, 'position', get_position(), get_position(), 1, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.interpolate_property(self, 'modulate', modulate, Color(1, 1, 1, 0), 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.start()
    $DisappearTimer.start()


func _on_Planet_body_entered(body: PhysicsBody2D) -> void:
    if body.is_in_group('Balls'):
        emit_signal("scored", special, position)
        body.play_effect()
        disappear()
        

func _on_VisibilityTimer_timeout() -> void:
    emit_signal("disappeared")
    queue_free()


func _on_VisibilityNotifier2D_screen_exited() -> void:
    $VisibilityTimer.start()


func _on_VisibilityNotifier2D_screen_entered() -> void:
    $VisibilityTimer.stop()


func _on_DisappearTimer_timeout() -> void:
    queue_free()
