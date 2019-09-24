extends Node

signal changed

var _music_on: bool = true setget set_music_on, is_music_on
var _sfx_on: bool = true setget set_sfx_on, is_sfx_on


func set_music_on(value: bool) -> void:
    _music_on = value
    emit_signal("changed")


func is_music_on() -> bool:
    return _music_on
    
    
func set_sfx_on(value: bool) -> void:
    _sfx_on = value
    emit_signal("changed")
    
    
func is_sfx_on() -> bool:
    return _sfx_on
