extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export (int) var screen = 0
export (float) var time = 0.0
onready var animator = get_node("AnimationPlayer")
onready var timer = get_node("Timer")
onready var player = get_node("AudioStreamPlayer")


var tips = ["Move the camera by click and drag or mouse scroll",
			"Levelling up will increase overall stats and cost of all your soldiers",
			"The Nuke will destroy all enemies in its radius, use it sparingly!",
			"Zombies will get progressively stronger and faster overtime",
			"The grenader is best for clearing out large mobs",
			"The shield man has the most HP, use him to protect your other troops",
			"The sniper is a long ranged troop, keep him away from exploding zombies",
			"Your base health points do not regenerate! Keep it safe at all costs.",
			"Use the right mouse button on troops to move them.",
			"Use the medic to heal your other troops",
			"Beware the reaper, it can resurrect the dead!"]
# Called when the node enters the scene tree for the first time.
func _ready():
	timer.connect("timeout", self, "Timeout")
	timer.start(time)
	randomize()

	if screen == 1:
		var rand = randi() % tips.size()
		get_node("ColorRect/Label3").text = "Tip: " + tips[rand]
		MusicPlayer.play_music()
		pass
		
	
	animator.play("load")
	
	yield(get_tree().create_timer(0.5), "timeout")
	player.play()
	pass # Replace with function body.

func Timeout():
	if screen == 0:
		SceneTransition.change_scene("res://splashscreen2.tscn")
	else:
		SceneTransition.change_scene("res://MainMenu.tscn")
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
