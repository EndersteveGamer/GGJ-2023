extends KinematicBody2D

var deltaSpeed = Vector2.ZERO
var speed = 100
var xPos = 0
var yPos = 0
var deceleration = 0.33


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
	
func move(delta):
	var directionInput = Vector2.ZERO
	directionInput.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	deltaSpeed.x = (deltaSpeed.x + directionInput.x * speed) * deceleration
	move_and_slide(deltaSpeed)

func _physics_process(delta):
	move(delta)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
