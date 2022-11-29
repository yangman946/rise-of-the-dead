extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


var vsync = true

var fullscreen = false

var music_volume = 100.0
var fx_volume = 100.0


var config = ConfigFile.new()
var prefs = config.load("user://prefs.cfg")

# Called when the node enters the scene tree for the first time.
func _ready():
	if prefs != OK:
		print("error")
		apply()
		return
	
	vsync = config.get_value("user", "vsync")
	fullscreen = config.get_value("user", "fullscreen")
	music_volume = config.get_value("user", "mv")
	fx_volume = config.get_value("user", "fxv")
	apply()
	pass # Replace with function body.

func save():
	config.set_value("user", "vsync", vsync)
	config.set_value("user", "fullscreen", fullscreen)
	config.set_value("user", "mv", music_volume)
	config.set_value("user", "fxv", fx_volume)
	
	config.save("user://prefs.cfg")
	pass
	
func apply():
	if vsync:
		OS.set_use_vsync(true)
	else:
		OS.set_use_vsync(false)
		
	MusicPlayer.updateMusic(music_volume)
	MusicPlayer.updateSfx(fx_volume)
	
	if fullscreen:
		OS.window_fullscreen = true
	else:
		OS.window_fullscreen = false
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
