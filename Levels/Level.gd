extends Node2D

class_name Level

@export_category("Objectives")
@export var objectives: Array[Objective]

@export_category("User star")
@export var init_star_limit: int = 3
@export var star_mass: float = 1.
@export var star_radius: float = 5.
@export var shader: Shader
@export var color: Color = Color.AQUA
@export var star_scene: PackedScene

var object: UserMassObject = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	($ClickableArea as ClickableArea).update_star_params(init_star_limit, star_mass, star_radius)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for objective in objectives:
		objective.update()

func _on_create_star(position: Vector2) -> void:
	object = star_scene.instantiate() as UserMassObject
	object.material = ShaderMaterial.new()
	(object.material as ShaderMaterial).shader = shader
	(object.material as ShaderMaterial).set_shader_parameter("color", color)
	object.set_size(Vector2(star_radius/10.0, star_radius/10.0))
	object.mass = star_mass
	object.position = position
	($ObjectsContainer).add_child(object)

func _on_release_star() -> void:
	if object == null:
		return
	object.release()
	object = null

func _on_update_star(position) -> void:
	if object == null:
		return
	object.linear_velocity = object.global_position - position
