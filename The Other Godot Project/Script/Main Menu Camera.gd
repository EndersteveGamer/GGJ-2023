extends Camera2D

export(bool) var fullscreen = false
onready var GlobalVars = get_node("/root/GlobalVars")

func _ready():
	pass

func _process(delta):
	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = !fullscreen
		fullscreen = !fullscreen
	if Input.is_action_just_pressed("exit"):
		if GlobalVars.isEndScreen:
			get_tree().change_scene("res://Scene/Main Menu.tscn")
			GlobalVars.isEndScreen = false
		else:
			get_tree().quit()
	pass
	
