extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var rangeExplosion = get_node("range")
onready var anim = get_node("AnimationPlayer")

var damage = 0;
var team = 0;
var exploding = false
var enemiesExploded = []

# Called when the node enters the scene tree for the first time.
func _ready():
	explode()
	pass # Replace with function body.

func init(size, dmg, t):
	get_node("range/CollisionShape2D").shape.radius = size * 2
	if size > 10000:
		size = 200
		dmg = 20000
		
	
	self.damage = dmg
	self.team = t
	var scale = size/100
	get_node("Sprite").scale.x = scale
	get_node("Sprite").scale.y = scale
	pass
	
	
func explode():
	MusicPlayer.playaudio("res://audio/explosion (1).wav")
	exploding = true
	anim.play("explode")
	# play sound?

	
	pass


func getEnemies():
	var enemy = [];
	if team == 0:
		#enemy = get_tree().get_nodes_in_group("zombie")
		#enemy = Arange.get_overlapping_bodies()
		for body in rangeExplosion.get_overlapping_bodies():
			if body.is_in_group("zombie"):
				enemy.append(body)
		
	elif team == 1:
		#enemy = get_tree().get_nodes_in_group("soldier")
		#enemy = Arange.get_overlapping_bodies()
		for body in rangeExplosion.get_overlapping_bodies():
			if body.is_in_group("soldier"):
				enemy.append(body)
		#enemy.append(soldierSpawn)
		
		#enemy.append(HQ)
		
	return enemy
	
func damageZ():
	var e = getEnemies()
	for enemy in e:
		#print("exploded")
		if enemiesExploded.has(enemy) == false:
			enemy.damage(damage)
			enemiesExploded.append(enemy)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if exploding:
		#exploding = false
		damageZ()
		#yield(get_tree().create_timer(0.5), "timeout")
		
		


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "explode":
		queue_free()
	pass # Replace with function body.
