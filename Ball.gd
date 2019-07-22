extends RigidBody2D

const TWEEN_SCALE := 1.25
const COLORS: Array = [Color(8, 0, 4, 0.1)]
export var speed := -500

var score := 0
var reset_position := false
var playing = false

signal dropped
signal scored


func _ready():
    hide()


func _integrate_forces(state):
    if reset_position:
        state.set_transform(Transform2D(0.0, _get_camera_center()))
        state.set_linear_velocity(Vector2())
        reset_position = false


func start() -> void:
    $Camera2D.make_current()
    show()
    set_light(true)
    reset_position = true
    playing = true
    $CollisionShape2D.disabled = false
    
    
func _get_camera_center():
    var vtrans = get_canvas_transform()
    var top_left = -vtrans.get_origin() / vtrans.get_scale()
    var vsize = get_viewport_rect().size
    return top_left + 0.5 * vsize / vtrans.get_scale()
    
    
func get_score() -> int:
    """Returns the player's score"""
    return score


func set_score(value: int) -> void:
    """Sets the player's score by the specified value"""
    score = value


func reset_light() -> void:
    $Tween.interpolate_property($Light2D, 'energy', $Light2D.energy, 1, 0.4, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)


func play_sound() -> void:
    $BounceSound.play()
    $BounceSound.pitch_scale += 1
    $BounceSound/PitchTimer.start()


func _input_event(viewport, event, shape_idx):
    if event is InputEventMouseButton and event.button_index == 1 and event.is_pressed() and !event.is_echo():
        var direction: Vector2 = (self.get_position() - get_global_mouse_position()).normalized()
        self.set_linear_velocity(-direction * speed)
        # TODO: implement better ball physics
        # apply_central_impulse(-direction * speed)
        play_sound()
        _start_tween()
        $Spark.set_emitting(true)
        reset_light()


func _on_Ball_body_entered(body):
    play_sound()
    _start_tween()
    $Camera2D.shake(0.2, 15, 8)
    $Spark.set_emitting(true)
    if body.is_in_group('Targets') and $VisibilityNotifier2D.is_on_screen():
        score += 1
        emit_signal('scored')


func _on_VisibilityNotifier2D_screen_exited():
    if playing:
        $DroppedSound.play()
        $CollisionShape2D.set_deferred('disabled', true)
        set_light(false)
        $Camera2D.current = false
        emit_signal("dropped")
        playing = false


func _on_PitchTimer_timeout():
    $BounceSound.pitch_scale = 1
    $BounceSound/PitchTimer.stop()
    
    
func set_light(on: bool) -> void:
    $Tween.interpolate_property(
        $Light2D, 'energy',
        $Light2D.energy, 1 if on else 0,
        0.2,
        Tween.TRANS_QUAD,
        Tween.EASE_IN)


func _tween(node: Object, property: NodePath, before, after):
    $Tween.interpolate_property(node, property, before, after, 0.4, Tween.TRANS_BOUNCE, Tween.EASE_IN)
    $Tween.interpolate_property(node, property, after, before, 0.4, Tween.TRANS_BOUNCE, Tween.EASE_OUT)


func _start_tween() -> void:
    if not $Tween.is_active():
        _tween($Light2D/Sprite, 'scale', $Light2D/Sprite.get_transform().get_scale(), Vector2(TWEEN_SCALE, TWEEN_SCALE))
        _tween($Light2D, 'texture_scale', $Light2D.texture_scale, 1.5)
        _tween($Light2D, 'color', $Light2D.color, COLORS[randi() % COLORS.size()])
        $Tween.start()