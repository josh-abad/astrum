extends Label


func display(position: Vector2, score: int, color: Color) -> void:
    set_position(position)    
    add_color_override("font_color", color)
    $Tween.interpolate_property(self, 'modulate', modulate, Color(1, 1, 1, 1), 0.2, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.start()
    set_text("+" + str(score))
    yield(get_tree().create_timer(1), 'timeout')
    $Tween.interpolate_property(self, 'modulate', modulate, Color(1, 1, 1, 0), 0.2, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.start()
    yield(get_tree().create_timer(1), 'timeout')
    queue_free()
    