extends Resource

class_name Objective

@export var label: Label

var completed: bool = false
var impossible: bool = false

func update(available_stars: int) -> void:
	push_error("Not implemented update(): ", self)
	return
