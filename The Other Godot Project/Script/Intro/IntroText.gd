extends Label

export(float, 0, 10, 0.1) var displayTime : float = 1

var texts : Array = ["Why are you even playing this",
			"This was made in 48 hours",
			"Screaming goat"]
var selectedText : String = ""

func _ready():
	randomize()
	text = texts[randi() % texts.size()]
	$Timer.connect("timeout", self, "switch_scene")
	$Timer.start(displayTime)
	pass

func _process(delta):
	pass

func switch_scene():
	get_tree().change_scene("res://Scene/Main Menu.tscn")
