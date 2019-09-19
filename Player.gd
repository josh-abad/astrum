extends KinematicBody2D

const TWEEN_SCALE := 1.25

var reset_position := false
var playing = false

signal dropped
signal scored(planet_position)
signal slo_mo
signal nor_mo

var elapsed_time = 0    
var start_pos
var speed
var start_time
var direction = Vector2()


func _input(event):
    if event is InputEventMouseButton:
        if event.is_pressed():
            start_pos = event.position
            start_time = elapsed_time
            $Tween.interpolate_property($Sprite, "scale", $Sprite.get_transform().get_scale(), Vector2(0.8, 1), 0.2, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
            $Tween.start()            
            Engine.time_scale = 0.25
            emit_signal("slo_mo")
        else:
            direction = event.position - start_pos
            var delta = elapsed_time - start_time
            speed = (direction.length()) / (delta if delta != 0 else 1)
            direction = direction.normalized() * 1500
            Engine.time_scale = 1
            emit_signal("nor_mo")
            
#            var color = Palette.randomize()
#            $Tween.interpolate_property($Light2D, 'color', $Light2D.color, color, 0.4,Tween.TRANS_QUAD, Tween.EASE_OUT)
#            color.a = 0.07
#            $Trail.process_material.color_ramp.gradient.set_color(0, color)
            
            _play_sound()
            # $Tween.interpolate_property($Sprite, "scale", $Sprite.get_transform().get_scale(), Vector2(1, 1), 0.2, Tween.TRANS_BOUNCE, Tween.EASE_OUT)            
            _start_tween()


func _physics_process(delta: float) -> void:
    if delta:
        pass
    direction = move_and_slide(direction)


func _process(delta):
    elapsed_time += delta


func _ready() -> void:
    hide()
    $CollisionShape2D.set_deferred('disabled', true)


func start() -> void:
    $Camera2D.make_current()
    show()
    set_light(true)
    reset_position = true
    playing = true
    $CollisionShape2D.disabled = false
        

func _on_Comet_body_entered(body: PhysicsBody2D) -> void:
    _play_sound()
    _start_tween()
    $Camera2D.shake(0.2, 15, 8)
    #if $VisibilityNotifier2D.is_on_screen() and body.is_in_group('Planets'):
    emit_signal("slo_mo")
    emit_signal('scored', body.get_position())
            

func _on_VisibilityNotifier2D_screen_exited() -> void:
    if playing:
        $CollisionShape2D.set_deferred('disabled', true)
        set_light(false)
        $Camera2D.current = false
        emit_signal("dropped")
        playing = false


func _play_sound() -> void:
    $BounceSound.play()
    $BounceSound.pitch_scale += 1
    $BounceSound/PitchTimer.start()


func _on_PitchTimer_timeout() -> void:
    $BounceSound.pitch_scale = 1
    
    
func set_light(on: bool) -> void:
    if on:
        pass
    # $Tween.interpolate_property($Light2D, 'energy', $Light2D.energy, 1 if on else 0, 0.2, Tween.TRANS_QUAD, Tween.EASE_IN)
    # $Tween.start()


func _tween(node: Object, property: NodePath, before, after, final, duration: float = 0.4):
    $Tween.interpolate_property(node, property, before, after, duration, Tween.TRANS_BOUNCE, Tween.EASE_IN)
    $Tween.interpolate_property(node, property, after, final, duration, Tween.TRANS_BOUNCE, Tween.EASE_OUT)

        
func pulse() -> void:
    pass
    # $Tween.interpolate_property($Light2D, 'energy', $Light2D.energy, 3, 0.8, Tween.TRANS_QUAD, Tween.EASE_OUT)
    # $Tween.interpolate_property($Light2D, 'energy', 3, 1, 0.8, Tween.TRANS_QUAD, Tween.EASE_OUT)
    # $Tween.start()
    
    
func _start_tween() -> void:
    _tween($Sprite, 'scale', $Sprite.get_transform().get_scale(), Vector2(TWEEN_SCALE, TWEEN_SCALE), Vector2(1, 1))
    $Tween.start()

        
func disappear() -> void:
    playing = false
    $CollisionShape2D.set_deferred('disabled', true)
    $Camera2D.current = false
    $Tween.interpolate_property(self, 'visible', visible, false, 0.4, Tween.TRANS_CIRC, Tween.EASE_OUT)
    $Tween.start()
