class_name EnemyKey 
extends CharacterBody2D

@export var ACCELERATION = 300
@export var MAX_SPEED = 50
@export var FRICTION = 200
@export var KNOCKBACK_FORCE = 100;
@onready var animationPlayer = $AnimatedSprite2D
@onready var stats = $stats
@onready var hurtbox = $Hurtbox
@onready var player = get_node("../../../Player")
@onready var enemyAttackRange = $EnemyAttackRange

enum {
	IDLE,
	CHASE,
	ATTACK
}

@export var state = IDLE
var knockback = Vector2.ZERO

func _physics_process(delta):
	_set_knockback_velocity(delta)
	print(enemyAttackRange._playerInRange())
	match state: 
		IDLE: 
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		CHASE:
			print("chase")
			if player != null:
				accelerate_towards_point(player.global_position, delta)
				_canAttackPlayer()
			else:
				state = IDLE
		ATTACK:
			print("attack")
			if !enemyAttackRange._playerInRange():
				state = CHASE
			
	move_and_slide()

func _canAttackPlayer():
	if enemyAttackRange._playerInRange():
		state = ATTACK
	
func accelerate_towards_point(point, delta):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta) 
	
func _on_hurtbox_area_entered(area):
	stats.health -= area.damage
	var direction = (global_position - area.owner.global_position).normalized()
	knockback = direction * KNOCKBACK_FORCE
	hurtbox.create_hit_effect()

func _start_chase():
	state = CHASE
	
func _set_knockback_velocity(delta):
	var old_velocity = velocity
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	velocity = knockback
	move_and_slide()
	knockback = velocity
	velocity = old_velocity
	#knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	#velocity = knockback
	#move_and_slide()
	
func _on_stats_no_health():
	queue_free()
