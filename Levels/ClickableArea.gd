extends Control

class_name ClickableArea

@export var container: Node
@export var objective_pass: LabelSettings
@export var objective_fail: LabelSettings
@export var shader: Shader
@export var color: Color

signal create_star(position: Vector2)
signal release_star
signal update_star(position: Vector2)

var object: bool = false

var pressed: bool = false

func update_star_params(count, mass, _size):
	($GridContainer/StarsValue as Label).text = str(count)
	($GridContainer/MassValue as Label).text = str(mass)
	($GridContainer/SizeValue as Label).text = str(_size)
	
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and (event as InputEventMouseButton).button_index == 1:
		if (event as InputEventMouseButton).pressed:
			if object:
				return
			emit_signal("create_star", (event as InputEventMouseButton).position - ($"../ObjectsContainer" as Node2D).position)
			object = true
		elif object:
			emit_signal("release_star")
			object = false
	elif event is InputEventMouseMotion:
		if !object:
			return
		emit_signal("update_star", (event as InputEventMouseMotion).position)
