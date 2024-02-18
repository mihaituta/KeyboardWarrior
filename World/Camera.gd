extends Camera2D

var shake_amount : float = 0
var default_offset : Vector2 = offset
var pos_x : int 
var pos_y : int

@onready var timer : Timer = $Timer
@onready var tween : Tween = create_tween()

func _ready():
	set_process(true)
	Events.room_entered.connect(func(room):
		global_position = room.global_position;
	)
	Global.camera = self
	randomize()
	
func shake(time: float, amount: float):
	timer.wait_time = time
	shake_amount = amount
	set_process(true)
	timer.start()
	
func _process(_delta: float):
	offset = Vector2(randf_range(-1, 1) * shake_amount, randf_range(-1, 1) * shake_amount)

func _on_timer_timeout() -> void:
	set_process(false)
	tween.interpolate_value(self, "offset", 1, 1, Tween.TRANS_LINEAR, Tween.EASE_IN)


#@export var randomStrength: float = 3.0
#@export var shakeFade: float = 15.0
#
#var rng = RandomNumberGenerator.new()
#
#var shake_strength: float = 0.0
#
#func _ready():
	#Events.room_entered.connect(func(room):
		#global_position = room.global_position;
	#)
#
#func _process(delta):
	#if Input.is_action_just_pressed("attack"):
		#apply_shake()
		#
	#if (shake_strength > 0):
		#shake_strength = lerpf(shake_strength, 0, shakeFade * delta)
		#offset = randomOffset()
		#
#func apply_shake():
	#shake_strength = randomStrength
	#
#func randomOffset() -> Vector2:
	#return Vector2(rng.randf_range(-shake_strength, shake_strength), rng.randf_range(-shake_strength, shake_strength))


