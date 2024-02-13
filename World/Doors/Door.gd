extends StaticBody2D

@onready var doors_collision = $CollisionShape2D
@onready var sprite_2d = $Sprite2D
	
func _process(delta):
	if(doors_collision.disabled):
		sprite_2d.set_frame(1)
	else:
		sprite_2d.set_frame(0)
