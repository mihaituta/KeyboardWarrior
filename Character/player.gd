extends CharacterBody2D

@export var ACCELERATION = 600;
@export var MAX_SPEED = 100;
@export var DASH_SPEED = 250;
@export var FRICTION = 700;

enum {MOVE, DASH, ATTACK}

var state = MOVE;
var dash_vector = Vector2.RIGHT;

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
	
func move_state(delta):
	var input_vector = Vector2.ZERO;
	input_vector.x = Input.get_axis("ui_left", "ui_right");
	input_vector.y = Input.get_axis("ui_up", "ui_down");
	input_vector = input_vector.normalized();

	
	if input_vector != Vector2.ZERO:
		dash_vector = input_vector;
		animationTree.set("parameters/Run/blend_position", input_vector);
		animationTree.set("parameters/Attack/blend_position", input_vector.x);
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
	velocity = dash_vector * DASH_SPEED;
	move_and_slide();
	animationState.travel("Dash");
	
func attack_state(delta):
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION/1.5 * delta);
	move_and_slide();
	animationState.travel("Attack");

func attack_animation_finished():
	state = MOVE;
	
func dash_animation_finished():
	velocity = dash_vector * MAX_SPEED;
	state = MOVE;
