extends Objective

class_name SurviveObjective

@export var user_group: String
@export var arena: Area2D

func update(available_stars: int) -> void:
	completed = true
	var colliding = arena.get_overlapping_bodies()
	for body in colliding:
		if body.is_in_group(user_group):
			completed = true
			break
	label.label_settings = completed_settings if completed else incompleted_settings
	impossible = false
	if available_stars != 0 or completed:
		return
	var stars = get_local_scene().get_tree().get_nodes_in_group(user_group)
	for star in stars:
		if !(star is RigidBody2D):
			continue
		var velocity_direction = (star as RigidBody2D).linear_velocity
		var space = (star as RigidBody2D).get_world_2d().direct_space_state
		var query = PhysicsRayQueryParameters2D.create((star as RigidBody2D).global_position, (star as RigidBody2D).global_position + (velocity_direction * 100))
		query.exclude = [self]
		var result = space.intersect_ray(query)
		if !result.is_empty() and result.collider == arena:
			return
	impossible = true
