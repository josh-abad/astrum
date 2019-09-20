extends Area2D

signal absorb
signal inactive

var active := false


func _physics_process(delta: float) -> void:
    if delta:
        pass
    var overlapping_bodies: Array = get_overlapping_bodies()
    if active and overlapping_bodies.size() > 0:
        for body in overlapping_bodies:
            if body.is_in_group('Balls'):
                emit_signal("absorb")


func appear(position: Vector2 = self.position) -> void:
    self.position = position
    $Tween.interpolate_property(self, 'scale', Vector2(0, 0), Vector2(3, 3), 0.8, Tween.TRANS_CIRC, Tween.EASE_IN)
    $Tween.interpolate_property(self, 'visible', visible, true, 0.8, Tween.TRANS_CIRC, Tween.EASE_IN)
    $Tween.interpolate_property(self, 'modulate', modulate, Color(1, 1, 1, 1), 0.8, Tween.TRANS_CIRC, Tween.EASE_IN)
    $Tween.start()
    $ActiveTimer.set_wait_time(rand_range(2, 5))
    $ActiveTimer.start()
    set_gravity_vector(position)
    
    # Wait for tween to finish before setting as active
    yield(get_tree().create_timer(1), "timeout")
    active = true    
    
    
func disappear() -> void:
    if active:
        $Tween.interpolate_property(self, 'scale', scale, Vector2(0, 0), 0.8, Tween.TRANS_CIRC, Tween.EASE_OUT)
        $Tween.interpolate_property(self, 'modulate', modulate, Color(1, 1, 1, 0), 0.8, Tween.TRANS_CIRC, Tween.EASE_OUT)
        $Tween.start()
        active = false
        emit_signal('inactive')
    

func _on_ActiveTimer_timeout() -> void:
    disappear()
    