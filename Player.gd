extends KinematicBody2D

const TWEEN_SCALE := 1.5

var reset_position := false
var playing := false
var moving := false

signal slo_mo(temporary)
signal nor_mo

var elapsed_time: float = 0    
var start_pos: Vector2
var speed := 1000
var start_time: float
var direction := Vector2()


func _input(event: InputEvent) -> void:
    if playing and event is InputEventMouseButton:
        if event.is_pressed():
            moving = false
            start_pos = event.position
            start_time = elapsed_time
            emit_signal("slo_mo", false)
        else:
            direction = event.position - start_pos
            direction = direction.normalized() * speed
            emit_signal("nor_mo")
            _start_tween(false)


# TODO: stretch sprite towards direction
func _stretch() -> void:
    look_at(direction)
    $Tween.interpolate_property($Sprite, "scale", $Sprite.get_transform().get_scale(), Vector2(1.2, 1), 0.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
    $Tween.start()    


func _physics_process(delta: float) -> void:
    if delta:
        pass
    if reset_position:
        direction = Vector2()
        reset_position = false
    direction = move_and_slide(direction)
    moving = direction != Vector2.ZERO


func _process(delta):
    elapsed_time += delta


func _ready() -> void:
    hide()
    $CollisionShape2D.set_deferred('disabled', true)


func start() -> void:
    $Camera2D.make_current()
    show()
    playing = true
    $CollisionShape2D.disabled = false
        

func play_effect() -> void:
    _start_tween()
    $Camera2D.shake(0.35, 15, 8)
    emit_signal("slo_mo", true)


func _tween(node: Object, property: NodePath, before, after, final, duration: float = 0.4):
    $Tween.interpolate_property(node, property, before, after, duration, Tween.TRANS_ELASTIC, Tween.EASE_IN)
    $Tween.interpolate_property(node, property, after, final, duration, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
    
    
func _start_tween(fast: bool = true) -> void:
    _tween($Sprite, 'scale', $Sprite.get_transform().get_scale(), Vector2(TWEEN_SCALE, TWEEN_SCALE), Vector2(1, 1), 0.4 if fast else 0.8)
    $Tween.interpolate_property($Sprite, 'self_modulate', $Sprite.self_modulate, Palette.REVO, 0.4 if fast else 0.8, Tween.TRANS_QUAD, Tween.EASE_IN)
    $Tween.interpolate_property($Sprite, 'self_modulate', Palette.REVO, Palette.BLUE, 0.4 if fast else 0.8, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.start()

        
func disappear() -> void:
    playing = false
    reset_position = true
    $CollisionShape2D.set_deferred('disabled', true)
    $Camera2D.current = false
    hide()
