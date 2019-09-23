extends Particles2D


func _ready() -> void:
    process_material.color_ramp.gradient.set_color(0, Palette.ORANGE)


func set_color(color: Color) -> void:
    var mat = process_material
    process_material = mat.duplicate()
    process_material.color_ramp = GradientTexture.new()
    process_material.color_ramp.gradient = Gradient.new()
    process_material.color_ramp = mat.color_ramp.duplicate()
    process_material.color_ramp.gradient = mat.color_ramp.gradient.duplicate()
    
    process_material.color_ramp.gradient.set_color(0, color)
    
    var transparent = color
    transparent.a = 0
    process_material.color_ramp.gradient.set_color(1, transparent)      
