extends Node

signal changed(achievement_name)

const ALL: String = "ALL"

var _completed_achievements: Array = [] setget set_completed_achievements, get_completed_achievements


func set_completed_achievements(value: Array) -> void:
    _completed_achievements = value
    emit_signal("changed", ALL)
    
    
func get_completed_achievements() -> Array:
    return _completed_achievements


func append(achievement_name: String) -> void:
    _completed_achievements.append(achievement_name)
    emit_signal("changed", achievement_name)