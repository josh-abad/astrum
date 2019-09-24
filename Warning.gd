extends Control

var active: bool = false setget set_active, is_active


func _ready() -> void:
    _pulse()


func set_active(value: bool) -> void:
    active = value
    
    
func is_active() -> bool:
    return active
    
    
func _pulse() -> void:
    $Tween.interpolate_property($Warning, "self_modulate", $Warning.modulate, Palette.PURPLE, 0.4, Tween.TRANS_LINEAR, Tween.EASE_IN)
    $Tween.interpolate_property($Warning, "self_modulate", Palette.PURPLE, Palette.ORANGE, 0.4, Tween.TRANS_LINEAR, Tween.EASE_OUT)
    $Tween.start()