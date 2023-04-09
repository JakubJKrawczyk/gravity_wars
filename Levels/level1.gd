extends Level


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for objective in objectives:
		if objective is SurviveObjective or objective is PushOutObjective:
			objective.arena = $Arena
		if objective is SurviveObjective:
			objective.label = $ClickableArea/VBoxContainer/Survive
		elif objective is PushOutObjective:
			objective.label = $ClickableArea/VBoxContainer/PushOut
	super._ready()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)
