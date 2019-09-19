extends Area2D

signal destroyed_player(player_position)


func _ready() -> void:
    $Tween.interpolate_property(self, "rotation_degrees", rotation_degrees, 360, 1, Tween.TRANS_QUAD, Tween.EASE_IN)
    $Tween.start()
    

func _on_Spike_body_entered(body: Node) -> void:
    if body.is_in_group('Balls'):
        body.disappear()        
        emit_signal("destroyed_player", body.position)
        
        
func _on_start_game() -> void:
    queue_free()
