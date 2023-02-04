extends Node2D

var timeTaken : float = 0
var isGameEnded : bool = false
var timeBeforeEnding : float = 10

func _ready():
	pass

func _process(delta):
	if isGameEnded:
		$Label.text = "Time taken: " + str(round(timeTaken))
		$Label.update()
		timeBeforeEnding -= delta
		if timeBeforeEnding <= 0:
			get_tree().change_scene("res://Scene/Main Menu.tscn")
			timeBeforeEnding = 10
			isGameEnded = false
			timeTaken = 0
