extends KinematicBody2D

var deltaSpeed=Vector2.ZERO
export var speed=1000
export var deceleration=0.33
var facing=false # false is facing right
onready var sprite=get_node("Sprite")
onready var grabbed=get_node("Grab").get_node("Grabbed")

var touched=null #the plant the rat touches right now
var second=null #the second plant it touches
var uproot=null #the plant the rat picked, if null the rat is empty handed

func _ready():
	pass

func plantGetCloser():
	if touched!=null:
		if second==null:
			return touched
		if touched.position.distance_to(position)<second.position.distance_to(position):
			return touched
		return second
	return null

# The closest plant will be grabed
# Skipped if the rat already have a plant
func grab():
	if uproot==null:
		uproot=plantGetCloser()
		if touched==uproot:
			touched=second
		else:
			second=null
		if uproot!=null:
			grabbed.texture=uproot.get_node("Sprite").texture
			print("grabed from "+uproot.owner.name)
			uproot.owner.remove_child(uproot)

func plant():
	if uproot!=null:
		owner.add_child(uproot)
		uproot.set_owner(owner)
		print("planted to "+owner.name)
		uproot.position=position
		uproot.position.y+=32
		uproot=null
		grabbed.texture=null

func playerMovement(delta):
	var directionInput=Vector2.ZERO
	directionInput.x= Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	deltaSpeed.x=(deltaSpeed.x+directionInput.x*speed)*deceleration
	if deltaSpeed.x>0.1:
		facing=true
	else:
		if deltaSpeed.x<0.1:
			facing=false
	sprite.flip_h=!facing
	if Input.get_action_strength("ui_up"):
		grab()
	else:
		if Input.get_action_strength("ui_down"):
			plant()
			
	# Move plant based on orientation
	if facing:
		grabbed.position.x = 41
		grabbed.flip_h = true
	else:
		grabbed.position.x = -41
		grabbed.flip_h = false
	move_and_slide(deltaSpeed) # auto delta !
 
func touchCheck():
	if touched==null and second!=null:
		touched=second
		second=null

func _physics_process(delta):
	playerMovement(delta)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Grab_area_entered(area):
	if touched==null:
		touched=area
	else:
		if second==null and area!=touched:
			second=area
	print(area.name)

func _on_Grab_area_exited(area):
	if area==touched:
		touched=second
		second=null
		return
	if area==second:
		second=null
