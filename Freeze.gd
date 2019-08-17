extends Node

func freeze() -> void:
    get_tree().paused = true
    yield(get_tree().create_timer(0.08), "timeout")
    get_tree().paused = false
