extends Camera2D

onready var player = get_node("../Rat")

func _ready():
	pass

func _process(delta):
	position = player.position
