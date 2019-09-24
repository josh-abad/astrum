extends MarginContainer

signal closed

const ACHIEVEMENT_ITEM = "res://Achievements/UI/AchievementItem.tscn";

var achievementPanel = null;
var achievementsNodes = {};

func init(achievements):
    achievementPanel = $Background/Layout/MarginContainer/Panel/MarginContainer/ScrollContainer/VBoxContainer;
    for i in achievements:
        var achievement = load(ACHIEVEMENT_ITEM).instance();
        achievement.set_achievement(achievements[i]);
        achievementsNodes[i] = achievement;
        achievementPanel.add_child(achievement);


func _on_Button_pressed():
    emit_signal("closed")
    _display(false)


func _update_bar(achievement_name, achievement):
    achievementsNodes[achievement_name].update_progress_bar(achievement)
    
    
func _display(yes: bool) -> void:
    $Tween.interpolate_property(self, 'rect_position', rect_position, Vector2(0, 0) if yes else Vector2(-320, 0), 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.start()
    if yes:
        show()
    else:
        yield(get_tree().create_timer(1), "timeout")
        hide()