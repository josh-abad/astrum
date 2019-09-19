extends Line2D

var target
var point
export (NodePath) var target_path
export var trail_length = 0


func _ready() -> void:
    target = get_node(target_path)


func _process(delta: float) -> void:
    if delta:
        pass
    global_position = Vector2(0, 0)
    global_rotation = 0
    point = target.global_position
    add_point(point)
    while get_point_count() > trail_length:
        remove_point(0)
