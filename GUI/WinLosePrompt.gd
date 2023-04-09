@tool
extends Control

class_name WinLosePrompt

@export var back_next: bool = true

signal next_click
signal replay_click
signal back_click

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if back_next:
		$Replay.visible = false
		$Next.visible = true
		$MainMessage.text = "You win!"
	else:
		$Replay.visible = true
		$Next.visible = false
		$MainMessage.text = "You lose. Try again?"


func _on_next_gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton) and (event as InputEventMouseButton).pressed:
		emit_signal("next_click")

func _on_replay_gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton) and (event as InputEventMouseButton).pressed:
		emit_signal("replay_click")

func _on_back_to_menu_gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton) and (event as InputEventMouseButton).pressed:
		emit_signal("back_click")
