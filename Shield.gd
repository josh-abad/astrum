extends Area2D

signal collect

var collected := false


func _ready() -> void:
    hide()


func _on_start_game() -> void:
    queue_free()


func _rand_scale() -> void:
    var scale: float = rand_range(0.5, 1.0)
    $Light2D/AnimatedSprite.set_scale(Vector2(scale, scale))
    $CollisionShape2D.set_scale(Vector2(scale, scale))


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
    $Tween.interpolate_property(self, 'scale', Vector2(0, 0), Vector2(1, 1), 0.8, Tween.TRANS_CIRC, Tween.EASE_IN)
    $Tween.interpolate_property(self, 'visible', visible, true, 0.8, Tween.TRANS_CIRC, Tween.EASE_IN)
    $Tween.interpolate_property(self, 'modulate', Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.8, Tween.TRANS_CIRC, Tween.EASE_IN)
    $Tween.start()


func disappear() -> void:
    $Tween.interpolate_property(self, 'scale', scale, Vector2(0, 0), 0.8, Tween.TRANS_CIRC, Tween.EASE_OUT)
    $Tween.interpolate_property(self, 'visible', visible, false, 0.8, Tween.TRANS_CIRC, Tween.EASE_OUT)
    $Tween.start()
    yield(get_tree().create_timer(1), "timeout")
    queue_free()
