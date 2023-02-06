extends KinematicBody2D

var deltaSpeed=Vector2.ZERO
export var speed=1000
export var deceleration=0.33
var facing=false # false is facing right
onready var sprite=get_node("Sprite")
onready var grabbed=get_node("Grab").get_node("Grabbed")
onready var audioManager=owner.get_node("AudioManager")
onready var animator=get_node("AnimationPlayer")

var touched=null #the plant the rat touches right now
var second=null #the second plant it touches
var uproot=null #the plant the rat picked, if null the rat is empty handed
var uprooting=0
export var timeToUproot=0.7
var planting=0
export var timeToPlant=0.5

var inHand=false

var fruitSprite=preload("res://Sprite/Other Fruit of the 80s.png")
var idle=preload("res://Sprite/idle.png")
var run=preload("res://Sprite/run.png")
var uprootAnimation=preload("res://Sprite/uproot.png")
var plantAnimation=preload("res://Sprite/plant.png")
var uprootSound=preload("res://Sound/uproot.ogg")
var plantSound=preload("res://Sound/plant.ogg")

var previousTouched=-1

onready var sounder=$Sounder
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
	
func selectedLoop():
	if uproot!=null:
		if previousTouched==-1:
			previousTouched=index
		if index!=previousTouched:
			if owner.gridGet(index)==null:
				owner.soilNode[previousTouched].modulate=owner.getSinColorCode(owner.soilColor[previousTouched])
				owner.soilNode[previousTouched].modulate.a=0.5
				owner.soilNode[index].modulate=Color(1.5,1.5,1.5,0.5)
			previousTouched=index
	else:
		if previousTouched!=-1:
			owner.soilNode[previousTouched].modulate=owner.getSinColorCode(owner.soilColor[previousTouched])
			owner.soilNode[previousTouched].modulate.a=0.5
			previousTouched=-1

# The closest plant will be grabed
# Skipped if the rat already have a plant
func grab():
	if uproot==null:
		uproot=plantGetCloser()
		if uproot!=null:
			grabbed.modulate=Color(1,1,1,1)
			grabbed.scale=Vector2(1,1)
			if uprooting==0:
				uprooting=0.001
				inHand=false
				if touched==uproot:
					touched=second
				else:
					second=null
		else:
			uproot=plantGetCloser(true)
			if uproot!=null:
				grabbed.texture=fruitSprite
				grabbed.modulate=owner.getSin(uproot.color)["color"]
				grabbed.scale=Vector2(2,2)
				uproot.game.remove_child(uproot)
				grabbed.add_child(uproot)
				inHand=false
				owner.gridTake(uproot.index)
				if touched==uproot:
					touched=second
				else:
					second=null

func plant():
	if uproot!=null:
		if uproot.grown:
			if index==owner.start or index==owner.start+owner.tiles-1:
				planting=0.01
				if touched==uproot:
					touched=second
				second=null
		else:
			if not owner.gridHas(index):
				planting=0.01
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
		sprite.texture=idle
		sprite.hframes=6
		animator.play("idle")
	else:
		sprite.texture=uprootAnimation
		sprite.hframes=6
		animator.play("uproot")
		if uprooting>0.5:
			if !inHand:
				owner.getDirtBury().position = uproot.position
				owner.getDirtBury().emitting = true
				owner.shakeCamera(0.25, 2)
				uproot.game.remove_child(uproot)
				grabbed.add_child(uproot)
				uproot.position.x=0
				uproot.position.y=0
				uproot.set_owner(grabbed)
				inHand=true
				owner.gridTake(uproot.index)
				uproot.soil=false
				uproot.get_node("AnimationPlayer").play("cry")
				sounder.stream=uprootSound
				sounder.play()
	move_and_slide(deltaSpeed)

func playerPlant(delta):
	planting+=delta
	deltaSpeed.x*=deceleration
	if planting>timeToPlant:
		# the plant is back in the ground
		inHand=false
		owner.shakeCamera(0.25, 2)
		if uproot==null:
			return
		grabbed.remove_child(uproot)
		uproot.get_node("AnimationPlayer").play("sleep")
		planting=0
		sprite.texture=idle
		sprite.hframes=6
		animator.play("idle")
		if uproot.grown:
				uproot.call_deferred("queue_free")
				owner.tiles+=1
				if index==owner.start:
					owner.start-=1
					owner.soilColor[owner.start]=uproot.color
					owner.createSoil(owner.start)
					owner.getUnlockParticles().position.x = owner.gridToPoint(owner.start)
				else:
					owner.soilColor[owner.start+owner.tiles-1]=uproot.color
					owner.createSoil(owner.start+owner.tiles-1)
					owner.getUnlockParticles().position.x = owner.gridToPoint(owner.start + owner.tiles - 1)
				owner.getUnlockParticles().position.y = 64
				owner.getUnlockParticles().color = owner.sins[owner.sinsIndex[uproot.color]]["color"]
				owner.getUnlockParticles().emitting = true
				if owner.sinsIndex[uproot.color]=="greed":
					for i in range(owner.start,owner.start+owner.tiles-1):
						if owner.soilColor[i]!=uproot.color:
							if owner.grid[i]!=null:
								owner.grid[i].growth+2
				uproot=null
				grabbed.texture=null
				owner.plantSpawnCurrent-=owner.plantSpawnDecrement
				var tiles=owner.tiles-owner.startingTiles
				var thirdVictory=(owner.victory-owner.startingTiles)/3
				if tiles>thirdVictory:
					if owner.musicer.stream==owner.music[0]:
						var from=owner.musicer.get_playback_position()
						owner.musicer.stream=owner.music[1]
						owner.musicer.play(from)
				if tiles>thirdVictory*2:
					if owner.musicer.stream==owner.music[1]:
						var from=owner.musicer.get_playback_position()
						owner.musicer.stream=owner.music[2]
						owner.musicer.play(from)
				if owner.tiles >= owner.victory:
					owner.endGame()
				return
		else:
			remove_child(uproot)
			owner.add_child(uproot)
			uproot.set_owner(owner)
			uproot.get_node("AnimationPlayer").play("sleep")
			owner.gridSet(index,uproot)
			owner.gridStick(uproot)
			grabbed.texture=null
			
			owner.getDirtBury().position = uproot.position
			owner.getDirtBury().emitting = true
			
			uproot.generator.emitting=false
			
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
			sounder.stream=plantSound
			sounder.play()
	else:
		sprite.texture=plantAnimation
		sprite.hframes=5
		animator.play("plant")

func _physics_process(delta):
	if uproot!=null:
		if uproot.dead:
			remove_child(uproot)
			
			uproot.queue_free()
			grabbed.texture=null
			uproot=null
	if uprooting>0:
		playerUproot(delta)
	else:
		if planting>0 and uproot!=null:
			playerPlant(delta)
		else:
			if abs(deltaSpeed.x)>0.1:
				sprite.texture=run
				sprite.hframes=9
				animator.play("run")
			else:
				sprite.texture=idle
				sprite.hframes=6
				animator.play("idle")
			playerMovement(delta)
	var terrainMin=owner.start*owner.gridWidth
	var terrainMax=(owner.start+owner.tiles-1)*owner.gridWidth
	if position.x<terrainMin:
		position.x=terrainMin
	if position.x>terrainMax:
		position.x=terrainMax
	selectedLoop()

func _on_Grab_area_entered(area):
	if area.visible:
		if touched==null:
			touched=area
		else:
			if second==null and area!=touched:
				second=area

func _on_Grab_area_exited(area):
	if area.visible:
		if area==touched:
			touched=second
			second=null
			return
		if area==second:
			second=null
