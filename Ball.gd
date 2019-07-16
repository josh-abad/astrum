extends RigidBody2D

const TWEEN_SCALE = 1.25
const SPEED = -500

var score = 0

signal dropped
signal scored


func get_score():
	return score


func set_score(value):
	score = value


func tween(node, property, before, after):
	$Tween.interpolate_property(node, property, before, after, 0.3, Tween.TRANS_QUAD, Tween.EASE_IN)
	$Tween.interpolate_property(node, property, after, before, 0.3, Tween.TRANS_QUAD, Tween.EASE_OUT)


func start_tween():
	tween($Light2D/Sprite, 'scale', $Light2D/Sprite.get_transform().get_scale(), Vector2(TWEEN_SCALE, TWEEN_SCALE))
	tween($Light2D, 'texture_scale', $Light2D.texture_scale, 1.5)
	tween($Light2D, 'color', $Light2D.color, Color(8, 0, 4, 0.1))
	$Tween.start()


func reset_light():
	$Tween.interpolate_property($Light2D, 'energy', $Light2D.energy, 1, 0.4, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)


func play_sound():
	$BounceSound.play()
	$BounceSound.pitch_scale += 1
	$BounceSound/PitchTimer.start()


func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == 1 and event.is_pressed() and !event.is_echo():
		var direction = (self.get_position() - get_global_mouse_position()).normalized()
		self.set_linear_velocity(-direction * SPEED)
		play_sound()
		start_tween()
		$Spark.set_emitting(true)
		reset_light()


func _on_Ball_body_entered(body):
	play_sound()
	start_tween()
	$Camera2D.shake(0.2, 15, 8)
	$Spark.set_emitting(true)
	if body.is_in_group('Targets') and $VisibilityNotifier2D.is_on_screen():
			score += 1
			emit_signal('scored')


func _on_VisibilityNotifier2D_screen_exited():
	$DroppedSound.play()
	emit_signal("dropped")


func unfocus_camera():
	$Camera2D.current = false
	
	
func stop_bounce():
	physics_material_override.bounce = 0
	
	
func remove():
	"""
	Hack to stop the ball's sound effects when it's dropped.
	"""
	$BounceSound.stream = null


func _on_PitchTimer_timeout():
	$BounceSound.pitch_scale = 1
	$BounceSound/PitchTimer.stop()
	
	
func turn_off_light():
	$Tween.interpolate_property(
		$Light2D, 'energy',
		$Light2D.energy, 0,
		0.4,
		Tween.TRANS_QUAD,
		Tween.EASE_IN)