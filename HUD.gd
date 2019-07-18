extends CanvasLayer

onready var center_y = get_center_y()


func set_label(text: String) -> void:
    $CenterContainer/Label.set_text(text)
    
    
func get_center_y() -> int:
    return get_viewport().size.y / 2 - $CenterContainer.get_rect().size.y / 2
    
    
func start_tween():
    $Tween.interpolate_property($CenterContainer, 'rect_position', Vector2($CenterContainer.rect_position.x, 0), Vector2($CenterContainer.rect_position.x, center_y), 0.8, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
    $Tween.start()
