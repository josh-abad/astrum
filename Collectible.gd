extends RigidBody2D

signal collected(is_health)

onready var is_health: bool = rand_range(0, 100) <= 20


func _ready() -> void:
    if is_health:
        $Sprite.texture = load("res://Assets/Health.png")


func appear(position: Vector2) -> void:
    self.position = position
    $Tween.interpolate_property(self, 'scale', Vector2(0, 0), Vector2(1, 1), 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
    # $Tween.interpolate_property(self, 'visible', visible, true, 0.8, Tween.TRANS_CIRC, Tween.EASE_IN)
    $Tween.start()


func _on_start_game() -> void:
    queue_free()


func _disappear() -> void:
    $CollisionShape2D.set_deferred('disabled', true)
#    $Tween.interpolate_property($Sprite, 'scale', $Sprite.scale, Vector2(0, 0), 0.1, Tween.TRANS_QUAD, Tween.EASE_OUT)
#    $Tween.interpolate_property(self, 'position', get_position(), get_position(), 1, Tween.TRANS_QUAD, Tween.EASE_OUT)
#    $Tween.start()
    hide()
    $DisappearTimer.start()


func _on_Collectible_body_entered(body: Node) -> void:
    if body.is_in_group('Balls'):
        emit_signal("collected", is_health)
        body.play_effect()
        _disappear()


func _on_DisappearTimer_timeout() -> void:
    queue_free()
