extends ColorRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
# parent scene will need 2 functions


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button3_pressed(): # yes
	get_parent().playaudio("res://audio/click (1).wav")
	get_parent().confirmed()
	
	pass # Replace with function body.
	



func _on_Button4_pressed(): # no
	get_parent().playaudio("res://audio/click (1).wav")
	get_parent().cancel()
	pass # Replace with function body.
