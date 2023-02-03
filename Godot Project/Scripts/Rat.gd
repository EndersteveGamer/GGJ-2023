extends KinematicBody2D

var deltaSpeed : Vector2 = Vector2.ZERO
export var speed : float = 35
var xPos : float = 0
var yPos : float = 0
export var deceleration : float = 0.8
onready var sideSprite = get_node("Sprite")
onready var upSprite = get_node("UpSprite")
var lastOrientation : int = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
	
func move(delta):
# Handle movement
	var directionInput = Vector2.ZERO
	directionInput.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	directionInput.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	# Save last orientation
	# Right: 0
	# Down: 1
	# Left: 2
	# Up: 3
	if directionInput.x > 0:
		lastOrientation = 0
	elif directionInput.x < 0:
		lastOrientation = 2
	elif directionInput.y > 0:
		lastOrientation = 3
	elif directionInput.y < 0:
		lastOrientation = 1

	# Handle Texture
	if lastOrientation == 0 || lastOrientation == 2:
		sideSprite.visible = true
		upSprite.visible = false
		sideSprite.flip_v = false
		sideSprite.flip_h = lastOrientation == 2
	else:
		upSprite.visible = true
		sideSprite.visible = false
		upSprite.flip_h = false
		upSprite.flip_v = lastOrientation == 3

	# Handle desceleration
	deltaSpeed.x = (deltaSpeed.x + directionInput.x * speed) * deceleration
	deltaSpeed.y = (deltaSpeed.y + directionInput.y * speed) * deceleration
# warning-ignore:return_value_discarded
	move_and_slide(deltaSpeed)

func _physics_process(delta):
	move(delta)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
