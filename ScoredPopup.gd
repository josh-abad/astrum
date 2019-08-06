extends Label


func display(position: Vector2, text: String) -> void:
    if not $Tween.is_active():
        $Tween.interpolate_property(self, 'modulate', modulate, Color(1, 1, 1, 1), 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
        $Tween.start()
    set_position(position)
    set_text(text)
    yield(get_tree().create_timer(1), 'timeout')
    if not $Tween.is_active():
        $Tween.interpolate_property(self, 'modulate', modulate, Color(1, 1, 1, 0), 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
        $Tween.start()
    