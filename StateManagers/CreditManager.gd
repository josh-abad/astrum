extends Node

signal changed

var _credits: int = 0 setget set_credits, get_credits


func set_credits(value: int) -> void:
    _credits = value
    emit_signal("changed")
    

func get_credits() -> int:
    return _credits
