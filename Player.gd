extends KinematicBody2D

const TWEEN_SCALE := 1.25

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
            
            # TODO: stretch sprite towards direction
            # $Tween.interpolate_property($Sprite, "scale", $Sprite.get_transform().get_scale(), Vector2(0.9, 0.9), 0.2, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
            #$Tween.start()
            
            emit_signal("slo_mo", false)
        else:
            direction = event.position - start_pos
            
            """ Determines speed based on player's gesture """
            # var delta = elapsed_time - start_time 
            # speed = (direction.length()) / (delta if delta != 0 else 1)
            
            direction = direction.normalized() * speed
            emit_signal("nor_mo")
            _start_tween()


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
    $Camera2D.shake(0.2, 15, 8)
    emit_signal("slo_mo", true)


func _tween(node: Object, property: NodePath, before, after, final, duration: float = 0.4):
    $Tween.interpolate_property(node, property, before, after, duration, Tween.TRANS_ELASTIC, Tween.EASE_IN)
    $Tween.interpolate_property(node, property, after, final, duration, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
    
    
func _start_tween() -> void:
    _tween($Sprite, 'scale', $Sprite.get_transform().get_scale(), Vector2(TWEEN_SCALE, TWEEN_SCALE), Vector2(1, 1))
    $Tween.start()

        
func disappear() -> void:
    playing = false
    reset_position = true
    $CollisionShape2D.set_deferred('disabled', true)
    $Camera2D.current = false
    hide()
