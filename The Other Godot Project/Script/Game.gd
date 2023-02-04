extends Node2D

var grid=[]
var soilColor=[]
var gridSize=128 # number of case
var gridWidth=64 # width of each case
var startingTiles : int =14
var victory : int=startingTiles+0
var tiles=startingTiles
var start=(gridSize-startingTiles)/2
onready var plant=preload("res://Scene/Plant.tscn")
onready var soil=preload("res://Scene/Soil.tscn")

onready var rng=RandomNumberGenerator.new()

export var plantSpawndBase=20
var plantSpawnCurrent=plantSpawndBase
export var plantSpawnIncrement=1
export var plantSpawnDecrement=1
export var plantSpawnTimer=0

var timeTaken = 0

var sinsIndex=[
	"wrath",
	"envy",
	"lust",
	"sloth",
	"greed",
	"gluttony",
	"pride",
]
var sins={
	"wrath":
	{
		"index":0,
		"color":Color(1,0,0),
		"desc":"Reduces nearby progression, but have a progression addition when a new plant appears next by"
	},
	"envy":
	{
		"index":1,
		"color":Color(1,0.5,0),
		"desc":"Grow faster when nearby plants are further ahead"
	},
	"lust":
	{
		"index":2,
		"color":Color(1,0,1),
		"desc":"When grown, will clone the nearby plant to the other side if there's space"
	},
	"sloth":
	{
		"index":3,
		"color":Color(0.5,0.5,0.5),
		"desc":"Grows faster if there's no plants to the sides"
	},
	"greed":
	{
		"index":4,
		"color":Color(1,1,0),
		"desc":"When used to grow the road, will add a bit progression to all but greed plants"
	},
	"gluttony":
	{
		"index":5,
		"color":Color(0,1,0),
		"desc":"Steals part of nearby progression when placed"
	},
	"pride":
	{
		"index":6,
		"color":Color(0,0.5,1),
		"desc":"Grows faster if it's ahead of the other plants"
	}
}

# get the sin data
func getSin(sI):
	return sins[sinsIndex[sI]]
	
func getPlantsNum():
	var plantsNum : int = 0
	for plant in grid:
		if plant != null:
			plantsNum += 1
	return plantsNum

func getSinColorCode(sI):
	return getSin(sI)["color"]

func plantGetSin(x):
	return getSin(grid[x].color)

func plantGetSinName(x):
	print("get name "+str(x))
	return sinsIndex[grid[x].color]

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
		newPlant.audioManager=get_node("AudioManager")
		newPlant.color=rng.randi()%7
		return newPlant
	return null

func spawnPlantRandom():
	var x=rng.randi()%tiles+start
	var threshold=100
	var i=0
	while gridHas(x):
		x+=1
		if x>gridSize:
			x=0
		i+=1
	if i<threshold:
		return createPlant(x)
	return null

func createSoil(x):
	var newSoil=soil.instance()
	newSoil.modulate=getSinColorCode(soilColor[x])
	newSoil.modulate.a=0.5
	newSoil.position.y=64
	newSoil.scale.x=2
	newSoil.scale.y=2
	add_child(newSoil)
	newSoil.position.x=gridToPoint(x)

# Called when the node enters the scene tree for the first time.
func _ready():
	grid.resize(gridSize)
	soilColor.resize(gridSize)
	rng.randomize()
	spawnPlantRandom() # Replace with function body.
	var leftColor=[2,2,2,2,2,2,2]
	for i in range(start,start+tiles):
		soilColor[i]=rng.randi()%7
		while leftColor[soilColor[i]]==0:
			soilColor[i]=rng.randi()%7
		leftColor[soilColor[i]]-=1
		createSoil(i)
	get_node("TileMap").position.x+start*gridWidth

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timeTaken += delta
	plantSpawnTimer+=delta
	if plantSpawnTimer>plantSpawnCurrent:
		if getPlantsNum() <= tiles - 5:
			spawnPlantRandom()
		plantSpawnTimer-=plantSpawnCurrent
		plantSpawnCurrent *= 0.95
		if plantSpawnCurrent < 3: plantSpawnCurrent = 3

func endGame():
	var endScreen = get_node("/root/EndScreen")
	print(timeTaken)
	endScreen.timeTaken = timeTaken
	endScreen.isGameEnded = true
	get_tree().change_scene("res://Scene/End Screen.tscn")
