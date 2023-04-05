extends Control




func _on_continue_pressed():
	pass # Replace with function body.


func _on_new_game_pressed():
	get_tree().change_scene_to_file("res://Levels/Playground.tscn")


func _on_options_pressed():
	var settings = get_child(1) as Control
	settings.visible = true

func _on_exit_pressed():
	get_tree().quit()


func _on_return_settings_pressed():
	var settings = get_child(1) as Control
	settings.visible = false
