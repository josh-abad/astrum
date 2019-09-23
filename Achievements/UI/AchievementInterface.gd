extends MarginContainer

signal achievement_complete(achievement_name)
signal closed

const ACHIEVEMENT_ITEM = "res://Achievements/UI/AchievementItem.tscn";

var achievementPanel = null;
var achievementsNodes = {};

func init(achievements):
    achievementPanel = $Background/Layout/MarginContainer/Panel/MarginContainer/ScrollContainer/VBoxContainer;
    for i in achievements:
        var achievement = load(ACHIEVEMENT_ITEM).instance();
        achievement.connect("achievement_complete", self, "_on_achievement_complete")
        achievement.set_achievement(achievements[i]);
        achievementsNodes[i] = achievement;
        achievementPanel.add_child(achievement);


func _on_achievement_complete(achievement_name: String) -> void:
    
    # Signal emitted to AchievementManager
    emit_signal("achievement_complete", achievement_name)


func _on_Button_pressed():
    emit_signal("closed")
    hide();

func _update_bar(achievement_name, achievement):
    achievementsNodes[achievement_name].update_progress_bar(achievement)