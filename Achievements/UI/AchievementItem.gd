extends Panel

const REWARD: int = 1000

var name_text: String
var progress_bar = null;
var progress_text = null;
var picture_parent = null;
var picture = null;
var achievement


func claim_reward() -> void:
    AchievementHelper.emit_signal("reward_claimed", achievement.get_key())
    
    progress_text.set_text("Completed!")
    
    progress_bar.texture_progress = GradientTexture.new();
    progress_bar.texture_progress.gradient = Gradient.new();
    progress_bar.texture_progress.gradient.set_color(0, Palette.REVO);
    progress_bar.texture_progress.gradient.set_color(1, Palette.REVO);


func set_achievement(achievement):
    progress_bar = $MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/MarginContainer/TextureProgress;
    progress_text = $MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/MarginContainer/TextureProgress/Label;
    picture_parent = $MarginContainer/HBoxContainer/Picture;
    picture = $MarginContainer/HBoxContainer/Picture/TextureRect;
    
    self.achievement = achievement
    if achievement.is_reward_claimed():
        claim_reward()
    if achievement.is_complete():
        AchievementHelper.emit_signal("popup_requested", achievement.get_key())
    set_text(achievement);
    update_progress_bar(achievement);
    set_custom_progress_bar_colors(achievement);
    set_or_remove_picture(achievement);
    progress_bar.max_value = achievement.get_total();


func set_text(achievement):
    name_text = achievement.get_name()
    $MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/Name.set_text(achievement.get_name());
    $MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/Description.set_text(achievement.get_desc());


func update_progress_bar(achievement):
    progress_bar.value = achievement.get_progress();
    update_progress_bar_text(achievement);


func update_progress_bar_text(achievement):
    if achievement.is_reward_claimed():
        return
    if achievement.is_complete():
        AchievementHelper.emit_signal("popup_requested", achievement.get_key())
        progress_text.set_text("claim " + str(REWARD))
        return
    progress_text.set_text("%s / %s" % [achievement.get_progress(), achievement.get_total()]);


func set_custom_progress_bar_colors(achievement):
    if achievement.is_reward_claimed():
        return
    if achievement.has_custom_progress_bar_colors():
        progress_bar.texture_under = GradientTexture.new();
        progress_bar.texture_under.gradient = Gradient.new();
        progress_bar.texture_under.gradient.set_color(0, achievement.get_progress_bar_background_color());
        progress_bar.texture_under.gradient.set_color(1, achievement.get_progress_bar_background_color());

        progress_bar.texture_progress = GradientTexture.new();
        progress_bar.texture_progress.gradient = Gradient.new();
        progress_bar.texture_progress.gradient.set_color(0, Palette.ORANGE);
        progress_bar.texture_progress.gradient.set_color(1, Palette.ORANGE);


func set_or_remove_picture(achievement):
    if !achievement.has_picture():
        picture_parent.queue_free();
        return;
    
    var image = ImageTexture.new();
    image.load(achievement.get_picture_location());
    picture.texture = image;


func _on_TextureProgress_gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.pressed:
        if achievement.is_complete() and not achievement.is_reward_claimed():
            CreditManager.set_credits(CreditManager.get_credits() + REWARD)
            achievement.set_reward_claimed(true)
            claim_reward()