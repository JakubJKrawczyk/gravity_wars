extends MassObject

class_name UserMassObject

@onready var velocity_arrow = $Arrow as Node2D

func _ready() -> void:
	remove_from_group("mass-obj")
	
func _process(delta: float) -> void:
	velocity_arrow.scale = Vector2(linear_velocity.length() / 10, 1)
	velocity_arrow.look_at(linear_velocity + global_position)

func release():
	freeze = false
	velocity_arrow.visible = false
	add_to_group("mass-obj")
	
func _on_impact(body: Node) -> void:
	if !(body is UserMassObject):
		remove_from_group("user-obj")
	super._on_impact(body)
