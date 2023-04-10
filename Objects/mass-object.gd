@tool
extends RigidBody2D


class_name MassObject

## Gravity constant
var G: float = pow(10, 5)

@export var radius: float = 10
@export var temperature: float = 1500.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_size(Vector2(radius/10, radius/10))
	var current_shader = (material as ShaderMaterial).shader
	material = ShaderMaterial.new()
	(material as ShaderMaterial).shader = current_shader
	set_color(temp_to_color(temperature))

func update_line(target: Vector2):
	($RayCast2D as RayCast2D).target_position = target

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		update_line(linear_velocity)
		set_size(Vector2(radius/10, radius/10))
		set_color(temp_to_color(temperature))
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
	printt(name, mass, linear_velocity.length(), temperature)

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
	
	var my_volume = get_size().x * get_size().y
	var mo_volume = mo.get_size().x * mo.get_size().y
	var x = sqrt(my_volume + mo_volume)
	set_size(Vector2(x, x))
	
	var old_mass = mass
	var old_dense = mass/(my_volume*PI);
	
	global_position = (global_position + mo.global_position)/2
	mass += mo.mass
	constant_force = Vector2.ZERO
	
	var my_temp = color_to_temp(get_color())
	var mo_temp = color_to_temp(mo.get_color())
	temperature = ((my_temp * old_mass) + (mo_temp * mo.mass)) / mass
	set_color(temp_to_color(temperature))
	
	mo.queue_free()

func temp_to_color(temp: float):
	var b = 0
	if temp < 1900:
		b = 0
	elif temp < 6500:
		b = 0.0554348 * temp - 105.326
	else: # 6500 = 255 => 12000 = 195
		b = 255
	
	var g = 0
	if temp < 6500:
		g = 0.0361818 * temp + 19.8182
	else: # 6500 = 255 => 12000 = 195
		g = -0.00836364 * temp + 309.364
		
	var r = 0
	if temp < 6500:
		r = 255
	else: # 6500 = 255 => 12000 = 195
		r = -0.011*temp+325.909
	
	return Color(r/255., g/255., b/255.)

func color_to_temp(color: Color):
	if color.r8 == 255:
		return 21.5686 * color.g8 + 1000
	else:
		return -91.6667 * color.r8 + 29875
