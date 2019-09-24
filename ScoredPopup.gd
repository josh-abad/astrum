extends Label


func _on_start_game() -> void:
    queue_free()


func display(position: Vector2, score: int, color: Color) -> void:
    set_position(position)    
    add_color_override("font_color", color)
    $Tween.interpolate_property(self, 'modulate', modulate, Color(1, 1, 1, 1), 0.2, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.start()
    set_text("+" + str(score))
    $FadeTimer.start()
    

func _on_DisappearTimer_timeout() -> void:
    queue_free()


func _on_FadeTimer_timeout() -> void:
    $Tween.interpolate_property(self, 'modulate', modulate, Color(1, 1, 1, 0), 0.2, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.start()
    $DisappearTimer.start()