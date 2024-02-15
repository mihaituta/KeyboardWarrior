extends Node2D
@onready var enemies = $Enemies

func _on_player_detector_body_entered(body):
	if body.name == 'Player':
		Events.room_entered.emit(self)
		
		#if enemies != null:
			#for enemy in enemies.get_children(): 
