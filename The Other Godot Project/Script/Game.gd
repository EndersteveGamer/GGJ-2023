extends Node2D

var grid=[]
var gridSize=64 # number of case
var gridWidth=64 # width of each case
onready var plant=preload("res://Scene/Plant.tscn")
onready var rng=RandomNumberGenerator.new()

func pointToGrid(x):
	return floor(x/gridWidth)
	
func gridToPoint(x):
	return x*gridWidth

func gridStick(what):
	what.index=pointToGrid(what.position.x)
	what.position.x=gridToPoint(what.index)

func gridStickFromIndex(what):
	what.position.x=gridToPoint(what.index)

func stickToGrid(x):
	gridStickFromIndex(gridGet(x))

func gridGet(x):
	return grid[x]

func gridHas(x):
	return gridGet(x)!=null

func gridSet(x,what):
	if not gridHas(x):
		print("set")
		grid[x]=what
		what.index=x
		stickToGrid(x)
		return true
	return false

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
		newPlant.owner=self
		gridSet(x,newPlant)
		newPlant.position.y+=32
		print("index "+str(newPlant.index))
		newPlant.audioManager=owner.get_node("AudioManager")
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
	for i in range(16):
		createPlant(i*4)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
