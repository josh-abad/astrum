extends Node

const ACHIEVEMENT_DATA_SCRIPT = "res://Achievements/Scripts/AchievementData.gd";
const INTERFACE_SCREEN = "res://Achievements/UI/AchievementInterface.tscn";
const INTERFACE_OPENCLOSE_ACTION = "achievement_interface_open_close";

var achievement_data = null;
var achievement_interface = null;

signal updated;

func _ready():
    achievement_data = load(ACHIEVEMENT_DATA_SCRIPT).new();
    achievement_interface = load(INTERFACE_SCREEN).instance();
    achievement_interface.init(achievement_data.get_achievements());
    achievement_interface.hide();
    add_child(achievement_interface);
    if self.connect("updated", achievement_interface, "_update_bar"):
        pass

func _process(delta: float):
    if delta:
        pass
    if Input.is_action_just_pressed(INTERFACE_OPENCLOSE_ACTION):
        if achievement_interface.is_visible_in_tree():
            achievement_interface.hide();
        else:
            achievement_interface.show();

func increment_achievement(achievement_name, amount):
    var achievements = achievement_data.get_achievements();
    if achievements.has(achievement_name):
        achievements[achievement_name].increment(amount);
        achievement_data.save();
        emit_signal("updated", achievement_name, achievements[achievement_name]);
        
        
func reset_achievement(achievement_name: String) -> void:
    var achievements = achievement_data.get_achievements()
    if achievements.has(achievement_name):
        var achievement = achievements[achievement_name]
        var progress = achievement.get_progress()
        var total = achievement.get_total()
        if progress < total:
            achievement.set_value("progress", 0)
            emit_signal("updated", achievement_name, achievements[achievement_name]);
            