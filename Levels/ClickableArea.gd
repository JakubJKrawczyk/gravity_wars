extends Control

@export var container: Node
@export var user_object_scene: PackedScene
@export var max_stars = 3
@export var star_size = 5
@export var star_mass = 5
@export var objective_pass: LabelSettings
@export var objective_fail: LabelSettings
@export var shader: Shader
@export var color: Color

var object: UserMassObject = null

var pressed: bool = false

func _ready() -> void:
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
	if event is InputEventMouseButton:
		if (event as InputEventMouseButton).button_index != 1:
			return
		if (event as InputEventMouseButton).pressed:
			if object != null || max_stars <= 0:
				return
			object = user_object_scene.instantiate() as UserMassObject
			object.material = ShaderMaterial.new()
			(object.material as ShaderMaterial).shader = shader
			(object.material as ShaderMaterial).set_shader_parameter("color", color)
			object.position = (event as InputEventMouseButton).position - ($"../ObjectsContainer" as Node2D).position
			object.set_size(Vector2(star_size/10.0, star_size/10.0))
			object.mass = star_mass
			container.add_child(object)
			max_stars -= 1
			($GridContainer/StarsValue as Label).text = str(max_stars)
		elif object != null:
			object.release()
			object = null
	elif event is InputEventMouseMotion:
		if object != null:
			var mpos = (event as InputEventMouseMotion).position
			object.linear_velocity = object.global_position - mpos
