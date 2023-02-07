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
var generator
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

var pleaseStopBeingRetarded=false

func plantGetSinName():
	return game.sinsIndex[color]

func plantGetSin():
	return game.sins[plantGetSinName()]

func _process(delta):
	if not dead:
		if not grown:
			if soil:
				if crying:
					print('crying 3 set to false')
					crying=false
				cry=0
				dying=false
				death=0
				decay=0
				assert(index!=-1)
				if pleaseStopBeingRetarded:
					print("retared 3 is now false")
				pleaseStopBeingRetarded=false
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
					sounder.stop()
					grown=true
					growth=timeToGrow
					fruit.texture=fruitSprite
					fruit.modulate=game.getSinColorCode(color)
					fruit.z_index = -1
				if plantGetSinName()=="lust":
					if index>game.start and index<game.start+game.tiles-1:
						if game.grid[index-1]==null:
							if game.grid[index+1]!=null:
								game.createPlant(index-1).color=game.grid[index+1].color
						else:
							if game.grid[index-1]!=null:
								game.createPlant(index+1).color=game.grid[index-1].color
				if plantGetSinName()=="sloth":
					growth+=delta/2
					if game.grid[index-1]!=null:
							growth-=delta/4
					if game.grid[index+1]!=null:
							growth-=delta/4
			if index==-1:
				assert(not soil)
				soil=false
				if not crying:
					cry+=delta
					if cry>timeToCry:
						cry=0
						print("crying "+str(crying))
						if not crying:
							if not pleaseStopBeingRetarded:
								if not sounder.is_playing():
									print("play "+str(index))
									sounder.play()
							pleaseStopBeingRetarded=true
							print("retared is now "+str(pleaseStopBeingRetarded))
						crying=true
						print("then crying "+str(crying))
				else:
					position.x=(game.rng.randi()%10)-5
					position.y=(game.rng.randi()%10)-5
					if not dying:
						death+=delta
						if death>=timeToDie:
							dying=true
							generator.emitting=true
							generator.position=Vector2(0,16)
							generator.modulate=plantGetSin()["color"]
							
					else:
						decay+=delta
						if decay>=timeToDecay:
							decay=timeToDecay
							dead=true
						sprite.modulate.a=1-(decay/timeToDecay)
						sounder.volume_db=-decay/timeToDecay*25
			else:
				sprite.modulate.a=1
				sounder.volume_db=0
				$AnimationPlayer.play("sleep")
				cry=0
				if sounder.playing:
					print("stop")
				sounder.stop()
				if crying:
					print("crying 2 set to false")
				crying=false
				if pleaseStopBeingRetarded:
					print("retared 2 is now false")
				pleaseStopBeingRetarded=false
				death=0
				dying=false
				growth-=decay*2
				if growth<0:
					growth=0
				decay=0
		else:
			if sounder.is_playing():
				print("stop 2")
				sounder.stop()

func _ready():
	pass # Replace with function body.
