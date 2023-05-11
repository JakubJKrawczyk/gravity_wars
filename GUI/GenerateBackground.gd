extends Node

#Preloads
@onready var massObject = preload("res://Objects/mass-object.tscn")

#All properies
@onready var container = get_node("ObjectContainer") as Node
var counter = 0
@onready var ListOfMass = []
@onready var shader = preload("res://Objects/mass-object.gdshader") as Shader
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	counter+=1
	if fmod(counter, 50) == 0:
		print_debug("Dupa stworzona")
		CreateMassObject()
	
	
	
func CreateMassObject():
	var massObj = massObject.instantiate() as MassObject
	
	var rand = RandomNumberGenerator.new()
	var r = randf()
	var g = randf()
	var b = randf()
	var color = Color(r,g,b)

	
	massObj.mass = 10
	massObj.set("radius", rand.randi_range(1,25))
	massObj.set("position", Vector2(rand.randi_range(1,get_window().size.x), rand.randi_range(1,get_window().size.y) ))
	massObj.z_index = 0
	massObj.IsMenu = true
	massObj.set_color(color)
	
	
	print_debug("Z-index: ",massObj.get("z"))
	container.add_child(massObj)
	
	pass
