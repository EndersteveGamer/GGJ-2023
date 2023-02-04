extends KinematicBody2D

var deltaSpeed=Vector2.ZERO
export var speed=1000
export var deceleration=0.33
var facing=false # false is facing right
onready var sprite=get_node("Sprite")
onready var grabbed=get_node("Grab").get_node("Grabbed")
onready var audioManager=owner.get_node("AudioManager")

var touched=null #the plant the rat touches right now
var second=null #the second plant it touches
var uproot=null #the plant the rat picked, if null the rat is empty handed
var uprooting=0
export var timeToUproot=0.5

var plantGray=preload("res://Sprite/Plantier plant of the 80s.png")
var fruitSprte=preload("res://Sprite/Other Fruit of the 80s.png")

var index=0

func _ready():
	pass

func plantGetSin(x):
	return owner.plantGetSin(x)

func plantGetSinName(p):
	return p.plantGetSinName()

func plantGetCloser(grown=false):
	if touched!=null and touched.grown==grown:
		if second==null:
			return touched
		if second.grown==grown:
			if touched.position.distance_to(position)<second.position.distance_to(position):
				return touched
			return second
		return touched
	return null

# The closest plant will be grabed
# Skipped if the rat already have a plant
func grab():
	if uproot==null:
		uproot=plantGetCloser()
		if uproot!=null:
			uprooting=0.001
			grabbed.texture=plantGray
			grabbed.modulate=plantGetSin(uproot.index)["color"]
			uproot.owner.remove_child(uproot)
			add_child(uproot)
			uproot.visible=false
			owner.gridTake(uproot.index)
			uproot.soil=false
			if touched==uproot:
				touched=second
			else:
				second=null
		else:
			uproot=plantGetCloser(true)
			if uproot!=null:
				grabbed.texture=fruitSprte
				grabbed.modulate=owner.getSin(uproot.color)["color"]
				uproot.owner.remove_child(uproot)
				add_child(uproot)
				uproot.visible=false
				owner.gridTake(uproot.index)
				if touched==uproot:
					touched=second
				else:
					second=null

func plant():
	if uproot!=null:
		if uproot.grown:
			if index==owner.start or index==owner.start+owner.tiles-1:
				uproot.queue_free()
				owner.tiles+=1
				if index==owner.start:
					owner.start-=1
					owner.soilColor[owner.start]=uproot.color
					owner.createSoil(owner.start)
				else:
					owner.soilColor[owner.start+owner.tiles-1]=uproot.color
					owner.createSoil(owner.start+owner.tiles-1)
				if owner.sinsIndex[uproot.color]=="greed":
					for i in range(owner.start,owner.start+owner.tiles-1):
						if owner.soilColor[i]!=uproot.color:
							if owner.grid[i]!=null:
								owner.grid[i].growth+2
				uproot=null
				grabbed.texture=null
				owner.plantSpawnCurrent-=owner.plantSpawnDecrement
				if touched==uproot:
					touched=second
				second=null
				return
		if index>=owner.start and index<=owner.start+owner.tiles:
			if not owner.gridHas(index):
				uproot.visible=true
				remove_child(uproot)
				owner.add_child(uproot)
				uproot.set_owner(owner)
				owner.gridSet(index,uproot)
				owner.gridStick(uproot)
				grabbed.texture=null
				if plantGetSinName(uproot)=="gluttony":
					if not uproot.grown:
						var steal=1
						var previous=owner.grid[uproot.index-1]
						var next=owner.grid[uproot.index+1]
						if previous!=null and next!=null:
							if uproot.growth+steal>uproot.timeToGrow:
								steal=uproot.timeToGrow-uproot.growth
							var sum=previous.growth+next.growth
							if sum>steal:
								steal=sum
							uproot.growth+=steal
							previous.growth-=steal/2
							if previous.growth<0:
								steal-=previous.growth
								previous.growth=0
							next.growth-=steal
						else:
							if previous==null:
								previous=next
							if previous!=null:
								previous.growth-=steal
								if previous.growth<0:
									steal=-previous.growth
									previous.growth=0
								uproot.growth+=steal
				if owner.soilColor[uproot.index]==uproot.color:
					uproot.soil=true
				uproot=null
				if touched==uproot:
					touched=second
				second=null

func playerMovement(delta):
	var directionInput = Vector2.ZERO
	directionInput.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	deltaSpeed.x = (deltaSpeed.x + directionInput.x * speed) * deceleration
	if Input.get_action_strength("ui_right") > 0:
		facing=true
	elif Input.get_action_strength("ui_left") > 0:
		facing=false
	sprite.flip_h = !facing
	if Input.get_action_strength("ui_up"):
		grab()
	elif Input.get_action_strength("ui_down"):
		plant()

	# Move plant based on orientation
	if facing:
		grabbed.position.x = 32
		grabbed.flip_h = true
	else:
		grabbed.position.x = -32
		grabbed.flip_h = false

	# Move Rat
	index=owner.pointToGrid(position.x+32)
	move_and_slide(deltaSpeed) # auto delta !

func touchCheck():
	if touched==null and second!=null:
		touched=second
		second=null
	else:
		second=null

func playerUproot(delta):
	uprooting+=delta
	deltaSpeed.x*=deceleration
	if uprooting>timeToUproot:
		uprooting=0
	move_and_slide(deltaSpeed)

func _physics_process(delta):
	if uproot.dead:
		remove_child(uproot)
		uproot.queue_free()
		grabbed.texture=null
		uproot=null
	if uprooting>0:
		playerUproot(delta)
	else:
		playerMovement(delta)
	var terrainMin=owner.start*owner.gridWidth
	var terrainMax=(owner.start+owner.tiles-1)*owner.gridWidth
	if position.x<terrainMin:
		position.x=terrainMin
	if position.x>terrainMax:
		position.x=terrainMax

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Grab_area_entered(area):
	if area.visible:
		if touched==null:
			touched=area
		else:
			if second==null and area!=touched:
				second=area
		print(area.name)

func _on_Grab_area_exited(area):
	if area.visible:
		if area.soil:
			print("noice")
		if area==touched:
			touched=second
			second=null
			return
		if area==second:
			second=null
