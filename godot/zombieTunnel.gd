extends Area2D


# Declare member variables here. Examples:
# var a = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_zombieTunnel_body_entered(body):
	#print("collision")
	if body.is_in_group("soldier"):
		print("collided")
		#get_tree().get_root().get_node("map").addBalance(body.reward)
		#maybe add some animation
		#body.queue_free()
		body.stop()
