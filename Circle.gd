extends RigidBody2D

const SPEED = 5


func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == 1 and event.is_pressed() and !event.is_echo():
		var direction = (self.get_position() - get_global_mouse_position()).normalized()
		self.set_linear_velocity(-direction * SPEED)


func get_smaller_scale():
	var smaller_scale = $Sprite.get_transform().get_scale()
	smaller_scale.x -= 0.25
	smaller_scale.y -= 0.25
	return smaller_scale


func get_smaller_radius():
	return $Spark.process_material.emission_sphere_radius - 32


func start_tween():
	$Tween.interpolate_property($Sprite, 'scale', $Sprite.get_transform().get_scale(), get_smaller_scale(), 0.4, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($Spark, 'emission_sphere_radius', $Spark.process_material.emission_sphere_radius, get_smaller_radius(), 0.4, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.start()
	if $Sprite.get_transform().get_scale().x <= 0:
		queue_free()


func _on_Circle_body_entered(body):
	if body.is_in_group('Balls'):
		$Spark.set_emitting(true)
		$HitSound.play()
		start_tween()
		get_tree().paused = true
		$Freeze.start()


func _on_Freeze_timeout():
	get_tree().paused = false
