extends Node

const MAX_UPGRADE: int = 3

var upgrades: Dictionary = {
    "speed": 0.0,
    "health": 0.0,
    "combo": 0.0    
}


func update_upgrade(upgrade_name: String, level: float) -> void:
    upgrades[upgrade_name] = level


func get_level(upgrade_name: String) -> float:
    if upgrades.has(upgrade_name):
        return round(upgrades[upgrade_name])
    return 0.0