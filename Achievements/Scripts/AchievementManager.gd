extends Node

const ACHIEVEMENT_DATA_SCRIPT = "res://Achievements/Scripts/AchievementData.gd";
const INTERFACE_SCREEN = "res://Achievements/UI/AchievementInterface.tscn"
const INTERFACE_OPENCLOSE_ACTION = "achievement_interface_open_close"

var achievement_data = null
var achievement_interface = null
var displayed: bool = false

signal updated
signal closed
signal display_popup(achievement_name)

func _ready():
    if AchievementHelper.connect("reward_claimed", self, "_on_reward_claimed"):
        pass
    if AchievementHelper.connect("popup_requested", self, "_on_popup_requested"):
        pass
    achievement_data = load(ACHIEVEMENT_DATA_SCRIPT).new();
    achievement_interface = load(INTERFACE_SCREEN).instance();
    achievement_interface.init(achievement_data.get_achievements());
    achievement_interface.hide();
    add_child(achievement_interface);
    if self.connect("updated", achievement_interface, "_update_bar"):
        pass
    if achievement_interface.connect("closed", self, "_on_AchievementInterface_closed"):
        pass
    if achievement_interface.connect("tween_complete", self, "_on_tween_complete"):
        pass
    
    
func _on_tween_complete() -> void:
    if not displayed:
        achievement_interface.hide()
    
    
func _on_AchievementInterface_closed() -> void:
    emit_signal("closed")
    displayed = false
    
    
func _process(delta: float):
    if delta:
        pass
    if Input.is_action_just_pressed(INTERFACE_OPENCLOSE_ACTION):
        if displayed:
            achievement_interface._display(false)
            displayed = false
        else:
            achievement_interface._display(true)
            displayed = true


func _is_achievement_complete(achievement_name: String) -> bool:
    var achievements = achievement_data.get_achievements();
    if achievements.has(achievement_name):
        var achievement = achievements[achievement_name]
        var progress = achievement.get_progress()
        var total = achievement.get_total()
        return progress >= total
    return false


func _on_reward_claimed(achievement_name: String) -> void:
    var achievements = achievement_data.get_achievements()
    if achievements.has(achievement_name):
        achievements[achievement_name].set_reward_claimed(true)
        achievement_data.save()
        emit_signal("updated", achievement_name, achievements[achievement_name])
        
        
func _on_popup_requested(achievement_name: String) -> void:
    var achievements = achievement_data.get_achievements()
    if achievements.has(achievement_name) and not achievements[achievement_name].is_popup_displayed():
        emit_signal("display_popup", achievements[achievement_name].get_name())
        achievements[achievement_name].set_popup_displayed(true)
        

func increment_achievement(achievement_name, amount):
    var achievements = achievement_data.get_achievements();
    if achievements.has(achievement_name):
        if _is_achievement_complete(achievement_name):
            return
        achievements[achievement_name].increment(amount);
        achievement_data.save();
        emit_signal("updated", achievement_name, achievements[achievement_name]);
        
        
func reset_achievement(achievement_name: String) -> void:
    var achievements = achievement_data.get_achievements()
    if achievements.has(achievement_name) and not _is_achievement_complete(achievement_name):
        achievements[achievement_name].set_value("progress", 0)
        achievements[achievement_name].set_value("rewardClaimed", false)
        achievements[achievement_name].set_value("popupDisplayed", false)
        emit_signal("updated", achievement_name, achievements[achievement_name]);
            