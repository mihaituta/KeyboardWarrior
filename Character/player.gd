extends CharacterBody2D

@export var ACCELERATION = 600;
@export var MAX_SPEED = 100;
@export var DASH_SPEED = 400;
@export var FRICTION = 700;
@export var ATTACK_MOVE_DISTANCE = 10;
@export var ATTACK_NUMBER: int = 3;

@export var DASH_LENGTH = 0.2;
@export var DASH_COOLDOWN = 1;
@export var MAX_DASH_COUNTER = 2;
@export var RESPAWN_COOLDOWN = 3;
var CURRENT_DASH_COUNTER

var stats = PlayerStats
enum {MOVE, DASH, ATTACK}
var state = MOVE;

var facing_direction_vector = Vector2.RIGHT;
var input_vector = Vector2.ZERO;

@onready var AttackTimer = $AttackTimer
@onready var DashDurationTimer = $DashDurationTimer
@onready var DashAgainTimer = $DashAgainTimer
@onready var DashCooldownTimer = $DashCooldownTimer
@onready var playerDeathRespawnTimer = $PlayerDeathRespawnTimer

@onready var hurtbox = $Hurtbox
@onready var sprite2D = $Sprite2D;
@onready var animationPlayer = $AnimationPlayer;
@onready var animationTree = $AnimationTree;
@onready var animationState = animationTree.get("parameters/playback");
@onready var blinkAnimationPlayer = $BlinkAnimationPlayer

const DashEffect = preload("res://Effects/DashEffect.tscn")
const PlayerHurtSound = preload("res://Character/PlayerHurtSound.tscn")
const PlayerDeathEffect = preload("res://Effects/PlayerDeathEffect.tscn")

func _ready():
	stats.no_health.connect(_player_death)
	animationTree.active = true;
	CURRENT_DASH_COUNTER = MAX_DASH_COUNTER
	
func _player_death():
	#get_tree().change_scene_to_file("res://World/world.tscn")
	queue_free()
	var playerDeathEffect = PlayerDeathEffect.instantiate()
	get_parent().add_child(playerDeathEffect)
	playerDeathEffect.global_position = global_position
	
func _physics_process(delta):
	match state:
		MOVE: 
			move_state(delta)
		DASH: 
			dash_state()
		ATTACK:
			attack_state(delta)
	
func set_move_input():
	input_vector.x = Input.get_axis("ui_left", "ui_right");
	input_vector.y = Input.get_axis("ui_up", "ui_down");
	input_vector = input_vector.normalized();
	facing_direction_vector = input_vector;
	
func move_state(delta):
	set_move_input()

	if input_vector != Vector2.ZERO:
		animationTree.set("parameters/Run/blend_position", input_vector);
		animationTree.set("parameters/Attack1/blend_position", input_vector.x);
		animationTree.set("parameters/Attack2/blend_position", input_vector.x);
		animationTree.set("parameters/Attack3/blend_position", input_vector.x);
		animationTree.set("parameters/Dash/blend_position", input_vector.x);
		animationState.travel("Run");
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta);
	else:
		animationState.travel("Idle");
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta);

	move_and_slide()

	if Input.is_action_just_pressed("attack"):
		state = ATTACK;
		
	if Input.is_action_just_pressed("dash") and !_is_dashing() and CURRENT_DASH_COUNTER != 0:
		start_dash()

func start_timer(timer, duration):
	timer.wait_time = duration
	timer.start()

func start_dash():
	if(CURRENT_DASH_COUNTER == 2):
		start_timer(DashCooldownTimer, DASH_COOLDOWN)
		start_timer(DashDurationTimer, DASH_LENGTH)
		animationState.travel("Dash");
		create_dash_effect()
	if(Input.is_action_just_pressed("dash") and CURRENT_DASH_COUNTER == 1):
		start_timer(DashCooldownTimer, DASH_COOLDOWN)
		start_timer(DashDurationTimer, DASH_LENGTH)
		animationState.travel("Dash");
		create_dash_effect()
	state = DASH;
	
func _is_dashing():
	return !DashDurationTimer.is_stopped()

func create_dash_effect():
	var effect = DashEffect.instantiate()
	self.add_child(effect)
	effect.scale.x = facing_direction_vector.x;
	effect.global_position = self.global_position

func dash_state():
	velocity = facing_direction_vector * DASH_SPEED;
	move_and_slide();
	
func attack_state(_delta):
	if ATTACK_NUMBER == 3:
		AttackTimer.start()
		animationState.travel("Attack1");
	if Input.is_action_just_pressed("attack") and ATTACK_NUMBER == 2:
		AttackTimer.start()
		animationState.travel("Attack2");
	if Input.is_action_just_pressed("attack") and ATTACK_NUMBER == 1:
		AttackTimer.start()
		animationState.travel("Attack3");
	velocity = facing_direction_vector * ATTACK_MOVE_DISTANCE;
	move_and_slide();
	set_move_input();
	if Input.is_action_just_pressed("dash") and !_is_dashing() and CURRENT_DASH_COUNTER != 0:
		start_dash()

func remove_attack_number():
	ATTACK_NUMBER -= 1

func attack_animation_finished():
	state = MOVE;
	
func dash_animation_finished():
	velocity = facing_direction_vector * MAX_SPEED;
	state = MOVE;

func _on_attack_timer_timeout():
	ATTACK_NUMBER = 3;
	state = MOVE;

func _on_hurtbox_area_entered(area):
	Global.camera.shake(0.2,1)
	stats.health -= area.damage
	hurtbox.start_invincibility(0.5)
	hurtbox.create_hit_effect()
	var playerHurtSound = PlayerHurtSound.instantiate()
	get_parent().add_child(playerHurtSound)

func _on_dash_timer_timeout():
	if(CURRENT_DASH_COUNTER > 0):
		CURRENT_DASH_COUNTER -= 1;

func _on_dash_again_timer_timeout():
	CURRENT_DASH_COUNTER = MAX_DASH_COUNTER
	
func _on_dash_cooldown_timer_timeout():
	CURRENT_DASH_COUNTER = MAX_DASH_COUNTER

func _on_hurtbox_invincibility_started():
	blinkAnimationPlayer.play("Start")

func _on_hurtbox_invincibility_ended():
	blinkAnimationPlayer.play("Stop")
