extends Area2D

signal absorb
signal inactive

var active := false setget set_active, is_active


func _physics_process(delta):
    var overlapping_bodies: Array = get_overlapping_bodies()
    if active and overlapping_bodies.size() > 0:
        for body in overlapping_bodies:
            if body.is_in_group('Balls'):
                emit_signal("absorb")


func appear(position: Vector2) -> void:
    show()
    self.position = position
    $Tween.interpolate_property(self, 'scale', Vector2(0, 0), Vector2(1, 1), 0.4, Tween.TRANS_CIRC, Tween.EASE_IN)
    $Tween.interpolate_property(self, 'visible', visible, true, 0.4, Tween.TRANS_CIRC, Tween.EASE_IN)
    $Tween.start()
    active = true
    $ActiveTimer.start()
    $TransitionSound.play()
    $AmbientSound.play()
    
    
func disappear() -> void:
    $Tween.interpolate_property(self, 'scale', scale, Vector2(0, 0), 0.4, Tween.TRANS_CIRC, Tween.EASE_OUT)
    $Tween.interpolate_property(self, 'visible', visible, false, 0.4, Tween.TRANS_CIRC, Tween.EASE_OUT)
    $Tween.start()
    active = false
    $AmbientSound.stop()
    $TransitionSound.play()
    

func _on_ActiveTimer_timeout():
    disappear()
    emit_signal('inactive')
    
    
func is_active() -> bool:
    return active
    
    
func set_active(value: bool) -> void:
    active = value
