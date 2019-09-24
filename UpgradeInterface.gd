extends Control

signal closed


func _process(delta: float) -> void:
    if delta:
        pass
    if Input.is_action_just_pressed("upgrade_interface_open_close"):
        if is_visible_in_tree():
            hide()
        else:
            show()


func _on_CloseButton_pressed() -> void:
    emit_signal("closed")
    hide()
    