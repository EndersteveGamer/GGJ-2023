extends Camera2D

export(bool) var fullscreen = false

func _ready():
	pass

func _process(delta):
	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = !fullscreen
		fullscreen = !fullscreen
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	pass
	
