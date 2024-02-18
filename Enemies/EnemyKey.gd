class_name EnemyKey 
extends CharacterBody2D

@export var ACCELERATION = 300
@export var MAX_SPEED = 50
@export var FRICTION = 200
@export var KNOCKBACK_FORCE = 150;
@onready var stats = $stats
@onready var hurtbox = $Hurtbox
@onready var player = get_node("../../../Player")
@onready var enemyAttackRange = $EnemyAttackRange
@onready var animationPlayer = $AnimationPlayer;
@onready var animationTree = $AnimationTree
@onready var animationState = animationTree.get("parameters/playback");
@onready var blinkAnimationPlayer = $BlinkAnimationPlayer

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

#false is left, true is right
var facingDirection = false

enum {
	IDLE,
	CHASE,
	ATTACK
}

@export var state = IDLE
var knockback = Vector2.ZERO

func _ready():
	animationTree.active = true

func _physics_process(delta):
	_set_knockback_velocity(delta)
	facingDirection = velocity.x > 0
	
	match state: 
		IDLE:
			animationState.travel("Run")
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		CHASE:
			if player != null:
				accelerate_towards_point(player.global_position, delta)
				_canAttackPlayer()
			else:
				state = IDLE
		ATTACK:
			animationState.travel("Attack") 
			velocity =  Vector2.ZERO 
			if !enemyAttackRange._playerInRange():
				state = CHASE
	
	move_and_slide()

func _canAttackPlayer():
	if enemyAttackRange._playerInRange():
		state = ATTACK
	
func accelerate_towards_point(point, delta):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta) 
	animationTree.set("parameters/Run/blend_position", direction.x)
	animationTree.set("parameters/Attack/blend_position", direction.x)
	animationState.travel("Run")
	
func _on_hurtbox_area_entered(area):
	Global.camera.shake(0.1,1)
	stats.health -= area.damage
	var direction = (global_position - area.owner.global_position).normalized()
	knockback = direction * KNOCKBACK_FORCE
	hurtbox.create_hit_effect()
	hurtbox.start_invincibility(0.4)

func _start_chase():
	state = CHASE
	
func _set_knockback_velocity(delta):
	var old_velocity = velocity
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	velocity = knockback
	move_and_slide()
	knockback = velocity
	velocity = old_velocity
	
func _on_stats_no_health():
	var enemyDeathEffect = EnemyDeathEffect.instantiate()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.position = position
	queue_free()

func _on_hurtbox_invincibility_started():
	blinkAnimationPlayer.play("Start")
	
func _on_hurtbox_invincibility_ended():
	blinkAnimationPlayer.play("Stop")
