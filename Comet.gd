extends RigidBody2D

const TWEEN_SCALE := 1.50
const COLORS: Array = [Color(1, 1, 1)]

export var speed := -500 setget set_speed, get_speed

var reset_position := false setget set_reset_position, is_reset_position
var playing = false setget set_playing, is_playing

signal dropped
signal scored(planet_position)
signal activate_power


func _ready():
    hide()
    $CollisionShape2D.set_deferred('disabled', true)


func _integrate_forces(state):
    if reset_position:
        state.set_transform(Transform2D(0.0, $Camera2D.get_camera_screen_center()))
        state.set_linear_velocity(Vector2())
        reset_position = false
        

func start() -> void:
    $Camera2D.make_current()
    show()
    set_light(true)
    reset_position = true
    playing = true
    $CollisionShape2D.disabled = false
        

func _input_event(viewport, event, shape_idx):
    if event is InputEventMouseButton and event.button_index == 1 and event.is_pressed() and !event.is_echo():
        var direction: Vector2 = (self.get_position() - get_global_mouse_position()).normalized()
        self.set_linear_velocity(-direction * speed)
        play_sound()
        _start_tween()


func _on_Comet_body_entered(body):
    play_sound()
    _start_tween()
    $Camera2D.shake(0.2, 15, 8)
    if $VisibilityNotifier2D.is_on_screen() and body.is_in_group('Planets'):
        emit_signal('scored', body.get_position())
            

func _on_VisibilityNotifier2D_screen_exited():
    if playing:
        dropped_sound_transition()
        $CollisionShape2D.set_deferred('disabled', true)
        set_light(false)
        $Camera2D.current = false
        emit_signal("dropped")
        playing = false


func play_sound() -> void:
    $BounceSound.play()
    $BounceSound.pitch_scale += 1
    $BounceSound/PitchTimer.start()


func _on_PitchTimer_timeout():
    $BounceSound.pitch_scale = 1
    
    
func set_light(on: bool) -> void:
    $Tween.interpolate_property($Light2D, 'energy', $Light2D.energy, 1 if on else 0, 0.2, Tween.TRANS_QUAD, Tween.EASE_IN)
    $Tween.start()


func _tween(node: Object, property: NodePath, before, after, duration: float = 0.4):
    $Tween.interpolate_property(node, property, before, after, duration, Tween.TRANS_BOUNCE, Tween.EASE_IN)
    $Tween.interpolate_property(node, property, after, before, duration, Tween.TRANS_BOUNCE, Tween.EASE_OUT)

        
func pulse() -> void:
    $Tween.interpolate_property($Light2D, 'energy', $Light2D.energy, 2, 0.8, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.interpolate_property($Light2D, 'energy', 2, $Light2D.energy, 0.8, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.start()
    
    
func _start_tween() -> void:
    if not $Tween.is_active():
        _tween($Light2D/Sprite, 'scale', $Light2D/Sprite.get_transform().get_scale(), Vector2(TWEEN_SCALE, TWEEN_SCALE))
        _tween($Light2D, 'texture_scale', $Light2D.texture_scale, 1.5)
        _tween($Light2D, 'color', $Light2D.color, COLORS[randi() % COLORS.size()])
        $Tween.start()

        
func disappear() -> void:
    playing = false
    $CollisionShape2D.set_deferred('disabled', true)
    $Camera2D.current = false
    set_linear_velocity(Vector2())
    $Tween.interpolate_property(self, 'visible', visible, false, 0.4, Tween.TRANS_CIRC, Tween.EASE_OUT)
    $Tween.start()
    
    
func dropped_sound_transition() -> void:
    $DroppedSound.play()
    $Tween.interpolate_property($DroppedSound, 'volume_db', $DroppedSound.volume_db, -25, 2, Tween.TRANS_QUAD, Tween.EASE_OUT_IN)
    $Tween.start()
    yield(get_tree().create_timer(2), 'timeout')
    $DroppedSound.stop()
    $DroppedSound.set_volume_db(10)
    
    
func get_speed() -> int:
    return speed
    
    
func set_speed(value: int) -> void:
    speed = value
    
       
func is_reset_position() -> bool:
    return reset_position
    
    
func set_reset_position(value: bool) -> void:
    reset_position = value


func is_playing() -> bool:
    return playing
    
    
func set_playing(value: bool) -> void:
    playing = value


func _on_Area2D_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
    if event is InputEventMouseButton and event.button_index == 1 and event.is_pressed() and !event.is_echo():
        emit_signal("activate_power")
        
        
func use_power() -> void:
    if not $Tween.is_active():
        _tween($Light2D, 'color', $Light2D.color, Color("#d52a7a"), 0.8)
    $Tween.interpolate_property(self, 'linear_velocity', linear_velocity, Vector2(0, 0), 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.start()
    $PowerSound.play()
