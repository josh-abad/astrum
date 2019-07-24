extends CanvasLayer

signal start_game

onready var center_y : int = get_center_y()


func _ready():
    $CenterContainer.rect_position = Vector2($CenterContainer.rect_position.x, center_y)


func set_label(text: String) -> void:
    $CenterContainer/Label.set_text(text)
    
    
func show_game_over() -> void:
    set_label('Game Over')
    center_label()
    $StartButton.show()
    
    
func get_center_y() -> int:
    return get_viewport().size.y / 2 - $CenterContainer.get_rect().size.y / 2
    
    
func center_label() -> void:
    $Tween.interpolate_property($CenterContainer, 'rect_position', Vector2($CenterContainer.rect_position.x, 0), Vector2($CenterContainer.rect_position.x, center_y), 0.8, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
    $Tween.start()


func uncenter_label() -> void:
    $Tween.interpolate_property($CenterContainer, 'rect_position', Vector2($CenterContainer.rect_position.x, center_y), Vector2($CenterContainer.rect_position.x, 0), 0.8, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
    $Tween.start()


func _on_StartButton_pressed():
    $StartButton.hide()
    uncenter_label()
    emit_signal('start_game')
