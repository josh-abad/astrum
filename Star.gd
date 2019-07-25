extends Area2D

signal collect

var collected := false


func _ready() -> void:
    hide()


func _physics_process(delta):
    var overlapping_bodies: Array = get_overlapping_bodies()
    if not collected and overlapping_bodies.size() > 0:
        for body in overlapping_bodies:
            if body.is_in_group('Balls'):
                emit_signal("collect")
                disappear()
                collected = true
                $CollectSound.play()


func appear(position: Vector2) -> void:
    self.position = position
    $Tween.interpolate_property(self, 'scale', Vector2(0, 0), Vector2(1, 1), 0.8, Tween.TRANS_CIRC, Tween.EASE_IN)
    $Tween.interpolate_property(self, 'visible', visible, true, 0.8, Tween.TRANS_CIRC, Tween.EASE_IN)
    $Tween.start()


func disappear() -> void:
    $Tween.interpolate_property(self, 'scale', scale, Vector2(0, 0), 0.8, Tween.TRANS_CIRC, Tween.EASE_OUT)
    $Tween.interpolate_property(self, 'visible', visible, false, 0.8, Tween.TRANS_CIRC, Tween.EASE_OUT)
    $Tween.start()