extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var mv = 0
var sv = 0

onready var stext = get_node("ColorRect/VBoxContainer/HBoxContainer/sfxv")
onready var mtext = get_node("ColorRect/VBoxContainer/HBoxContainer2/musicv")

# Called when the node enters the scene tree for the first time.
func _ready():
	reload()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func reload():
	mv = GlobalSettings.music_volume
	sv = GlobalSettings.fx_volume
	
	get_node("ColorRect/VBoxContainer/HBoxContainer3/fullscreen").pressed = OS.window_fullscreen
	get_node("ColorRect/VBoxContainer/HBoxContainer4/CheckBox").pressed = GlobalSettings.vsync
	
	stext.text = str(sv)
	mtext.text = str(mv)
	
	get_node("ColorRect/VBoxContainer/HBoxContainer/sslider").value = sv
	get_node("ColorRect/VBoxContainer/HBoxContainer2/mslider").value = mv

func _on_back_pressed():
	GlobalSettings.save()
	MusicPlayer.playaudio("res://audio/click (1).wav")
	self.visible = false
	pass # Replace with function body.



func _on_mslider_value_changed(value):
	
	mv = value
	mtext.text = str(mv)
	GlobalSettings.music_volume = mv
	MusicPlayer.updateMusic(mv)
	pass # Replace with function body.


func _on_sslider_value_changed(value):
	sv = value
	stext.text = str(sv)
	GlobalSettings.fx_volume = sv
		
	MusicPlayer.updateSfx(sv)
	pass # Replace with function body.


func _on_sslider_mouse_exited():
	self.release_focus()
	pass # Replace with function body.


func _on_mslider_mouse_exited():
	self.release_focus()
	pass # Replace with function body.




func _on_CheckBox_pressed():
	if GlobalSettings.vsync:
		GlobalSettings.vsync = false
		OS.set_use_vsync(false)
	else:
		GlobalSettings.vsync = true
		OS.set_use_vsync(true)
		
	get_node("ColorRect/VBoxContainer/HBoxContainer4/CheckBox").pressed = GlobalSettings.vsync


func _on_fullscreen_pressed():
	if GlobalSettings.fullscreen:
		GlobalSettings.fullscreen = false
		OS.window_fullscreen = false
		
	else:
		GlobalSettings.fullscreen = true
		OS.window_fullscreen = true
	get_node("ColorRect/VBoxContainer/HBoxContainer3/fullscreen").pressed = OS.window_fullscreen
