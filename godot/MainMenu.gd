extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var credits = get_node("credits")
onready var confirm = get_node("confirm")

onready var options = get_node("options")


# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/startbtn.grab_focus()
	credits.visible = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func playaudio(sound):
	MusicPlayer.playaudio(sound)

func _on_startbtn_pressed():
	playaudio("res://audio/click (1).wav")
	#get_tree().change_scene("res://map.tscn")
	SceneTransition.change_scene("res://map.tscn")
	pass # Replace with function body.
	

func confirmed():
	
	get_tree().quit()
	pass
	
func cancel():
	
	confirm.visible = false
	pass

func _on_quitbtn_pressed():
	playaudio("res://audio/click (1).wav")
	confirm.visible = true
	pass # Replace with function body.


func _on_Credits_pressed():
	playaudio("res://audio/click (1).wav")
	credits.visible = true
	pass # Replace with function body.


func _on_back_pressed():
	playaudio("res://audio/click (1).wav")
	credits.visible = false
	pass # Replace with function body.


func _on_optionsbtn_pressed():
	playaudio("res://audio/click (1).wav")
	options.reload()
	options.visible = true
	pass # Replace with function body.
