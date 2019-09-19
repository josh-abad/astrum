extends Particles2D


func _ready() -> void:
    process_material.color_ramp.gradient.set_color(0, Palette.ORANGE)


func set_color(color: Color) -> void:
    process_material.color_ramp.gradient.set_color(0, color)    
