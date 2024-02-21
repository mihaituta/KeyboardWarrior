#class_name EnemyKey 
extends CharacterBody2D

@export var ACCELERATION = 300
@export var MAX_SPEED = 50
@export var FRICTION = 300
@export var KNOCKBACK_FORCE = 100;
@onready var stats = $stats
@onready var hurtbox = $Hurtbox
#@onready var player = get_node("../../../Player")
@onready var enemyAttackRange = $EnemyAttackRange
@onready var animationPlayer = $AnimationPlayer;
@onready var bowAnimationPlayer = $BowAnimationPlayer
@onready var animationTree = $AnimationTree
@onready var animationState = animationTree.get("parameters/playback");
@onready var blinkAnimationPlayer = $BlinkAnimationPlayer
@onready var bow = $Bow
@onready var arrow_spawn_pivot = $Bow/ArrowSpawnPivot
@onready var arrow_hold_timer = $ArrowHoldTimer
@onready var bow_reload_timer = $BowReloadTimer

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")
const arrow = preload("res://Enemies/arrow.tscn")

#false is left, true is right
var facingDirection = false
var player
enum {
	IDLE, 
	CHASE,
	ATTACK,
	RELOAD
}

@export var state = IDLE
var knockback = Vector2.ZERO

func _ready():
	player = Global.player
	animationTree.active = true

func _physics_process(delta):
	_rotate_bow(delta)
	_set_knockback_velocity(delta)
	#facingDirection = velocity.x > 0
	
	match state: 
		IDLE:
			animationPlayer.play("Idle")
			animationState.travel("Idle")
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		CHASE:
			if player != null:
				animationState.travel("Idle")
				accelerate_towards_point(player.global_position, delta)
				_canAttackPlayer()
			else:
				state = IDLE
		ATTACK:
			animationPlayer.play("Idle")
			animationState.travel("Draw")
			velocity =  Vector2.ZERO 
			if !enemyAttackRange._playerInRange():
				state = CHASE
		RELOAD:
			animationState.travel("Shoot")
			
	move_and_slide()


func _rotate_bow(delta):
	if player != null:
		bow.rotation = lerp_angle(bow.rotation, global_position.angle_to_point(player.global_position), 0.05)
	#var angle_to_player = get_angle_to(player.global_position)
	#bow.rotation = move_toward(bow.rotation, angle_to_player, delta * 20 )
	#work but do it instantly
	#bow.rotation = global_position.angle_to_point(player.global_position)	
	#bow.look_at(player.global_position)
	
func _shoot_arrow():
	var arrow_instance = arrow.instantiate()
	arrow_instance.position = arrow_spawn_pivot.global_position
	#darrow_instance.look_at(player.global_position)
	arrow_instance.rotation = bow.rotation
	add_child(arrow_instance)
	
func _bow_hold():
	_start_timer(arrow_hold_timer, 1)

func _bow_reload():
	_start_timer(bow_reload_timer, 0.5)

func _on_arrow_hold_timer_timeout():
	_shoot_arrow()
	state = RELOAD

func _on_bow_reload_timer_timeout():
	state = ATTACK

func _start_timer(timer, duration):
	timer.wait_time = duration
	timer.start()
	
func _canAttackPlayer():
	if enemyAttackRange._playerInRange():
		state = ATTACK
	
func accelerate_towards_point(point, delta):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta) 
	animationPlayer.play("Run")
	#animationTree.set("parameters/Run/blend_position", direction.x)
	#animationTree.set("parameters/Attack/blend_position", direction.x)
	#animationState.travel("Run")
	
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
