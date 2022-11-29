extends RigidBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var pos;
var damage = 0
var Arange = 0

onready var timer = get_node("Timer")
var detonated = false

const explosion = preload("res://explosion.tscn")

var played = false
var start = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.connect("timeout", self, "_on_Timer_timeout")
	timer.start(5)
	start = OS.get_unix_time()
	playaudio("res://audio/plane.wav")
	pass # Replace with function body.



func detonate(): 
	
	var ex = explosion.instance()
	ex.position = global_position
	ex.init(Arange, damage, 0)
	
	get_parent().add_child(ex)
	
	detonated = true
	queue_free()
	pass

func _on_Timer_timeout():
	timer.stop()
	if detonated == false:
		detonate()

func init(p, d, r):
	self.pos = Vector2(p, -1000)
	self.damage = d
	self.Arange = r
	self.global_position = self.pos
	pass
	
	
func playaudio(sound):
	MusicPlayer.playaudio(sound)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if OS.get_unix_time() - start >= 3:
		if played == false:
			played = true
			playaudio("res://audio/drop.wav")
