class_name EnemyKey 
extends CharacterBody2D

@export var ACCELERATION = 300
@export var MAX_SPEED = 50
@export var FRICTION = 200

@onready var animationPlayer = $AnimatedSprite2D

enum {
	IDLE,
	CHASE
}

var state = IDLE
var knockback = Vector2.ZERO

func _ready():
	Events.room_entered.connect(func(room):
		pass
	)



func _on_hurtbox_area_entered(area):
	queue_free()
