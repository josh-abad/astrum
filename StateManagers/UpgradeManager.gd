extends Node

signal changed(upgrade_name)

const ALL: String = "ALL"
const MAX_UPGRADE: int = 3

var _upgrades: Dictionary = {
    "speed": {
        "level": 0.0,
        "cost": 1000
    },
    "health": {
        "level": 0.0,
        "cost": 1000
    },
    "combo": {
        "level": 0.0,
        "cost": 1000
    }    
} setget set_upgrades, get_upgrades


func set_upgrades(value: Dictionary) -> void:
    _upgrades = value
    emit_signal("changed", ALL)
    
    
func get_upgrades() -> Dictionary:
    return _upgrades


func set_upgrade(upgrade_name: String, level: float, cost: int) -> void:
    _upgrades[upgrade_name]["level"] = level
    _upgrades[upgrade_name]["cost"] = cost
    emit_signal("changed", upgrade_name)


func get_upgrade(upgrade_name: String) -> Dictionary:
    if _upgrades.has(upgrade_name):
        return _upgrades[upgrade_name]
    return { }