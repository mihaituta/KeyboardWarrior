extends Node2D
@onready var enemies = $Enemies

@onready var doors_container = $Doors
@onready var enemies_container = $Enemies
var num_enemies

func _ready() -> void:
	num_enemies = enemies_container.get_child_count();

func _open_doors() -> void:
	for door in doors_container.get_children():
		door.open()
		
func _close_doors() -> void:	
	for door in doors_container.get_children():
		door.close()
		
func _physics_process(delta) -> void:
	if(num_enemies == 0):
		_open_doors()
		
func _on_player_detector_body_entered(body):
	if (body.name == 'Player' && num_enemies > 0):
		_close_doors()
		Events.room_entered.emit(self)
		if enemies != null:
			for enemy in enemies.get_children(): 
				enemy._start_chase()
