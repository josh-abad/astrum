extends Node

func freeze(seconds: float = 0.08) -> void:
    get_tree().paused = true
    yield(get_tree().create_timer(seconds), "timeout")
    get_tree().paused = false
