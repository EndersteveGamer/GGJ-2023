extends Area2D

var index=-1 # if not on the terrain, set to -1
var color=0
var growth=0
var grown=false
var soil=false
var cry=0
var crying=false
var death=0
var dying=false
var decay=0
var dead=false
onready var sounder=$Sounder
# time in seconds
export var timeToGrow=30
export var timeToDecay=5
export var timeToCry=2
export var timeToDie=5

var soundCry=preload("res://Sound/Scream.ogg")
var fruitSprite=preload("res://Sprite/Other Fruit of the 80s.png")
onready var sprite=get_node("Sprite")
onready var fruit=get_node("Fruit")
onready var game=owner

func plantGetSinName():
	return game.sinsIndex[color]

func plantGetSin():
	return game.sins[plantGetSinName()]

func _process(delta):
	if not dead:
		if not grown:
			if soil:
				var plant1 = game.grid[index - 1]
				var plant2 = game.grid[index + 1]
				if (plant1 != null && plant1.plantGetSinName() == "wrath") || (plant2 != null && plant2.plantGetSinName() == "wrath"):
					growth += delta / 2
				else:
					growth+=delta
				if game.grid[index].plantGetSinName() == "pride":
					if (plant1 != null && plant1.growth < growth) || (plant2 != null && plant2.growth < growth):
						growth += delta
				if game.grid[index].plantGetSinName() == "envy":
					if (plant1 != null && plant1.growth > growth) || (plant2 != null && plant2.growth > growth):
						growth += delta
				if growth>=timeToGrow:
					grown=true
					growth=timeToGrow
					fruit.texture=fruitSprite
					fruit.modulate=game.getSinColorCode(color)
					fruit.z_index = -1
				if plantGetSinName()=="lust":
					if game.grid[index-1]==null:
						if game.grid[index+1]!=null:
							game.createPlant(index-1).color=game.grid[index+1].color
					else:
						if game.grid[index-1]!=null:
							game.createPlant(index+1).color=game.grid[index-1].color
				if plantGetSinName()=="sloth":
					growth+=delta/2
					if game.grid[index-1]!=null :
							growth-=delta/4
					if game.grid[index+1]!=null :
							growth-=delta/4
			if index==-1:
				if not crying:
					cry+=delta
					if cry>timeToCry:
						crying=true
						print(sounder.stream)
						sounder.play()
				else:
					position.x=(game.rng.randi()%10)-5
					position.y=(game.rng.randi()%10)-5
					if not dying:
						death+=delta
						if death>=timeToDie:
							dying=true
					else:
						decay+=delta
						if decay>=timeToDecay:
							dead=true
			else:
				$AnimationPlayer.play("sleep")
				cry=0
				sounder.stop()
				crying=false
				death=0
				dying=false
				growth-=decay
				if growth<0:
					growth=0
				decay=0

func _ready():
	pass # Replace with function body.
