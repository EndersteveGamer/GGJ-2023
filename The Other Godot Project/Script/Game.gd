extends Node2D

var grid=[]
var gridSize=64 # number of case
var gridWidth=64 # width of each case
onready var plant=preload("res://Scene/Plant.tscn")
onready var rng=RandomNumberGenerator.new()

func pointToGrid(x):
	return floor(x/gridWidth)*gridWidth
	
func gridToPoint(x):
	return x*gridWidth

func stickToGrid(x):
	gridGet(x).position.x=pointToGrid(gridGet(x).position.x)

func gridGet(x):
	return grid[x]

func gridHas(x):
	return gridGet(x)!=null

func gridSet(x,what):
	if not gridHas(x):
		grid[x]=what
		what.index=x
		what.position.x=gridToPoint(x)

func gridTake(x):
	if gridHas(x):
		var got=gridGet(x)
		got.index=-1
		grid[x]=null
		return got
	return null

func createPlant(x):
	print(plant)
	if plant!=null:
		var newPlant=plant.instance()
		add_child(newPlant)
		gridSet(x,newPlant)
		return newPlant
	return null

func spawnPlantRandom():
	var x=rng.randi()%gridSize
	while gridHas(x):
		x+=1
		if x>gridSize:
			x=0
	return createPlant(x)

# Called when the node enters the scene tree for the first time.
func _ready():
	grid.resize(gridSize)
	rng.randomize()
	createPlant(2)
	createPlant(3)
	createPlant(4)
	spawnPlantRandom()
	spawnPlantRandom()
	spawnPlantRandom()
	spawnPlantRandom()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
