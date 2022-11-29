extends Camera2D


#onready var L_arrow = get_tree().get_root().get_node("map/CanvasLayer/interface/HBoxContainer/Control")
#onready var R_arrow = get_tree().get_root().get_node("map/CanvasLayer/interface/HBoxContainer2/Control")

var trauma = 0.0  # Current shake strength.
var trauma_power = 2  # Trauma exponent. Use [2, 3].
var decay = 0.8  # How quickly the shaking stops [0, 1].
var max_offset = Vector2(100, 75)  # Maximum hor/ver shake in pixels.
var max_roll = 0.1  # Maximum rotation in radians (use sparingly).
onready var noise = OpenSimplexNoise.new()
var noise_y = 0
var death = false

func _ready():
	randomize()
	noise.seed = randi()
	noise.period = 4
	noise.octaves = 2

func add_trauma(amount):
	if trauma < 0.4 and death == false:
		trauma = min(trauma + amount, 1.0)
		
func death():
	death = true
	add_trauma(1)
	# will show menu
	pass

"""
func _input(ev):
	
	if Input.is_key_pressed(KEY_A):
		move(0.95, Vector2(-500, 25))
	elif Input.is_key_pressed(KEY_D):
		move(0.95, Vector2(500, 25))
"""



func _input(event: InputEvent) -> void:
	if get_parent().dead:
		return
	if event is InputEventMouseMotion:
		if get_parent().deploying == false:
			if event.button_mask == BUTTON_MASK_LEFT:
				#print(event.position)
				position.x -= event.relative.x

	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP:
			position.x -= 50 #maybe change this
			pass
		elif event.button_index == BUTTON_WHEEL_DOWN:
			position.x += 50
			pass
	if global_position[0] <= -410:
		#L_arrow.hide()
		global_position[0] = -410
	elif global_position[0] >= 4740:
		#R_arrow.hide()
		global_position[0] = 4740
			


func _process(_delta: float) -> void:
	if trauma:
		trauma = max(trauma - decay * _delta, 0)
		shake()
		
	if death:
		return
		
	"""
	var viewport := get_viewport()
	var viewport_center := viewport.size / 2.0
	var direction := viewport.get_mouse_position() - viewport_center
	var percent := (direction / viewport.size * 2.0).length()
	move(percent, direction)
	"""
	
func shake():
	var amount = pow(trauma, trauma_power)
	noise_y += 1
	rotation = max_roll * amount * noise.get_noise_2d(noise.seed, noise_y)
	offset.x = max_offset.x * amount * noise.get_noise_2d(noise.seed*2, noise_y)
	offset.y = max_offset.y * amount * noise.get_noise_2d(noise.seed*3, noise_y)
	
	
	
