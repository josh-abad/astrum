extends Control

signal upgraded(upgrade_name, level, upgrade_cost)
signal closed


func _ready() -> void:
    $Panel/Speed.update_upgrade("speed")
    $Panel/Health.update_upgrade("health")
    $Panel/Combo.update_upgrade("combo")
    
    if $Panel/Speed.connect("upgraded", self, "_on_UpgradeItem_upgraded"):
        pass
    if $Panel/Health.connect("upgraded", self, "_on_UpgradeItem_upgraded"):
        pass
    if $Panel/Combo.connect("upgraded", self, "_on_UpgradeItem_upgraded"):
        pass
        

func load_upgrades(upgrades: Dictionary) -> void:
    if upgrades.has("speed"):
        $Panel/Speed.update_upgrade("speed", upgrades["speed"])
    if upgrades.has("health"):
        $Panel/Health.update_upgrade("health", upgrades["health"])
    if upgrades.has("combo"):
        $Panel/Combo.update_upgrade("combo", upgrades["combo"])
    

func _on_UpgradeItem_upgraded(upgrade_name: String, level: float, upgrade_cost: int) -> void:
    emit_signal("upgraded", upgrade_name, level, upgrade_cost)


func _process(delta: float) -> void:
    if delta:
        pass
    if Input.is_action_just_pressed("upgrade_interface_open_close"):
        if is_visible_in_tree():
            hide()
        else:
            show()


func update_credits(credits: int) -> void:
    $Panel/Speed.disable_upgrade_button(credits)
    $Panel/Health.disable_upgrade_button(credits)
    $Panel/Combo.disable_upgrade_button(credits)


func _on_CloseButton_pressed() -> void:
    emit_signal("closed")
    hide()
    