extends RigidBody2D

onready var time = get_node("Timer")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var team;
var damage;
var force;
var multiplier = 500
var detonated = false

const explosion = preload("res://explosion.tscn")

func init(teamn, dmg):
	team = teamn
	damage = dmg
	
	if team == 0:
		force = Vector2(1,0)
	elif team == 1:
		force = Vector2(-1,0)
		
# Called when the node enters the scene tree for the first time.
func _ready():
	time.connect("timeout", self, "_on_Timer_timeout")
	time.start(3)
	apply_central_impulse(force * multiplier)
	pass # Replace with function body.

func detonate(): #zombies only
	
	var ex = explosion.instance()
	ex.position = global_position
	ex.init(100, damage, team)
	
	get_parent().add_child(ex)
	
	detonated = true
	queue_free()
	pass

func _on_Timer_timeout():
	if detonated == false:
		detonate()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
