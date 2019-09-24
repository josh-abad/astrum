extends Control

export var upgrade_name: String

var can_upgrade: bool = true


func _ready() -> void:
    if CreditManager.connect("changed", self, "_on_credits_changed"):
        pass
    if UpgradeManager.connect("changed", self, "_on_upgrades_changed"):
        pass
    $UpgradeName.set_text(upgrade_name)
    $UpdateProgress.set_value(UpgradeManager.get_upgrade(upgrade_name)["level"])
    $UpgradeButton.set_text(str(UpgradeManager.get_upgrade(upgrade_name)["cost"]))


func _on_upgrades_changed(upgrade_name: String) -> void:
    if self.upgrade_name == upgrade_name or upgrade_name == UpgradeManager.ALL:
        var cost: int = UpgradeManager.get_upgrade(self.upgrade_name)["cost"]
        $UpgradeButton.set_text(str(cost))

        var level: float = UpgradeManager.get_upgrade(self.upgrade_name)["level"]
        $UpdateProgress.set_value(level)
        
        if level == UpgradeManager.MAX_UPGRADE:
            can_upgrade = false
            $UpgradeButton.hide()
        

func _on_credits_changed() -> void:
    if can_upgrade:
        $UpgradeButton.set_disabled(CreditManager.get_credits() < UpgradeManager.get_upgrade(upgrade_name)["cost"])


func _on_UpgradeButton_pressed() -> void:
    var cost = UpgradeManager.get_upgrade(upgrade_name)["cost"]
    CreditManager.set_credits(CreditManager.get_credits() - cost)
    
    UpgradeManager.set_upgrade(
        upgrade_name,
        UpgradeManager.get_upgrade(upgrade_name)["level"] + 1,
        cost + 4000
    )
        
