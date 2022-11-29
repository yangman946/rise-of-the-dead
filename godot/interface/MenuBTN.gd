extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var btn = get_node("Button")
onready var loading = get_node("Button/ColorRect")
onready var disable = get_node("Button/ColorRect2")

onready var manager = get_tree().get_root().get_node("map")
onready var interface = get_tree().get_root().get_node("map/CanvasLayer/interface")

#onready var time = get_node("loadTimer")
var special = false

var enabled = true
var ind = 0
var loads = false
var cool = 0
var timestart;



# Called when the node enters the scene tree for the first time.
func _ready():
	enabled()
	check()

	pass # Replace with function body.

func init(index, texture, s):
	#print(path)
	get_node("Button/Sprite").texture = load(texture)
	self.ind = index
	self.special = s
	#time.connect("timeout", self, "_on_Timer_timeout")

	#time.stop()

func check():
	if (loads == false):
		if manager.Money < getItem()["cost"]:
			
			disable()
		else:
			enabled()

func enabled():
	enabled = true
	loads = false
	disable.visible = false
	loading.rect_size.y = 0
	
func disable():
	enabled = false
	loads = false
	disable.visible = true
	loading.rect_size.y = 0
	
# will do loading effect based on cooldown
func loadFrame():
	enabled = false
	disable.visible = true
	loading.rect_size.y = 84
	timestart = OS.get_ticks_msec()
	#print(timestart)
	loads = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if loads:
		var time_now = OS.get_ticks_msec()
		var time_elapsed = time_now - timestart
		#print(time_elapsed)
		
		if time_elapsed >= getItem()["cooldown"] * 1000:
			enabled()
		else:
			var percent = time_elapsed/float(getItem()["cooldown"] * 1000)
			#print(percent)
			loading.rect_size.y = (1-percent) * 84
	else:
		check()
		
func getItem():
	if special:
		return manager.specials[ind]
		#pass
	else:
		return manager.soldiers[ind]


func _on_Button_pressed():
	if enabled:
		interface.playaudio("res://audio/click (1).wav")
		var result;
		if special:
			result = manager.startSpecial(ind)
			if result[0] == false:
				loadFrame()
			elif result[0] == true:
				result[1].connect("instanced", self, "confirm") # confirmed 
		else:
			result = manager.hireMerc(ind)
			if result != null:
				result.connect("instanced", self, "confirm") # confirmed 
	else:
		interface.playaudio("res://audio/invalid.wav")
			

func confirm(index):
	if index == ind:
		loadFrame()
	pass


func _on_Button_mouse_entered():
	#print("hover")
	if manager.deploying == false:
		manager.setToolTip(getItem()["name"] + ": $" + str(getItem()["cost"]))
	pass # Replace with function body.





func _on_Button_mouse_exited():
	if manager.deploying == false:
		manager.resetToolTip()
	pass # Replace with function body.



