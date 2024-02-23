class_name Arrow
extends Node2D

var speed = 300

@onready var impact_detector: Area2D = $ImpactDetector
@onready var timer: Timer = $Timer
@onready var animation_player = $AnimationPlayer
@onready var gpu_particles_2d = $GPUParticles2D

func _ready():
	set_as_top_level(true)
	impact_detector.body_entered.connect(_on_impact)
	impact_detector.area_entered.connect(_on_impact)
	#timer.timeout.connect(_timer_done)
	#timer.start(1)
	
func _physics_process(delta):
	position += (Vector2.RIGHT * speed).rotated(rotation) * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
	
func _timer_done():
	speed = 0
	animation_player.play("Hit")

func _on_impact(body):
	speed = 0
	animation_player.play("Hit")
