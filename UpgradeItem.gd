extends Control

signal upgraded(upgrade_name, level, upgrade_cost)

const MAX_UPGRADE: int = 3

var upgrade_name: String = "upgrade name"
var level: float = 0.0
var upgrade_cost: int = 1000
var can_upgrade: bool = true


func _ready() -> void:
    $UpgradeName.set_text(upgrade_name)
    $UpdateProgress.set_value(level)
    $UpgradeButton.set_text(str(upgrade_cost))


func update_upgrade(name: String, value: float = 0.0) -> void:
    upgrade_name = name
    level = value
    if round(value) == 3:
        can_upgrade = false
        $UpgradeButton.hide()
    elif round(value) == 2:
        upgrade_cost = 10000
    else:
        upgrade_cost = 5000 if round(value) == 1 else 1000
    
    $UpgradeName.set_text(upgrade_name)
    $UpdateProgress.set_value(level)
    $UpgradeButton.set_text(str(upgrade_cost))


func disable_upgrade_button(credits: int) -> void:
    if can_upgrade:
        $UpgradeButton.set_disabled(credits < upgrade_cost)


func _upgrade() -> void:
    if can_upgrade:
        level += 1
        $UpdateProgress.set_value(level)
        
        emit_signal("upgraded", upgrade_name, level, upgrade_cost)
                
        if level == MAX_UPGRADE:
            can_upgrade = false
            $UpgradeButton.hide()
        else:
            upgrade_cost += 4000 if upgrade_cost < 5000 else 5000
            $UpgradeButton.set_text(str(upgrade_cost))


func _on_UpgradeButton_pressed() -> void:
    _upgrade()
