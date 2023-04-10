extends Node2D

class_name Level

signal win
signal lose

@export_category("Objectives")
@export var objectives: Array[Objective]

@export_category("User star")
@export var available_stars: int = 3
@export var star_mass: float = 1.
@export var star_radius: float = 5.
@export var shader: Shader
@export var color: Color = Color.AQUA
@export var star_scene: PackedScene

@export_category("Game settings")
@export var menu_scene: PackedScene
@export var next_scene: PackedScene

var object: UserMassObject = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	($ClickableArea as ClickableArea).update_star_params(available_stars, star_mass, star_radius)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for objective in objectives:
		objective.update(available_stars)
	var win_timer = true
	for objective in objectives:
		if objective.impossible:
			emit_signal("lose")
			return
		if not objective.completed:
			win_timer = false
			break
	if win_timer and ($WinTimer as Timer).is_stopped():
		($WinTimer as Timer).start()

func _on_create_star(position: Vector2) -> void:
	if available_stars == 0:
		return
	available_stars -= 1
	object = star_scene.instantiate() as UserMassObject
	object.material = ShaderMaterial.new()
	(object.material as ShaderMaterial).shader = shader
	(object.material as ShaderMaterial).set_shader_parameter("color", color)
	object.set_size(Vector2(star_radius/10.0, star_radius/10.0))
	object.mass = star_mass
	object.position = position
	($ObjectsContainer).add_child(object)
	($ClickableArea as ClickableArea).update_star_params(available_stars, star_mass, star_radius)

func _on_release_star() -> void:
	if object == null:
		return
	object.release()
	object = null

func _on_update_star(position) -> void:
	if object == null:
		return
	object.linear_velocity = object.global_position - position

func _on_win_timer_timeout() -> void:
	emit_signal("win")

func _on_lose() -> void:
	get_tree().paused = true
	($WLP/WinLosePrompt as WinLosePrompt).back_next = false
	$WLP.visible = true

func _on_win() -> void:
	get_tree().paused = true
	($WLP/WinLosePrompt as WinLosePrompt).back_next = true
	$WLP.visible = true

func _on_win_lose_prompt_back_click() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_packed(menu_scene)

func _on_win_lose_prompt_next_click() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_packed(next_scene)

func _on_win_lose_prompt_replay_click() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
