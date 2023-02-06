extends Node2D

var num_players = 32
var bus = "master"

var available = []  # The available players.
var queue = []  # The queue of sounds to play.
var positionQueue=[] # where the sound is played

func _ready():
	# Create the pool of AudioStreamPlayer nodes.
	for i in num_players:
		var p = AudioStreamPlayer2D.new()
		add_child(p)
		p.connect("finished", self, "_on_stream_finished", [p])
		p.bus = bus
		available.append(p)

func _on_stream_finished(stream):
	# When finished playing a stream, make the player available again.
	available.append(stream)

func play(sound,where=Vector2(0,0)):
	queue.append(sound)
	positionQueue.append(where)

func _process(delta):
	# Play a queued sound if any players are available.
	if not queue.empty() and not available.empty():
		available[0].stream = queue.pop_front()
		available[0].position=positionQueue.pop_front()
		#print("played at "+str(available[0].position))
		available[0].play()
		available.pop_front()
