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

var max_stars: int = 0
var star_mass: int
var star_size: int

func update_star_params(count, mass, _size):
	max_stars = count
	star_mass = mass
	star_size = _size
	($GridContainer/StarsValue as Label).text = str(max_stars)
	($GridContainer/MassValue as Label).text = str(star_mass)
	($GridContainer/SizeValue as Label).text = str(star_size)
	
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
			if object || max_stars <= 0:
				return
			emit_signal("create_star", (event as InputEventMouseButton).position - ($"../ObjectsContainer" as Node2D).position)
			object = true
			max_stars -= 1
			($GridContainer/StarsValue as Label).text = str(max_stars)
		elif object:
			emit_signal("release_star")
			object = false
	elif event is InputEventMouseMotion:
		if !object:
			return
		emit_signal("update_star", (event as InputEventMouseMotion).position)
		"""var mpos = (event as InputEventMouseMotion).position
		object.linear_velocity = object.global_position - mpos"""
