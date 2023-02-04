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
var audioManager
# time in seconds
export var timeToGrow=30
export var timeToDecay=5
export var timeToCry=2
export var timeToDie=5

var soundCry=preload("res://Sound/Scream.ogg")

func _process(delta):
	if not dead:
		if not grown:
			if soil:
				growth+=delta
				if growth>=timeToGrow:
					grown=true
			if index==-1:
				print("out of earth")
				if not crying:
					cry+=delta
					if cry>timeToCry:
						crying=true
						audioManager.play(soundCry,position)
				else:
					if not dying:
						death+=delta
						if death>=timeToDie:
							dying=true
					else:
						decay+=delta
						if decay>=timeToDecay:
							dead=true
			else:
				cry=0
				crying=false
				death=0
				dying=false
				growth-=decay
				if growth<0:
					growth=0
				decay=0

func _ready():
	pass # Replace with function body.
