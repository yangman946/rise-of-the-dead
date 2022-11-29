extends KinematicBody2D

var pos;
var damage = 0
var Arange = 0

var detonated = false

onready var area = get_node("Area2D")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const explosion = preload("res://explosion.tscn")

onready var anim = get_node("AnimationPlayer")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(p, d, r):
	self.pos = Vector2(p, 0)
	self.damage = d
	self.Arange = r
	self.global_position = self.pos
	
	pass
	
func detonate():
	var ex = explosion.instance()
	ex.position = global_position
	ex.init(Arange, damage, 0)
	
	get_parent().add_child(ex)

	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if detonated == false:
		for body in area.get_overlapping_bodies():
			if body.is_in_group("zombie"):
				detonated = true
				detonate()
