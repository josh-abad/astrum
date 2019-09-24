extends Node

signal changed(achievement_name)

const ALL: String = "ALL"
const EMPTY: String = ""

var _completed_achievements: Array = [] setget set_completed_achievements, get_completed_achievements
var buffer: String


func set_completed_achievements(value: Array) -> void:
    _completed_achievements = value
    emit_signal("changed", ALL)
    
    
func get_completed_achievements() -> Array:
    return _completed_achievements


func append(achievement_name: String) -> void:
    buffer = achievement_name
    emit_signal("changed", achievement_name)
    
    
func popup_complete() -> void:
    if buffer != EMPTY:
        _completed_achievements.append(buffer)
        buffer = EMPTY
    