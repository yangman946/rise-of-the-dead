extends KinematicBody2D

var dead = false
var health = 0
var isHq = true
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func damage(dmg):
	get_tree().get_root().get_node("map").damage(dmg)
	pass

func reheal(dmg):
	pass
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
