extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var team = get(team)

var attacking = false

func _on_Area2D_body_enter(body):
	
	if team == 0: 
		if "zombie" in body.get_name():
			pass
	else:
		if "soldier" in body.get_name():
			pass
	
	
func _on_Area2D_body_exit(body):
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func settarget(target):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if attacking == false:
		for body in get_overlapping_bodies():
			if (body.is_in_group("zombie") and team == 0) or (body.is_in_group("soldier") and team == 1):
				settarget(body)
