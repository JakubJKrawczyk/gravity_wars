extends Objective

class_name GravityWell

@export var arena: Area2D
@export var user_group: String
@export var init_stars: int

var register: Dictionary

func _ready():
	register = {}
	completed = false

func update(available_stars: int) -> void:
	if completed:
		return
	var colliding = arena.get_overlapping_bodies()
	for body in colliding:
		if body.is_in_group(user_group) and !register.has(body):
			register[body] = (body as RigidBody2D).linear_velocity.length()
	for key in register.keys():
		if colliding.has(key) or register.get(key) == null:
			continue
		if (key as RigidBody2D).linear_velocity.length() > register.get(key):
			completed = true
			break
		register[key] = null
	if !completed and register.size() == init_stars:
		# Jeżeli wszystkie gwiazdy były w centrum i wyleciały to niemożliwe do spełnienia
		# Jeżeli żadna gwiazda nie istnieje, a nie ma innych to niemożliwe
		var all_null = true
		for key in register.keys():
			if register.get(key) != null:
				all_null = false
				break
		impossible = true
