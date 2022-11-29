extends Node2D

# Sorry for spagetti code
# handles all of the game logic like waves, spawning, user money, etc.

export (int) var wave = 0
export (float) var Max_health = 100
export (int) var Money = 500
onready var health = Max_health setget _set_health
export (int) var level = 1 # increase level will cost money, will increase all stats

var speed = 1
var speeds = [0.5, 1, 2, 4]

var paused = false
var dead = false

var units_delopied = 0
var zombies_killed = 0


var multiplier = 1 # will change every 5 waves
var lvlmultiplier = log(level) + 1 # will change with level to increase soldier stats
var chance_z = 0 # chance to summon spawn from hell
var lvlCost = 200

var spawning = false

var bloodlust = false

onready var SoldierSpawn = get_node("soldier spawn")
onready var ZombieSpawn = get_node("zombieSpawn")
onready var Cam = get_node("Camera2D")

onready var spawntimer: Timer = $Timer
onready var toolTimer = get_node("toolTip timer")

onready var MoneyTxt = get_node("CanvasLayer/interface/HBoxContainer3/VBoxContainer/Control2/NinePatchRect/Label")
onready var healthTxt = get_node("CanvasLayer/interface/HBoxContainer3/VBoxContainer/Control/NinePatchRect/Label")
onready var waveTxt = get_node("CanvasLayer/interface/VBoxContainer2/Label") # might have to change
onready var toolTip = get_node("CanvasLayer/interface/VBoxContainer3/Tooltip")
onready var speedbtn = get_node("CanvasLayer/interface/VBoxContainer2/speed")
onready var lvlTxt = get_node("CanvasLayer/interface/HBoxContainer3/VBoxContainer/Control3/NinePatchRect/Label")

onready var pauseScreen = get_node("CanvasLayer/interface/pauseScreen")
onready var deathScreen = get_node("CanvasLayer/interface/deathScreen")

onready var interface = get_node("CanvasLayer/interface")


var waveConfig = [] # array to store indexes of all enemies to spawn
var spawnConfig = []
var originalamnt = 0
var rng = RandomNumberGenerator.new()

var deploying = false

var soldier = preload("res://player.tscn")
var nuke = preload("res://NUKE.tscn")
var landmine = preload("res://landmine.tscn")
var zombie = preload("res://zombie.tscn")
var btn = preload("res://interface/MenuBTN.tscn")
var sbtn = preload("res://interface/specialMenuBTN.tscn")
var deploy = preload("res://deploy.tscn")
var explosion = preload("res://explosion.tscn")

var tutorial = ["Commander, the zombies are coming! Send out troops to defend the post!",
			"Click and drag or scroll to move the camera!",
			"Right Click on soldiers to move them.",
			""]
			
var defaultTip = ""
var indt = 0

var bloodlustChance = 0

var boosts = [ # create nodes for each, this is probability split for boost drop
	{
		"name": "Double Points",
		"url": "",
		"rarity": 0.5
	},
	{
		"name": "InstaKill", 
		"url": "",
		"rarity": 0.1
	},
	{
		"name": "Reheal",
		"url": "",
		"rarity": 0.35
	}
]

var specials = []

func updateDict():
	var newSpecials = specials.duplicate()
	newSpecials = [
		{
			"name": "Nuke",
			"texture": "res://sprites/nuke.png",
			"dps": int(6000 * lvlmultiplier),
			"attack_range": int(500 * lvlmultiplier),
			"cost": int(float(500) * lvlmultiplier),
			"cooldown": 120,
			"deploy": "res://sprites/Nuke_deploy.png"
		},
		{
			"name": "Land Mine",
			"texture": "res://sprites/landmine_s.png",
			"dps": int(1000 * lvlmultiplier),
			"attack_range": int(100 * lvlmultiplier),
			"cost": int(float(100) * lvlmultiplier),
			"cooldown": 30,
			"deploy": "res://sprites/landmine_deploy.png"
		},
		{
			"name": "Level up",
			"texture": "res://sprites/lvl.png",
			"cost": self.lvlCost,
			"cooldown": 30,
		},
	]
	
	specials = newSpecials
	
	var newsoldiers = soldiers.duplicate()
	newsoldiers = [
		{
			"name": "Soldier",
			"cost": int(float(100) * lvlmultiplier),
			"texture": "res://sprites/soldier.png",
			"health": int(250 * lvlmultiplier),
			"dps": int(100 * lvlmultiplier),
			"speed": 1 * lvlmultiplier,
			"attack_range": int(500 * lvlmultiplier),
			"attack_rate": 2.0 / lvlmultiplier,
			"reward": 100,
			"projectile": true,
			"cooldown": 10,
			"explode": false,
			"deploy": "res://sprites/Soldier_deploy.png"
		},
		{
			"name": "Sword man",
			"cost": int(float(250) * lvlmultiplier),
			"texture": "res://sprites/sword man.png",
			"health": int(500 * lvlmultiplier),
			"dps": int(250 * lvlmultiplier),
			"speed": 1 * lvlmultiplier,
			"attack_range": int(250 * lvlmultiplier),
			"attack_rate": 2.0 / lvlmultiplier,
			"reward": 100,
			"projectile": false,
			"cooldown": 10,
			"explode": false,
			"deploy": "res://sprites/sword_deploy.png"
		},
		{
			"name": "Medic",
			"cost": int(float(500) * lvlmultiplier),
			"texture": "res://sprites/medic.png",
			"health": int(500 * lvlmultiplier),
			"dps": int(50 * lvlmultiplier),
			"speed": 1 * lvlmultiplier,
			"attack_range": int(500),
			"attack_rate": 2.0 / lvlmultiplier,
			"reward": 100,
			"projectile": true,
			"cooldown": 10,
			"explode": false,
			"deploy": "res://sprites/medic_deploy.png"
		},
		{
			"name": "Sniper",
			"cost": int(float(500) * lvlmultiplier),
			"texture": "res://sprites/sniper.png",
			"health": int(250 * lvlmultiplier),
			"dps": int(800 * lvlmultiplier),
			"speed": 0.5 * lvlmultiplier,
			"attack_range": int(1500 * lvlmultiplier),
			"attack_rate": 8.0 / lvlmultiplier,
			"reward": 100,
			"projectile": true,
			"cooldown": 40,
			"explode": false,
			"deploy": "res://sprites/Sniper_deploy.png"
		},
		{
			"name": "Shield man",
			"cost": int(float(650) * lvlmultiplier),
			"texture": "res://sprites/shield.png",
			"health": int(5000 * lvlmultiplier),
			"dps": int(50 * lvlmultiplier),
			"speed": 0.5 * lvlmultiplier,
			"attack_range": int(250 * lvlmultiplier),
			"attack_rate": 4.0 / lvlmultiplier,
			"reward": 100,
			"projectile": true,
			"cooldown": 60,
			"explode": false,
			"deploy": "res://sprites/Shield_deploy.png"
		},
		{
			"name": "Special Ops",
			"cost": int(float(1000) * lvlmultiplier),
			"texture": "res://sprites/special ops.png",
			"health": int(1000 * lvlmultiplier),
			"dps": int(50 * lvlmultiplier),
			"speed": 1.5 * lvlmultiplier,
			"attack_range": int(700 * lvlmultiplier),
			"attack_rate": 0.5 / lvlmultiplier,
			"reward": 100,
			"projectile": true,
			"cooldown": 60,
			"explode": false,
			"deploy": "res://sprites/SpecialOps_deploy.png"
		},
		{
			"name": "Grenader",
			"cost": int(float(1500) * lvlmultiplier),
			"texture": "res://sprites/grenader.png",
			"health": int(500 * lvlmultiplier),
			"dps": int(800 * lvlmultiplier),
			"speed": 1 * lvlmultiplier,
			"attack_range": int(1000 * lvlmultiplier),
			"attack_rate": 4.0 / lvlmultiplier,
			"reward": 100,
			"projectile": true,
			"cooldown": 60,
			"explode": true,
			"deploy": "res://sprites/Grenader_deploy.png"
		}
	]
	
	soldiers = newsoldiers
	pass
	
func cycleTut():
	if indt < len(tutorial):
		defaultTip = tutorial[indt]
		#play some sound
		resetToolTip()
		toolTimer.start(10)
	else:
		resetToolTip()

func updateZombies(multipliers):
	var newZombies = zombies.duplicate()
	newZombies = [ # index 0 = default, other = special type
		{
			"name": "zombie",
			"texture": "res://sprites/zombie.png",
			"health": int(25 * multipliers),
			"dps": int(25 * multipliers),
			"speed": 0.5 * multipliers,
			"attack_range": 200,
			"attack_rate": 1.0 / multipliers,
			"reward": int(10 * multipliers) + 30,
			"projectile": false,
			"cooldown": 0,
			"explode": false,
		},
		{
			"name": "hell hound",
			"texture": "res://sprites/zombie_dog.png",
			"health": int(25 * multipliers),
			"dps": int(50 * multipliers),
			"speed": 1 * multipliers,
			"attack_range": 200,
			"attack_rate": 1.0 / multipliers,
			"reward": int(10 * multipliers) + 30,
			"projectile": false,
			"cooldown": 0,
			"explode": false,
		},
		{
			"name": "fast",
			"texture": "res://sprites/fast_zombie.png",
			"health": int(50 * multipliers),
			"dps": int(25 * multipliers),
			"speed": 1.5 * multipliers,
			"attack_range": 200,
			"attack_rate": 0.5 / multipliers,
			"reward": int(50 * multipliers) + 30,
			"projectile": false,
			"cooldown": 0,
			"explode": false,
		},
		{
			"name": "Bomber zombie",
			"texture": "res://sprites/suicidebomber.png",
			"health": int(100 * multipliers),
			"dps": int(500 * multipliers),
			"speed": 1 * multipliers,
			"attack_range": 200,
			"attack_rate": 1.0 / multipliers,
			"reward": int(150 * multipliers) + 30,
			"projectile": false,
			"cooldown": 0,
			"explode": true,
		},
		{
			"name": "Zombie Soldier",
			"texture": "res://sprites/zombie_soldier.png",
			"health": int(200 * multipliers),
			"dps": int(100 * multipliers),
			"speed": 1 * multipliers,
			"attack_range": 500,
			"attack_rate": 2.0 / multipliers,
			"reward": int(100 * multipliers) + 30,
			"projectile": true,
			"cooldown": 0,
			"explode": false,
		},
		{
			"name": "reaper",
			"texture": "res://sprites/reaper.png",
			"health": int(300 * multipliers),
			"dps": int(250 * multipliers),
			"speed": 1 * multipliers,
			"attack_range": 200,
			"attack_rate": 1.0 / multipliers,
			"reward": int(10 * multipliers) + 30,
			"projectile": false,
			"cooldown": 0,
			"explode": false,
		},
		{
			"name": "dimitri the 5th",
			"texture": "res://sprites/titan.png",
			"health": int(2000 * multipliers),
			"dps": int(800 * multipliers),
			"speed": 0.25 * multipliers,
			"attack_range": 200,
			"attack_rate": 4.0 / multipliers,
			"reward": int(200 * multipliers) + 30,
			"projectile": false,
			"cooldown": 0,
			"explode": false,
		}
	]
	zombies = newZombies

var zombies = []
var soldiers = []

func setToolTip(string, b=false):
	#toolTimer.stop()
	if b:
		toolTip.modulate = Color(1, 0, 0)
	else:
		toolTip.modulate = Color(1, 1, 1)
	toolTip.text = string
	#toolTimer.start(10)
	
func resetToolTip():
	toolTip.modulate = Color(1, 1, 1)
	toolTip.text = defaultTip

func _on_ToolTimer_timeout():
	toolTimer.stop()
	indt += 1
	cycleTut()

func _input(event):
	if event is InputEventKey and event.pressed and event.echo == false:
		if Input.is_key_pressed(KEY_ESCAPE):
			pause()

func playaudio(sound):
	MusicPlayer.playaudio(sound)
		


func pause():
	if (!dead):
		interface.playaudio("res://audio/click (1).wav")
		if paused:
			paused = false
			pauseScreen.visible = false
			get_tree().paused = false
		else:
			paused = true
			pauseScreen.visible = true
			get_tree().paused = true

func spawnBTN(): # maybe use this as reset for store????
	for i in range(len(soldiers)):
		var b = btn.instance()
		b.init(i, soldiers[i]["texture"], false)
		get_node("CanvasLayer/interface/bottomMenu").add_child(b)
	
func spawnSpecialBTN():
	for i in range(len(specials)):
		var b = sbtn.instance()
		b.init(i, specials[i]["texture"], true)
		get_node("CanvasLayer/interface/HBoxContainer3").add_child(b)
		


func Chance(percent):
	
	var my_random_number = rng.randf_range(0.0, 100.0)
	if my_random_number < percent:
		return true
	else:
		return false

func increaseMultiplier(b): # increases every round
	"""
	chance_z = (-(200/(wave+15)) + 10) * 10
	
	if chance_z < 0:
		chance_z = 0
	"""
	if wave % 2 == 0: # every 2nd round
		multiplier = self.multiplier * 1.2
		
	if b:
		updateZombies(self.multiplier * 2)
	else:

		updateZombies(multiplier)
	
func levelUp():
	playaudio("res://audio/lvl.wav")
	self.level += 1
	self.lvlTxt.text = "LVL " + str(level)
	#self.lvlmultiplier = log(level)/log(10) + 1
	self.lvlmultiplier = self.lvlmultiplier * 1.1
	self.lvlCost = int(float(lvlCost) * lvlmultiplier)
	updateDict()
	
	var soldiers = get_tree().get_nodes_in_group("soldier")
	
	for s in soldiers:
		if s.isHq == false:
			s.Max_health = s.Max_health * 1.1
			s.health = s.Max_health
			s.speed = s.speed * 1.1
			s.dps = s.dps * 1.1
			s.attackrange = s.attackrange * 1.1
			s.attackrate = s.attackrate/1.1
			pass
			
		
	#print(lvlCost)



func weights(length):
	
	var weight = distribution(length)
	var totalw = 0.0
	var acc = []
	
	for i in range(length):
		totalw += weight[i]
		acc.append(totalw)

	return acc
	
func distribution(l): # index and length
	#mean
	#print(l)
	
	var weight = []
	for x in range(l):
		
		var m = (float(l) * 25)/(wave+25)
		var u = (l - m)/10 # mean
		#print(u)
		
		var o = 0.1 + float(wave)/100 # standard deviation
		#print(o)
		
		var z = ((float(x)/10) - u)/o
		#print(z)
		
		var k = 1/(o * sqrt(2 * PI))
		var p = k * pow(exp(1), -0.5*pow(z,2))
		weight.append(stepify(p, 0.01))
		
	return weight
# this function will calculate the zombies to spawn/wave and will store indexes in array
func WaveSpawner(offset): # run once per round
	var zombieCount = wave * 2 + 5 # change this???
	waveConfig = []
	spawnConfig = []
	var w = weights(len(zombies))
	print(w)
	
	for i in range(zombieCount):
		# add zombies but choose the zombie
		"""
		if (Chance(chance_z)):
			var my_random_number = rng.randi_range(2, len(zombies)-1)
			#var my_random_number = 2
			waveConfig.append(my_random_number)
			
		else:
			waveConfig.append(rng.randi_range(0, 1))
		"""
		var roll = rand_range(0.0, w[-1])
		for z in range(len(zombies)):
			if w[z] > roll:
				if z + offset >= len(zombies):
					waveConfig.append(z)
				else:
					waveConfig.append(z + offset)
				break
		

	spawnConfig = [] + waveConfig
	print(waveConfig)
	originalamnt = len(spawnConfig)
	spawning = true
		

func NewWave():

	# some animation or audio?
	interface.newwave()
	playaudio("res://audio/bell.wav")
	wave += 1
	waveTxt.text = "Wave " + str(wave)
	print("Wave " + str(wave) + " Begins!")
	var o = 0
	var b = false
	if bloodlust == true:
		bloodlust = false
		bloodlustChance = 0
		get_node("ParallaxBackground").endbloodLust()
		defaultTip = "You survived BLOODLUST"
		toolTimer.start(10)
		setToolTip(defaultTip)
	else:
		if wave >= 5: # wave % 2 == 5
			bloodlustChance += 0.1
			if Chance(log(bloodlustChance + 1) * 100) && bloodlust == false:
				print("bloodlust")
				o = 1 # hmm
				b = true
				defaultTip = "BLOODLUST - They smell your fear"
				toolTimer.start(10)
				setToolTip(defaultTip, true)
				get_node("ParallaxBackground").bloodLust()
				bloodlust = true
				pass
			
	increaseMultiplier(b)
	WaveSpawner(o)


# Called when the node enters the scene tree for the first time.
func _ready():
	healthTxt.text = str(health)
	MoneyTxt.text = str(Money)
	self.lvlTxt.text = "LVL " + str(level)
	resetToolTip()
	get_node("CanvasLayer/interface/VBoxContainer2/Button").connect("pressed", self, "pause")
	get_node("CanvasLayer/interface/VBoxContainer2/speed").connect("pressed", self, "speedToggle")
	Engine.time_scale = 1
	rng.randomize()
	spawntimer.connect("timeout", self, "_on_Timer_timeout")
	toolTimer.connect("timeout", self, "_on_ToolTimer_timeout")
	spawntimer.stop()
	updateDict()
	spawnBTN()
	spawnSpecialBTN()
	
	NewWave()
	cycleTut()
	
	playaudio("res://audio/start.wav")
	

func speedToggle():
	playaudio("res://audio/click (1).wav")
	speed += 1
	if speed > len(speeds) - 1:
		speed = 0
	
	Engine.time_scale = speeds[speed]
	speedbtn.text = str(speeds[speed]) + "x"
	
	pass

# stub rn - change it to deal with UI inputs
"""
func _input(event):
	if Input.is_key_pressed(KEY_0):
		hireMerc(0)
	elif Input.is_key_pressed(KEY_1):
		hireMerc(1)
	elif Input.is_key_pressed(KEY_2):
		hireMerc(2)
	elif Input.is_key_pressed(KEY_3):
		spawnZombie(0)
"""		

func removeItem():
	spawnConfig.remove(len(spawnConfig)-1) # just remove one

func addBalance(value):
	Money += value 
	MoneyTxt.text = str(Money)
	# update label or something

func subtractBalance(value):
	Money -= value
	MoneyTxt.text = str(Money)
	# update label or something
	

func startSpecial(index):
	if deploying == false:
		if specials[index]["cost"] <= Money:
			if specials[index]["name"] == "Level up":
				subtractBalance(specials[index]["cost"])
				levelUp()
				setToolTip("Leveled up to Level " + str(level) + "!")
				return [false, null]
				
			elif specials[index]["name"] == "Nuke":
				setToolTip("Deploy " + specials[index]["name"] + ": LMB to deploy, RMB to cancel")
				deploying = true
				# deploy
				var d = deploy.instance()
				d.init(index, specials[index]["deploy"], true)
				add_child(d)
				return [true, d]
			elif specials[index]["name"] == "Land Mine":
				setToolTip("Deploy " + specials[index]["name"] + ": LMB to deploy, RMB to cancel")
				deploying = true
				# deploy
				var d = deploy.instance()
				d.init(index, specials[index]["deploy"], true)
				add_child(d)
				return [true, d]
		else:
			print("not enough money")
	pass

func hireMerc(index):
	
	print("hired Merc " + str(index))
	if (soldiers[index]["cost"] <= Money):
		if deploying == false:
			setToolTip("Deploy " + soldiers[index]["name"] + ": LMB to deploy, RMB to cancel")
			deploying = true
			var d = deploy.instance()
			d.init(index, soldiers[index]["deploy"], false)
			add_child(d)
			return d

	else:
		
		print("not enough money")
	
		
	
func confirm(index, pos, special):
	
	if special == false:
		setToolTip("Deployed " + soldiers[index]["name"] + "!")
		deploying = false
		units_delopied += 1
		subtractBalance(soldiers[index]["cost"])
		var s = soldier.instance()
		s.position = Vector2(SoldierSpawn.global_position.x, 0)
		s.connect("clicked", self, "clickedSoldier")
		s.init(index, pos, soldiers[index]["texture"], soldiers[index]["health"], soldiers[index]["dps"], soldiers[index]["speed"], soldiers[index]["attack_range"], soldiers[index]["attack_rate"], soldiers[index]["reward"], soldiers[index]["projectile"], soldiers[index]["explode"])
		add_child(s)
	else:
		
		setToolTip("Deployed " + specials[index]["name"] + "!")
		deploying = false
		units_delopied += 1
		subtractBalance(specials[index]["cost"])
		var s;
		if specials[index]["name"] == "Nuke":
			s = nuke.instance()
		elif specials[index]["name"] == "Land Mine":
			s = landmine.instance()
		s.init(pos, specials[index]["dps"], specials[index]["attack_range"])
		#s.init(pos, soldiers[index]["texture"], soldiers[index]["health"], soldiers[index]["dps"], soldiers[index]["speed"], soldiers[index]["attack_range"], soldiers[index]["attack_rate"], soldiers[index]["reward"], soldiers[index]["projectile"], soldiers[index]["explode"])
		add_child(s)
	
	
func clickedSoldier(soldier):
	if deploying == true:
		return
	deploying = true
	var d = deploy.instance()
	setToolTip("LMB to move, RMB to cancel")
	#d.init(index, soldiers[index]["deploy"], false)
	d.moveInit(soldier, soldiers[soldier.index]["deploy"])
	add_child(d)
	pass

func cancel():
	deploying = false

func spawnZombie(index):
	
	var z = zombie.instance()
	z.position = ZombieSpawn.global_position
	z.init(index, 0, zombies[index]["texture"], zombies[index]["health"], zombies[index]["dps"], zombies[index]["speed"], zombies[index]["attack_range"], zombies[index]["attack_rate"], zombies[index]["reward"], zombies[index]["projectile"], zombies[index]["explode"])
	add_child(z)
	
func spawnZombie2(index, pos):
	var z = zombie.instance()
	z.position = pos
	z.init(index, 0, zombies[index]["texture"], zombies[index]["health"], zombies[index]["dps"], zombies[index]["speed"], zombies[index]["attack_range"], zombies[index]["attack_rate"], zombies[index]["reward"], zombies[index]["projectile"], zombies[index]["explode"])
	add_child(z)
	
func calculateTime(enemiesleft):
	#print(enemiesleft)
	# we want maximum at middle, minimum at edges
	var x = 1/(float(originalamnt)/2) # error here
	var result = 10*cos(x*PI*float(enemiesleft)) + 12
	#var result = 2*cos(x*PI*float(enemiesleft)+2*PI)+4
	return int(result)

func spawn():
	if !dead:
		if (spawntimer.is_stopped() and spawning):
			
			if len(waveConfig) > 0:
				spawnZombie(waveConfig[len(waveConfig)-1])
				waveConfig.remove(len(waveConfig)-1)
				
				if len(waveConfig) != 0:
					spawntimer.start(rng.randi_range(0, calculateTime(len(waveConfig))))
			else:
				spawning = false
			
		if len(spawnConfig) <= 0:
			#new wave
			spawning = false # redundant???
			NewWave()
			spawntimer.start(10)
			

	
#Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	spawn()

		
func _on_Timer_timeout():
	spawntimer.stop()


func _set_health(value):
	var prev_health = health
	health = clamp(value, 0, Max_health)
	healthTxt.text = str(health)
	Cam.add_trauma(0.5)
	if health != prev_health:
		emit_signal("health_updated", health)
		if health == 0:
			kill()
	
func kill():
	emit_signal("death")
	print("YOU DIED!!!!")
	if dead == false:
		dead = true
		# explode!!!!
		detonate()
	
	#_animation_player.stop()
func detonate(): 
	Cam.death()
	var ex = explosion.instance()
	ex.position = global_position
	ex.init(20000, 6000, 0)
	
	add_child(ex)
	
	
	
	deathScreen.get_node("rounds").text = "You lasted " + str(wave) + " rounds \n" + "Zombies killed: " + str(zombies_killed) + " \n Units deployed: " + str(units_delopied)
	yield(get_tree().create_timer(0.5), "timeout")
	deathScreen.visible = true


	
func damage(amount):
	# update label
	
	
	_set_health(health - 1)
	#_animation_player.stop()
	print("damage")
	#_animation_player.play("damage")
