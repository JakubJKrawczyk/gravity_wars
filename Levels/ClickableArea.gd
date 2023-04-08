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
	
func _physics_process(delta: float) -> void:
	var survive = false
	var push_out = true
	for body in ($"../Arena" as Area2D).get_overlapping_bodies():
		if body.is_in_group("user-obj"):
			survive = true
		elif body.is_in_group("mass-obj"):
			push_out = false
	($VBoxContainer/Survive as Label).label_settings = objective_pass if survive else objective_fail
	($"VBoxContainer/Push out everyone" as Label).label_settings = objective_pass if push_out else objective_fail

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
