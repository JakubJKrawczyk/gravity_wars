extends Objective

class_name EscapeObjective

@export var arena: Area2D
@export var user_group: String
@export var cosmos_border: float = 1000

func update(available: int):
	completed = true
	var bodies = arena.get_tree().get_nodes_in_group(user_group)
	var all_out = available == 0
	for body in bodies:
		if (body as RigidBody2D).position.length() <= cosmos_border:
			all_out = false
		if !all_out:
			break
	if all_out:
		impossible = true
	
