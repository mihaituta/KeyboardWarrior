extends CharacterBody2D

@export var ACCELERATION = 600;
@export var MAX_SPEED = 100;
@export var DASH_SPEED = 230;
@export var FRICTION = 700;
@export var ATTACK_MOVE_DISTANCE = 10;
@export var AttackNumber: int = 3;

enum {MOVE, DASH, ATTACK}

var state = MOVE;
var facing_direction_vector = Vector2.RIGHT;
var input_vector = Vector2.ZERO;
var is_attacking = false;

@onready var AttackTimer = $AttackTimer
@onready var sprite2D = $Sprite2D;
@onready var animationPlayer = $AnimationPlayer;
@onready var animationTree = $AnimationTree;
@onready var animationState = animationTree.get("parameters/playback");

func _ready():
	animationTree.active = true;

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
		#facing_direction_vector = input_vector;
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
	if Input.is_action_just_pressed("dash"):
		state = DASH;


func dash_state():
	velocity = facing_direction_vector * DASH_SPEED;
	move_and_slide();
	animationState.travel("Dash");
	
func attack_state(delta):
	if AttackNumber == 3:
		#state = ATTACK;
		AttackTimer.start()
		animationState.travel("Attack1");
	if Input.is_action_just_pressed("attack") and AttackNumber == 2:
		#state = ATTACK;
		AttackTimer.start()
		animationState.travel("Attack2");
	if Input.is_action_just_pressed("attack") and AttackNumber == 1:
		#state = ATTACK;
		AttackTimer.start()
		animationState.travel("Attack3");
	
	velocity = facing_direction_vector * ATTACK_MOVE_DISTANCE;
	
	move_and_slide();
	
	set_move_input();
	
	if Input.is_action_just_pressed("dash"):
		state = DASH;
	#if input_vector != Vector2.ZERO:
	#velocity = velocity.move_toward(Vector2.ZERO * ATTACK_MOVE_DISTANCE, FRICTION/3 * delta);
	#else:
	

func remove_attack_number():
	AttackNumber -= 1

func attack_animation_finished():
	state = MOVE;
	
func dash_animation_finished():
	velocity = facing_direction_vector * MAX_SPEED;
	state = MOVE;

func _on_attack_timer_timeout():
	AttackNumber = 3;
	state = MOVE;
