extends StaticBody2D

@onready var animation_player = $AnimationPlayer

func open() -> void:
	print("open")
	animation_player.play("open");

func close() -> void:
	print("close")
	animation_player.play("close");
