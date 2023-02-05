extends Node2D

var timeTaken : int = 0
var timeBeforeEnding : float = 10
onready var GlobalVars = get_node("/root/GlobalVars")
var minutes : int = 0
var seconds : int = 0

func _ready():
	timeTaken = GlobalVars.timeTaken
	minutes = timeTaken / 60
	seconds = timeTaken - 60 * minutes

func _process(delta):
	$TimeDisplay.text = "Time taken:\n" + str(minutes) + "m " + str(seconds) + "s"
	timeBeforeEnding -= delta
	if timeBeforeEnding <= 0:
		timeBeforeEnding = 10
		timeTaken = 0
		GlobalVars.isEndScreen = false
		get_tree().change_scene("res://Scene/Main Menu.tscn")
