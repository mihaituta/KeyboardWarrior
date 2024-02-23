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
@onready var staffAnimationPlayer = $StaffAnimationPlayer
@onready var animationTree = $AnimationTree
@onready var animationState = animationTree.get("parameters/playback");
@onready var blinkAnimationPlayer = $BlinkAnimationPlayer
@onready var staff = $Staff
@onready var staff_point_pivot: Marker2D = $Staff/StaffPointPivot
@onready var staff_hold_timer: Timer = $StaffHoldTimer
@onready var staff_reload_timer: Timer = $StaffReloadTimer

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")
const projectile = preload("res://Enemies/fire.tscn")

#false is left, true is right
var facingDirection = false
var player
enum {
	IDLE, 
	CHASE,
	ATTACK,
	RELOAD,
	SHAKE
}

@export var state = IDLE
var knockback = Vector2.ZERO

func _ready():
	player = Global.player
	animationTree.active = true

func _physics_process(delta):
	_set_knockback_velocity(delta)
	
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
			animationState.travel("Raise")
			velocity =  Vector2.ZERO 
			if !enemyAttackRange._playerInRange():
				state = CHASE
		RELOAD:
			animationState.travel("Shoot")
		SHAKE:
			animationState.travel("Shake")
			
	move_and_slide()

func _shoot_projectile():
	Global.camera.shake(0.1,1)
	var projectile_instance = projectile.instantiate()
	projectile_instance.position = staff_point_pivot.global_position
	if player != null: projectile_instance.look_at(player.global_position)
	add_child(projectile_instance)
	
func _staff_hold():
	_start_timer(staff_hold_timer, 0.5)
	state = SHAKE

func _staff_reload():
	_start_timer(staff_reload_timer, 1.5)

func _on_staff_hold_timer_timeout() -> void:
	#_shoot_projectile()
	state = RELOAD

func _on_staff_reload_timer_timeout() -> void:
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

