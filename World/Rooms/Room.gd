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
		
func _physics_process(_delta) -> void:
	if(enemies_container.get_child_count() == 0):
		_open_doors()

func _on_player_detector_body_entered(body):
	Events.room_entered.emit(self)
	if (body.name == 'Player' && num_enemies > 0):
		_close_doors()
		if enemies != null:
			for enemy in enemies.get_children(): 
				enemy._start_chase()
