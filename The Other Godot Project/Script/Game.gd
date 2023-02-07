extends Node2D

var grid=[]
var soilColor=[]
var soilNode=[]
var gridSize=128 # number of case
var gridWidth=64 # width of each case
var startingTiles : int =14
var victory : int=startingTiles+30
var tiles=startingTiles
var start=(gridSize-startingTiles)/2
onready var plant=preload("res://Scene/Plant.tscn")
onready var soil=preload("res://Scene/Soil.tscn")

export var plantedHeight=48

var sloth=preload("res://Sprite/sloth.png")
var greed=preload("res://Sprite/greed.png")
var pride=preload("res://Sprite/pride.png")
var gluttony=preload("res://Sprite/gluttony.png")
var envy=preload("res://Sprite/envy.png")
var wrath=preload("res://Sprite/wrath.png")
var lust=preload("res://Sprite/lust.png")

var wrathSound=preload("res://Sound/wrath.ogg")
var greedSound=preload("res://Sound/greed.ogg")
var prideSound=preload("res://Sound/pride.ogg")
var gluttonySound=preload("res://Sound/gluttony.ogg")
var envySound=preload("res://Sound/envy.ogg")
var slothSound=preload("res://Sound/sloth.ogg")
var lustSound=preload("res://Sound/lust.ogg")

var music=[preload("res://Sound/level 1.ogg"),preload("res://Sound/level 2.ogg"),preload("res://Sound/level 3.ogg")]

onready var progressDisplay = $CanvasLayer/TextureProgress
onready var musicer=$Musicer
onready var sounder=$Sounder
var plantSpawnSound=preload("res://Sound/plantSpawn.ogg")
onready var rng=RandomNumberGenerator.new()

export var plantSpawndBase=6
var plantSpawnCurrent=plantSpawndBase
export(float) var plantSpawnIncrement=1
export(float) var plantSpawnDecrement=2
export var plantSpawnTimer=0


var timeTaken = 0

var timeLeftToShake : float = 0
var shakeStrength : float = 0

onready var dirtBury = $DirtBury
onready var unlockParticles = $UnlockParticles
onready var plantDecay = $PlantDecay

func getDirtBury():
	return dirtBury
	
func getUnlockParticles():
	return unlockParticles
	
func shakeCamera(time : float, strength : float):
	timeLeftToShake = time
	shakeStrength = strength

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
		"desc":"Reduces nearby progression, but have a progression addition when a new plant appears next by",
		"texture":wrath,
		"sound":wrathSound
	},
	"envy":
	{
		"index":1,
		"color":Color(1,0.5,0),
		"desc":"Grow faster when nearby plants are further ahead",
		"texture":envy,
		"sound":envySound
	},
	"lust":
	{
		"index":2,
		"color":Color(1,0,1),
		"desc":"When grown, will clone the nearby plant to the other side if there's space",
		"texture":lust,
		"sound":lustSound
	},
	"sloth":
	{
		"index":3,
		"color":Color(0.5,0.5,0.5),
		"desc":"Grows faster if there's no plants to the sides",
		"texture":sloth,
		"sound":slothSound
	},
	"greed":
	{
		"index":4,
		"color":Color(1,1,0),
		"desc":"When used to grow the road, will add a bit progression to all but greed plants",
		"texture":greed,
		"sound":greedSound
	},
	"gluttony":
	{
		"index":5,
		"color":Color(0,1,0),
		"desc":"Steals part of nearby progression when placed",
		"texture":gluttony,
		"sound":gluttonySound
	},
	"pride":
	{
		"index":6,
		"color":Color(0,0.5,1),
		"desc":"Grows faster if it's ahead of the other plants",
		"texture":pride,
		"sound":prideSound
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
	what.position.y=plantedHeight

func stickToGrid(x):
	gridStickFromIndex(gridGet(x))

func gridGet(x):
	return grid[x]

func gridHas(x):
	return gridGet(x)!=null

func gridSet(x,what):
	if not gridHas(x):
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
	if plant!=null:
		var newPlant=plant.instance()
		add_child(newPlant)
		newPlant.owner=self
		newPlant.owner=self
		newPlant.game=self
		gridSet(x,newPlant)
		newPlant.position.y=plantedHeight
		newPlant.color=rng.randi()%7
		while newPlant.color==soilColor[x]:
			newPlant.color=rng.randi()%7
		newPlant.sprite.texture=sins[sinsIndex[newPlant.color]]["texture"]
		newPlant.sounder.stream=sins[sinsIndex[newPlant.color]]["sound"]
		newPlant.sounder.bus="master"
		newPlant.generator=plantDecay.duplicate()
		newPlant.add_child(newPlant.generator)
		newPlant.generator.emitting=false
		sounder.stream=plantSpawnSound
		sounder.play()
		return newPlant
	return null

func spawnPlantRandom():
	var x=rng.randi()%tiles+start
	var threshold=100
	var i=0
	while gridHas(x) and x!=get_node("Player").index:
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
	soilNode[x]=newSoil

# Called when the node enters the scene tree for the first time.
func _ready():
	musicer.stream=music[0]
	musicer.play()
	grid.resize(gridSize)
	soilColor.resize(gridSize)
	soilNode.resize(gridSize)
	rng.randomize()
	spawnPlantRandom()
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
	timeLeftToShake -= delta
	plantSpawnTimer+=delta
	if plantSpawnTimer>plantSpawnCurrent:
		if getPlantsNum() <= tiles / 2:
			spawnPlantRandom()
		plantSpawnTimer-=plantSpawnCurrent
		plantSpawnCurrent+=plantSpawnIncrement
		if plantSpawnCurrent < 3: plantSpawnCurrent = 3
	progressDisplay.value = tiles - 14
	if timeLeftToShake > 0:
		var value = rng.randf() * 360
		var xOffset = shakeStrength * cos(value)
		var yOffset = shakeStrength * sin(value)
		$Player/Camera2D.offset_h = xOffset
		$Player/Camera2D.offset_v = yOffset
	else:
		$Player/Camera2D.offset_h = 0
		$Player/Camera2D.offset_v = 0

func endGame():
	var GlobalVars = get_node("/root/GlobalVars")
	GlobalVars.timeTaken = timeTaken
	GlobalVars.isEndScreen = true
	get_tree().change_scene("res://Scene/End Screen.tscn")
