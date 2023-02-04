extends Node2D

var grid=[]
var soilColor=[]
var gridSize=128 # number of case
var gridWidth=64 # width of each case
var startingTiles=14
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
	},
	"envy":
	{
		"index":1,
		"color":Color(1,0.5,0),
	},
	"lust":
	{
		"index":2,
		"color":Color(1,0,1),
	},
	"sloth":
	{
		"index":3,
		"color":Color(0.5,0.5,0.5),
	},
	"greed":
	{
		"index":4,
		"color":Color(1,1,0),
	},
	"gluttony":
	{
		"index":5,
		"color":Color(0,1,0),
	},
	"pride":
	{
		"index":6,
		"color":Color(0,0.5,1),
	}
}

func getSin(x):
	return sins[sinsIndex[x]]

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
	print("x is "+str(x))
	print("soil is "+str(soilColor[x]))
	newSoil.modulate=getSin(soilColor[x])["color"]
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
	plantSpawnTimer+=delta
	if plantSpawnTimer>plantSpawnCurrent:
		spawnPlantRandom()
		plantSpawnTimer-=plantSpawnCurrent
		plantSpawnCurrent+=plantSpawnIncrement
