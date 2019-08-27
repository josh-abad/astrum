extends Area2D

signal collect

var collected := false


func _ready() -> void:
    $Light2D/AnimatedSprite.scale = Vector2(0, 0)
    modulate = Color(1, 1, 1, 0)


func _on_start_game() -> void:
    queue_free()


func _physics_process(delta: float) -> void:
    if delta:
        pass
    var overlapping_bodies: Array = get_overlapping_bodies()
    if not collected and overlapping_bodies.size() > 0:
        for body in overlapping_bodies:
            if body.is_in_group('Balls'):
                emit_signal("collect")
                Freeze.freeze()                                
                disappear()
                collected = true
                $CollectSound.play()


func appear(position: Vector2) -> void:
    self.position = position
    $Tween.interpolate_property($Light2D/AnimatedSprite, 'scale', $Light2D/AnimatedSprite.scale, Vector2(1, 1), 1, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.interpolate_property(self, 'modulate', modulate, Color(1, 1, 1, 1), 1, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.start()


func disappear() -> void:
    $Light2D.set_deferred('enabled', false)
    $CollisionShape2D.set_deferred('disabled', true)
    $Tween.interpolate_property(self, 'visible', visible, false, 0.4, Tween.TRANS_CIRC, Tween.EASE_OUT)
    $Tween.start()
    yield(get_tree().create_timer(1), "timeout")
    queue_free()
