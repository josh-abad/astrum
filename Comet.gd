extends RigidBody2D

const TWEEN_SCALE := 1.25

export var speed := -500

var reset_position := false
var playing = false
var shield_on = false

signal dropped
signal scored(planet_position)
signal shielded


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
    if viewport and shape_idx:
        pass
    if event is InputEventMouseButton and event.button_index == 1 and event.is_pressed() and !event.is_echo():
        var direction: Vector2 = (self.get_position() - get_global_mouse_position()).normalized()
        self.set_linear_velocity(-direction * speed)
        play_sound()
        _start_tween()


func _on_Comet_body_entered(body: PhysicsBody2D):
    play_sound()
    _start_tween()
    $Camera2D.shake(0.2, 15, 8)
    if $VisibilityNotifier2D.is_on_screen() and body.is_in_group('Planets'):
        emit_signal('scored', body.get_position())
            

func _on_VisibilityNotifier2D_screen_exited():
    if playing:
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


func _tween(node: Object, property: NodePath, before, after, final, duration: float = 0.4):
    $Tween.interpolate_property(node, property, before, after, duration, Tween.TRANS_BOUNCE, Tween.EASE_IN)
    $Tween.interpolate_property(node, property, after, final, duration, Tween.TRANS_BOUNCE, Tween.EASE_OUT)

        
func pulse() -> void:
    $Tween.interpolate_property($Light2D, 'energy', $Light2D.energy, 3, 0.8, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.interpolate_property($Light2D, 'energy', 3, 1, 0.8, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.start()
    
    
func _start_tween() -> void:
    _tween($Light2D/Sprite, 'scale', $Light2D/Sprite.get_transform().get_scale(), Vector2(TWEEN_SCALE, TWEEN_SCALE), Vector2(1, 1))
    _tween($Light2D, 'texture_scale', $Light2D.texture_scale, 1.5, 1)
    _tween($Light2D, 'color', $Light2D.color, Color(1, 1, 1), Color("#07f9dc"))
    $Tween.start()

        
func disappear() -> void:
    playing = false
    $CollisionShape2D.set_deferred('disabled', true)
    $Camera2D.current = false
    set_linear_velocity(Vector2())
    $Tween.interpolate_property(self, 'visible', visible, false, 0.4, Tween.TRANS_CIRC, Tween.EASE_OUT)
    $Tween.start()
    
              
func use_power() -> void:
    _tween($Light2D, 'color', $Light2D.color, Color("#fb2778"), Color("#07f9dc"), 0.8)
    $Tween.interpolate_property(self, 'linear_velocity', linear_velocity, Vector2(0, 0), 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.start()
    $PowerSound.play()
    $Spark.set_emitting(true)
    Freeze.freeze()
    
    
func enable_shield(yes: bool) -> void:
    shield_on = yes
    $Tween.interpolate_property($Shield, "modulate", $Shield.modulate, Color(1, 1, 1, 1 if yes else 0), 1, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.start()
    Freeze.freeze()    


func _on_Shield_area_entered(area: Area2D) -> void:
    if $VisibilityNotifier2D.is_on_screen() and shield_on and area.is_in_group("Black Hole"):
        emit_signal("shielded")
