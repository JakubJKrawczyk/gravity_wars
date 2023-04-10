extends Objective

class_name PushOutObjective

@export var default_group: String
@export var user_group: String
@export var arena: Area2D

func update(_available_stars: int) -> void:
	impossible = false
	completed = true
	var colliding = arena.get_overlapping_bodies()
	for body in colliding:
		if body.is_in_group(default_group) and !body.is_in_group(user_group):
			completed = false
			break
	label.label_settings = completed_settings if completed else incompleted_settings
