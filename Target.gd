extends RigidBody2D

const COLORS: Array = ['Target', 'Dingy', 'Eton', 'Flax']


func _ready():
    $Sprite.set_texture(load("res://Assets/%s.png" % COLORS[randi() % COLORS.size()]))


func get_smaller_scale() -> Vector2:
    var smaller_scale: Vector2 = $Sprite.get_transform().get_scale()
    smaller_scale.x -= 0.25
    smaller_scale.y -= 0.25
    return smaller_scale


func get_smaller_radius() -> float:
    return $Spark.process_material.emission_sphere_radius - 32


func start_tween() -> void:
    $Tween.interpolate_property($Sprite, 'scale', $Sprite.get_transform().get_scale(), get_smaller_scale(), 0.4, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
    $Tween.interpolate_property($Spark, 'emission_sphere_radius', $Spark.process_material.emission_sphere_radius, get_smaller_radius(), 0.4, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
    $Tween.start()


func start_freeze() -> void:
    """
    Freezes the screen for 7.5 milliseconds.
    """
    get_tree().paused = true
    $Freeze.start()


func _on_Circle_body_entered(body):
    if body.is_in_group('Balls'):
        $Spark.set_emitting(true)
        $HitSound.play()
        start_tween()
        start_freeze()


func _on_Freeze_timeout():
    get_tree().paused = false
    if $Sprite.get_transform().get_scale().x < 0.25:
        queue_free()
