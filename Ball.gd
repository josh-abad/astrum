extends RigidBody2D

const TWEEN_SCALE = 1.25
const SPEED = -400


func _ready():
	$Timer.start()


func tween(node, property, before, after):
	$Tween.interpolate_property(node, property, before, after, 0.4, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.interpolate_property(node, property, after, before, 0.4, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)


func start_tween():
	tween($Light2D/Sprite, 'scale', $Light2D/Sprite.get_transform().get_scale(), Vector2(TWEEN_SCALE, TWEEN_SCALE))
	tween($Light2D, 'texture_scale', $Light2D.texture_scale, 1.5)
	tween($Light2D, 'color', $Light2D.color, Color(8, 0, 4, 0.1))
	$Tween.start()


func reset_light():
	$Tween.interpolate_property($Light2D, 'energy', $Light2D.energy, 1, 0.4, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)


func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == 1 and event.is_pressed() and !event.is_echo():
		var direction = (self.get_position() - get_global_mouse_position()).normalized()
		self.set_linear_velocity(-direction * SPEED)
		$AudioStreamPlayer.play()
		start_tween()
		$Particles2D.set_emitting(true)
		reset_light()


func _on_Ball_body_entered(body):
	$AudioStreamPlayer.play()
	start_tween()
	$Particles2D.set_emitting(true)


func _on_Timer_timeout():
	if $Light2D.energy > 0:
		$Tween.interpolate_property($Light2D, 'energy', $Light2D.energy, $Light2D.energy-0.1, 0.4, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
		$Tween.start()