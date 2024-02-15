class_name EnemyKey 
extends CharacterBody2D

@export var MAX_SPEED = 40.0;
@export var ACCELERATION = 50.0;
@onready var animated_sprite_2d = $AnimatedSprite2D

func _ready():
	Events.room_entered.connect(func(room):
		print("SMS")
	)
