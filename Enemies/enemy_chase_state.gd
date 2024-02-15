class_name EnemyChaseState
extends State

@export var actor: EnemyKey
@export var animator: AnimatedSprite2D

func _ready():
	set_physics_process(false)

func _enter_state() -> void:
	set_physics_process(true);
	animator.play("Run");
	#if actor.velocity == Vector2.ZERO;
		#actor.velocity = Vector2.

func _exit_state() -> void:
	set_physics_process(false)
	
func _physics_process(delta) -> void:
	var direction = Vector2.ZERO.direction_to(actor.get_local_mouse_position())
	actor.velocity = actor.velocity.move_toward(direction * actor.MAX_SPEED, actor.ACCELERATION * delta)
	actor.move_and_slide()
