extends AnimatedSprite2D
@onready var timer = $Timer

func _ready():
	#self.animation_finished.connect(_on_animation_finished)
	play("Animate")
	timer.start(3);


func _on_timer_timeout():
	get_tree().reload_current_scene()
	PlayerStats.health_restart()
