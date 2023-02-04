extends Node2D

var timeTaken : float = 0
var isGameEnded : bool = false
var timeBeforeEnding : float = 10
onready var label = get_node("/root/EndScreen/TimeDisplay")

func _ready():
	pass

func _process(delta):
	if isGameEnded:
		$TimeDisplay.text = "Time taken: " + str(round(timeTaken))
		print(label.text)
		timeBeforeEnding -= delta
		if timeBeforeEnding <= 0:
			get_tree().change_scene("res://Scene/Main Menu.tscn")
			timeBeforeEnding = 10
			isGameEnded = false
			timeTaken = 0
