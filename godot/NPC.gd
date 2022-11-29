extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export (int) var team = 0 # 0 is humans, 1 is zombies
onready var Max_health;
onready var dps; # per second = single shot * shots per second
onready var speed;
onready var attackrange;
onready var attackrate; # second between shots
onready var reward; 
onready var isProjectile;
var isHq = false

signal clicked(node)

var detonated = false

const bullet = preload("res://bullet.tscn")
const grenade = preload("res://grenade.tscn")
const zbullet = preload("res://zombie_bullet.tscn")
onready var soldierSpawn = get_tree().get_root().get_node("map/soldier spawn")
const explosion = preload("res://explosion.tscn")



onready var label = self.get_node("Sprite/Label")

onready var Arange = self.get_node("Area2D")

onready var health = Max_health setget _set_health

signal health_updated(health)
signal death()
signal delay()
var lasttarget = [];

#var ismove = true

onready var dir;

#what the fuuu
var inits = false
var attacking = false
var target;
var dead = false
var dying = false
var destination;
var explode = false

var ismedic = false
var isreaper = false

var index = 0

var dmg = false
var attackThreashold = 0 # if it takes 10 shots to kill something its probably dead
onready var attacktimer: Timer = $Timer
onready var collider: CollisionShape2D = $CollisionShape2D
onready var _animation_player: AnimationPlayer = $AnimationPlayer
onready var shadow = get_node("shadow")

var rng = RandomNumberGenerator.new()

var stop = false

func init(ind, pos, texture, health, d, speed, a_range, a_rate, r, p, isExplode):
	self.Max_health = health
	self.health = health
	self.speed = speed
	self.dps = d
	self.attackrange = a_range
	self.attackrate = a_rate
	self.reward = r
	self.isProjectile = p
	self.destination = pos
	self.explode = isExplode # spawns an explosion
	self.index = ind
	
	# dont mess up the index!!!
	if team == 0 && index == 2:
		# medic
		self.ismedic = true
	
	if team == 1 && index == 5:
		self.isreaper = true	
	
	
	#var collision = CollisionShape2D.new()
	var circles = CircleShape2D.new()
	circles.set_radius(a_range)
	#collision.set_shape(circle)
	
	self.get_node("Area2D/CollisionShape2D").shape = circles
	
	
	var tex = get_node("Sprite")
	tex.texture = load(texture)
	


	

func playaudio(sound):
	MusicPlayer.playaudio(sound)
		
func reheal(amount):
	if team != 0:
		pass # zombies dont reheal
		
	if health >= Max_health:
		return
		
	if dmg == false:
		if dead:
			return
		_animation_player.playback_speed = 1
		_animation_player.play("reheal")
	
	
		yield(get_tree().create_timer(0.5), "timeout")
	
		_set_health(health + amount)

func damage(amount):
	_animation_player.playback_speed = 1
	if dead:
		return
	dmg = true
	#yield(get_tree().create_timer(0.5), "timeout")
	_animation_player.play("damage")
	
	
	yield(get_tree().create_timer(0.5), "timeout")
	
	_set_health(health - amount)
	
	#print("damage")
	
# Called when the node enters the scene tree for the first time.
func _ready():
	if team == 0:
		dir = 100
	else:
		dir = -100
	attacktimer.connect("timeout", self, "_on_Timer_timeout")

	attacktimer.stop()
	inits = true



func _set_health(value):
	if (inits == false):
		return
	var prev_health = health
	health = clamp(value, 0, Max_health)
	if health != prev_health:
		emit_signal("health_updated", health)
		if health == 0:
			dead = true
			collider.disabled = true
			shadow.visible = false
			kill()
			# play custom death sound
			playaudio("res://audio/death.wav")
		else:
			if health < prev_health:
				playaudio("res://audio/hitHurt.wav")
			
	yield(get_tree().create_timer(0.5), "timeout")
	dmg = false
	

	
func kill():
	if team == 1:
		get_tree().get_root().get_node("map").addBalance(reward)
		get_tree().get_root().get_node("map").zombies_killed += 1
		get_tree().get_root().get_node("map").removeItem()
		
		if (detonated == false && explode == true):
			if Chance(50.0):
				detonate()
			
		
	emit_signal("death")
	#_animation_player.stop()
	
func Chance(percent):
	
	var my_random_number = rng.randf_range(0.0, 100.0)
	if my_random_number < percent:
		return true
	else:
		return false
	
func shoot(dmgs):
	playaudio("res://audio/shoot.wav")
	var b;
	if team == 0:
		if explode:
			b = grenade.instance()
			
		else:
			b = bullet.instance()
	else:
		b = zbullet.instance()
	
	b.init(team, dmgs)
	get_parent().add_child(b)
	b.position = $bulletSpawn.global_position



	
func _on_Timer_timeout():
	attacktimer.stop()
	

func newDestination(pos):
	stop = false
	destination = pos

func move():
	if stop:
		get_node("Sprite").set_flip_h(false)
		return
		
	if team == 0:
		if abs(global_position.x - destination) < 5:
			get_node("Sprite").set_flip_h(false)
			stop = true
			
	lasttarget = []
	if dmg:
		pass # a stun function???
		#_animation_player.play("damage")
		#dmg = false
	else:
		_animation_player.playback_speed = speed
		_animation_player.play("walk")
		
	if team == 0:
		if global_position.x > destination:
			get_node("Sprite").set_flip_h(true)
			dir = -100
		else:
			get_node("Sprite").set_flip_h(false)
			dir = 100
		
	
	var new_position: Vector2
	
	new_position = Vector2(dir, 0) # change this to deployment position
	move_and_slide(new_position * speed, Vector2.UP)

func detonate(): #zombies only
	
	var ex = explosion.instance()
	ex.position = global_position
	ex.init(attackrange, dps, team)
	
	get_parent().add_child(ex)
	
	if detonated == false:
		damage(dps/attackrate)
	
	detonated = true
	pass
	
func attack():
	
	#ismove = false
	
	if dmg:
		_animation_player.playback_speed = speed
		pass # stun?
		#_animation_player.play("damage")
		#dmg = false
		
	if (explode && team == 1):
		detonate()
		return
		
	if (attackThreashold >= 10):
		attacking = false
		#ismove = true
		attacktimer.stop()
		_animation_player.playback_speed = speed
		return
		
	
	#target.damage()
	if (attacktimer.is_stopped()):
		attackThreashold += 1
		#_animation_player.stop()
		
		_animation_player.playback_speed = 2/attackrate
		
		
		#_animation_player.queue("reset")
		

		


		if is_instance_valid(target):
			if target.dead == true:
				on_die()
				return

			if isProjectile:
				shoot(dps/attackrate)
			else:
				#_animation_player.queue("reset")
				# play custom non shoot sound!!!
				playaudio("res://audio/melee.wav")
				target.damage(dps/attackrate)
		else:
			on_die()
			return
			
		attacktimer.start(attackrate)
		_animation_player.play("attack") # gotta reset this

		
		#print("play")
	else:
		_animation_player.playback_speed = speed
		
		


	
func on_die():
	if isreaper:
		get_tree().get_root().get_node("map").spawnZombie2(4, target.global_position)
		pass
	#yield(get_tree().create_timer(0.5), "timeout")
	lasttarget.append(target)
	attacking = false
	attackThreashold = 0
	#ismove = true
	#_animation_player.stop(true)
	attacktimer.stop()
	_animation_player.playback_speed = speed

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta) -> void:
	if (inits == false):
		return

	if dead:

		if !dying:
			_animation_player.playback_speed = 1
			dying = true
			#_animation_player.connect("finished", self, "done")
			#yield(get_tree().create_timer(1.0), "timeout")
			_animation_player.play("death")
			#_animation_player.queue("reset")
			yield(get_tree().create_timer(2.0), "timeout")
			queue_free()
			
		


		return
		

	
		
	label.text = str(int(health)) + "/" + str(int(Max_health))
		
	if attacking == false:
		
		
		var enemies = getEnemies()
		#var enemiesInrange = []
		
		for enemy in enemies:
			
			#if enemy.global_position.distance_to(global_position) < attackrange: # shitty code
			
			if lasttarget.has(enemy) == false:
				#enemiesInrange.append(enemy)
				attacking = true
				attackThreashold = 0
				enemy.connect("death", self, "on_die")
				target = enemy
				return
		
				
		if len(enemies) == 0:
			move()
			if ismedic:
				heal()
		
		
	else:
		
		attack()
		
func heal():
	var m = get_tree().get_root().get_node("map").lvlmultiplier
	for friend in getFriends():
		friend.reheal(int(float(1) * m))
	yield(get_tree().create_timer(1), "timeout")
	pass
				
func getEnemies():
	var enemy = [];
	if team == 0:
		#enemy = get_tree().get_nodes_in_group("zombie")
		#enemy = Arange.get_overlapping_bodies()
		for body in Arange.get_overlapping_bodies():
			if body.is_in_group("zombie"):
				enemy.append(body)
		
	elif team == 1:
		#enemy = get_tree().get_nodes_in_group("soldier")
		#enemy = Arange.get_overlapping_bodies()
		for body in Arange.get_overlapping_bodies():
			if body.is_in_group("soldier"):
				enemy.append(body)
		#enemy.append(soldierSpawn)
		
		#enemy.append(HQ)
		
	return enemy
	
func getFriends():
	var friends = []
	if team == 0:
		#enemy = get_tree().get_nodes_in_group("zombie")
		#enemy = Arange.get_overlapping_bodies()
		for body in Arange.get_overlapping_bodies():
			if body.is_in_group("soldier"):
				friends.append(body)
		
	elif team == 1:
		#enemy = get_tree().get_nodes_in_group("soldier")
		#enemy = Arange.get_overlapping_bodies()
		for body in Arange.get_overlapping_bodies():
			if body.is_in_group("zombie"):
				friends.append(body)
		#enemy.append(soldierSpawn)
		
		#enemy.append(HQ)
		
	return friends
	
func stop():
	stop = true
	pass


func _on_soldier_input_event(viewport, event, shape_idx):
	#print("input")
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_RIGHT:
			print("clicked")
			emit_signal("clicked", self)
	pass # Replace with function body.


func _mouse_entered():
	label.visible = true
	if team == 0 && get_tree().get_root().get_node("map").deploying == false:
		get_tree().get_root().get_node("map").setToolTip("RMB to edit position")
	pass # Replace with function body.


func _mouse_exited():
	if team == 0 && get_tree().get_root().get_node("map").deploying == false:
		get_tree().get_root().get_node("map").setToolTip("")
	label.visible = false
	pass # Replace with function body.
