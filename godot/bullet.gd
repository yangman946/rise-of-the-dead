extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var velocity;
export (int) var team;
var speed = 500 
onready var damage;
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func init(teamn, dmg):
	team = teamn
	damage = dmg
	
	if team == 0:
		velocity = Vector2(1,0).rotated(deg2rad(rng.randf_range(-10.0, 10.0)))
	elif team == 1:
		velocity = Vector2(-1,0).rotated(deg2rad(rng.randf_range(-10.0, 10.0)))
	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var collision_info = move_and_collide(velocity.normalized() * delta * speed)
	
	if collision_info != null:
		if (collision_info.collider.is_in_group("zombie") && team == 0) or (collision_info.collider.is_in_group("soldier") && team == 1):
			collision_info.collider.damage(damage)
			
		elif (collision_info.collider.is_in_group("zombie") && team == 1) or (collision_info.collider.is_in_group("soldier") && team == 0):
			collision_info.collider.damage(damage)
			return

		queue_free()
	
