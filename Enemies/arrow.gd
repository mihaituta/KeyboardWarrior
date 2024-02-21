class_name Arrow
extends Node2D

var speed = 250

@onready var impact_detector: Area2D = $ImpactDetector
@onready var timer: Timer = $Timer

func _ready():
	set_as_top_level(true)
	impact_detector.body_entered.connect(_on_impact)
	timer.timeout.connect(queue_free)
	timer.start(1)
	
func _physics_process(delta):
	position += (Vector2.RIGHT * speed).rotated(rotation) * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_impact(_body: Node) -> void:
	queue_free()
