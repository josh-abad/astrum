extends MarginContainer

signal closed
signal tween_complete

const ACHIEVEMENT_ITEM = "res://Achievements/UI/AchievementItem.tscn";

var achievementPanel = null;
var achievementsNodes = {};

func init(achievements):
    achievementPanel = $Background/Layout/MarginContainer/Panel/MarginContainer/ScrollContainer/VBoxContainer
    for i in achievements:
        var achievement = load(ACHIEVEMENT_ITEM).instance()
        achievement.set_achievement(achievements[i])
        achievementsNodes[i] = achievement
        achievementPanel.add_child(achievement)


func _on_Button_pressed() -> void:
    emit_signal("closed")
    _display(false)


func _update_bar(achievement_name: String, achievement) -> void:
    achievementsNodes[achievement_name].update_progress_bar(achievement)
    
    
func _display(yes: bool) -> void:
    if yes:
        show()
    $Tween.interpolate_property(self, 'rect_position', rect_position, Vector2(0, 0) if yes else Vector2(-320, 0), 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.interpolate_property(self, 'modulate', modulate, Color(1, 1, 1, 1) if yes else Color(1, 1, 1, 0), 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.start()


func _on_Tween_tween_all_completed() -> void:
    emit_signal("tween_complete")