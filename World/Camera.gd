extends Camera2D

func _ready():
	Events.room_entered.connect(func(room):
		global_position = room.global_position;
	)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
