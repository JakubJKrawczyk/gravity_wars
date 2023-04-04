@tool
extends RigidBody2D


class_name MassObject

## Gravity constant
var G: float = pow(10, 5)

@export var radius: float = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_size(Vector2(radius/10, radius/10))

func update_line(target: Vector2):
	($RayCast2D as RayCast2D).target_position = target

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		update_line(linear_velocity)
		set_size(Vector2(radius/10, radius/10))
		return
	if is_queued_for_deletion():
		return
	var resultant_force: Vector2 = Vector2.ZERO
	for obj in get_tree().get_nodes_in_group("mass-obj"):
		var mo = obj as MassObject
		if mo == null:
			continue
		if mo.name == name:
			continue
		if mo.is_queued_for_deletion():
			continue
		var dist := global_position.distance_to(mo.global_position)
		var force = G*(mass * mo.mass) / pow(dist, 2)
		resultant_force += global_position.direction_to(mo.global_position) * force
	constant_force = resultant_force

func get_color() -> Color:
	return (material as ShaderMaterial).get_shader_parameter("color")

func set_color(color: Color):
	(material as ShaderMaterial).set_shader_parameter("color", color)

func get_size() -> Vector2:
	return ($CollisionShape2D as CollisionShape2D).scale

func set_size(scale: Vector2):
	($CollisionShape2D as CollisionShape2D).scale = scale

func sgn(x: float) -> float:
	return x/abs(x)

func _on_impact(body: Node) -> void:
	if is_queued_for_deletion():
		return
	var mo = body as MassObject
	if mo == null:
		return
	if mo.mass > mass:
		return
	printt(name, "impact", linear_velocity, mass, mo.linear_velocity, mo.mass)
	var my_volume = get_size().x * get_size().y
	var mo_volume = mo.get_size().x * mo.get_size().y
	var x = sqrt(my_volume + mo_volume)
	set_size(Vector2(x, x))
	var old_dense = mass/(my_volume*PI);
	
	global_position = (global_position + mo.global_position)/2
	
	mass += mo.mass
	constant_force = Vector2.ZERO
	
	var my_ek = linear_velocity.normalized() * pow(linear_velocity.length(), 2) * mass
	var mo_ek = mo.linear_velocity.normalized() * pow(mo.linear_velocity.length(), 2) * mo.mass
	var v2: Vector2 = (my_ek + mo_ek)/(mass+mo.mass)
	linear_velocity = Vector2(sqrt(abs(v2.x)) * sgn(v2.x), sqrt(abs(v2.y)) * sgn(v2.y))
	
	var my_color = get_color()
	var mo_color = mo.get_color()
	var blend = my_color.lerp(mo_color, 0.5)
	var new_dense = mass / ((my_volume+mo_volume)*PI)
	var diff = new_dense/old_dense
	set_color(blend * diff)
	
	mo.queue_free()
