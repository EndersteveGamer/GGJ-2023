extends Node2D

var grid=[]
var gridSize=64
var gridWidth=64
onready var plant=get_node("Plant")
func pointToGrid(x):
	return floor(x/gridWidth)*gridSize

func stickToGrid(x):
	gridGet(x).position.x=pointToGrid(gridGet(x).position.x)

func gridGet(x):
	return grid[x]

func gridHas(x):
	return gridGet(x)!=null

func gridSet(x,what):
	if not gridHas(x):
		grid[x]=what

func gridTake(x):
	if gridHas(x):
		var got=gridGet(x)
		grid[x]=null
		return got
	return null

func createPlant(x):
	var newPlant=plant.instance()
	add_child(newPlant)
	gridSet(x,newPlant)
	return newPlant

# Called when the node enters the scene tree for the first time.
func _ready():
	grid.resize(gridSize)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
