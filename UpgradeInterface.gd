extends MarginContainer

signal closed

var displayed: bool = false


func _process(delta: float) -> void:
    if delta:
        pass


func _on_CloseButton_pressed() -> void:
    emit_signal("closed")
    _display(false)
    
    
func _display(yes: bool) -> void:
    displayed = yes
    if yes:
        show()
    $Tween.interpolate_property(self, 'rect_position', rect_position, Vector2(0, 0) if yes else Vector2(320, 0), 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.interpolate_property(self, 'modulate', modulate, Color(1, 1, 1, 1) if yes else Color(1, 1, 1, 0), 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.start()


func _on_Tween_tween_all_completed() -> void:
    if not displayed:
        hide()
