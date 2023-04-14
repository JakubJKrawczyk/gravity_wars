extends Container
@onready var directory = DirAccess.open("res://Levels")
@onready var levelTemplate = preload("res://GUI/Templates/Level/LevelTemplate.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	var levels : Array = []
	var regex = RegEx.new()
	regex.compile("level[0-9]+.tscn")
	for file in directory.get_files():
		if regex.search(file):
			levels.push_back(file.get_basename())
	var counter = 1
	for level in levels:
		print_debug(level)
		AddLevelBox(level, counter)
		counter += 1
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func AddLevelBox(name, boxNumber):
	var level = load("res://Levels/" + name + ".tscn") as PackedScene
	var box : LevelTemplate = levelTemplate.instantiate() as LevelTemplate
	box.SetLevel(level, name)
	if boxNumber <= 8:	
		box.position = Vector2(240*boxNumber, 0)	
	elif boxNumber > 8 and boxNumber <= 16:
		box.position = Vector2(240*boxNumber, 250)	
	add_child(box)
