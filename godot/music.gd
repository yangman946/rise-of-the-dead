extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var menumusic = load("res://music/rise of the dead.wav")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func play_music():
	$music.stream = menumusic
	$music.play()
	pass
	
func playaudio(sound):
	var chn = [$channel1, $channel2, $channel3]
	var i = 0
	
	for item in chn:
		if !item.is_playing():
			item.stream = load(sound)
			item.play()
			break
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func updateMusic(volume):
	$music.volume_db = lineartodb(volume)
	#pass
	
func updateSfx(volume):
	var chn = [$channel1, $channel2, $channel3]
	var v = lineartodb(volume)
	for item in chn:
		item.volume_db = v
	
	
func lineartodb(volume):
	return linear2db(float(volume)/100)

	
