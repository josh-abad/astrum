extends RigidBody2D

signal scored(special, position)

onready var special: bool = rand_range(0, 100) <= 30


func _ready() -> void:
    $Sprite.self_modulate = Palette.PINK if special else Palette.ORANGE
    hide()


func _on_start_game() -> void:
    queue_free()


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
    yield(get_tree().create_timer(0.8), 'timeout')
    queue_free()


func _on_Planet_body_entered(body: PhysicsBody2D) -> void:
    if body.is_in_group('Balls'):
        emit_signal("scored", special, position)
        body.play_effect()
        disappear()
        Engine.time_scale = 0.125
