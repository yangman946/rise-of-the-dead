extends Control

# manages button presses etc. 
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var confirm = get_node("confirm")
onready var options = get_node("options")
onready var anim = get_node("AnimationPlayer")

var mode = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func newwave():
	anim.play("newWave")

func playaudio(sound):
	MusicPlayer.playaudio(sound)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):

func replay():
	pass

#	pass
func quit():
	get_tree().quit()

func confirmed():
	if mode == 0:
		quit()
	elif mode == 1:
		print("going to menu")
		get_tree().get_root().get_node("map").pause()
		Engine.time_scale = 1
		SceneTransition.change_scene("res://MainMenu.tscn")
	pass
	
func cancel():
	confirm.visible = false
	pass

func _on_Button4_pressed(): # resume
	print("presed")
	playaudio("res://audio/click (1).wav")
	get_tree().get_root().get_node("map").pause()
	pass # Replace with function body.


func _on_Button3_pressed():
	mode = 0
	playaudio("res://audio/click (1).wav")
	confirm.visible = true
	pass # Replace with function body.


func _on_Button2_pressed():
	mode = 1
	playaudio("res://audio/click (1).wav")
	confirm.visible = true
	pass # Replace with function body.


func _on_Button_pressed():
	mode = 1
	playaudio("res://audio/click (1).wav")
	confirm.visible = true
	pass # Replace with function body.


func _on_retry_pressed():
	playaudio("res://audio/click (1).wav")
	Engine.time_scale = 1
	SceneTransition.reload()
	pass # Replace with function body.


func _on_options_pressed():
	playaudio("res://audio/click (1).wav")
	options.reload()
	options.visible = true
	pass # Replace with function body.
