extends Control

@export var menu : PackedScene

func _on_continue_pressed():
	pass # Replace with function body.


func _on_new_game_pressed():
	var levels = get_child(4) as Control
	var mainmenu = get_child(1) as Sprite2D
	levels.visible = true
	mainmenu.visible = false

func _on_options_pressed():
	var settings = get_child(2) as Control
	var mainmenu = get_child(1) as Sprite2D
	settings.visible = true
	mainmenu.visible = false
func _on_exit_pressed():
	get_tree().quit()


func _on_return_settings_pressed():
	var settings = get_child(2) as Control
	var mainmenu = get_child(1) as Sprite2D
	settings.visible = false
	mainmenu.visible = true


func _on_return_pressed():
	var levels = get_child(4) as Control
	var mainmenu = get_child(1) as Sprite2D
	levels.visible = false
	mainmenu.visible = true
