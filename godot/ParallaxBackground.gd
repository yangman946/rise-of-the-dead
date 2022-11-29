extends ParallaxBackground


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var fog = get_node("ParallaxLayer5/Sprite")
var bloodlust = false
onready var fade = get_node("fade")
var end = false

# Called when the node enters the scene tree for the first time.
func _ready():
	fog.modulate.a = 0
	fade.connect("timeout", self, "_on_Timer_timeout")
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if bloodlust:
		if fog.modulate.a < 1:
			if fade.is_stopped():
				fog.modulate.a += 0.01
				fade.start(0.1)
	elif end:
		if fog.modulate.a > 0:
			if fade.is_stopped():
				fog.modulate.a -= 0.01
				fade.start(0.1)
			

func _on_Timer_timeout():
	fade.stop()

func bloodLust():
	fade.stop()
	bloodlust = true
	end = false

func endbloodLust():
	fade.stop()
	bloodlust = false
	end = true
	
