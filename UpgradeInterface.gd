extends MarginContainer

signal closed


func _process(delta: float) -> void:
    if delta:
        pass
    if Input.is_action_just_pressed("upgrade_interface_open_close"):
        if is_visible_in_tree():
            _display(false)
        else:
            _display(true)


func _on_CloseButton_pressed() -> void:
    emit_signal("closed")
    _display(false)
    
    
func _display(yes: bool) -> void:
    $Tween.interpolate_property(self, 'rect_position', rect_position, Vector2(0, 0) if yes else Vector2(320, 0), 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.start()
    if yes:
        show()
    else:
        yield(get_tree().create_timer(1), "timeout")
        hide()