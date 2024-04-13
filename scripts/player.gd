extends CharacterBody2D

@export var speed = 300;
@export var gravity = 30;
@export var jump_force = 750;
@export var enhancedJumpForce = 500;

@onready var animationPlayer = $AnimationPlayer;
@onready var sprite = $Sprite2D;
@onready var cShape = $CollisionShape2D;
@onready var crouchRaycast1 = $CrouchRaycast1;
@onready var crouchRaycast2 = $CrouchRaycast2;


var horizontalDirection = 1;
var canDoubleJump = true;
var isCrouching = false;
var stuckUnderObject = true;

var standingCShape = preload("res://resources/knight_standing_cshape.tres");
var crouchingCShape = preload("res://resources/knight_crouching_cs.tres");

func _process(delta):
	horizontalDirection = Input.get_axis("move_left", "move_right");
	
	toggleCrouch();

	if horizontalDirection !=  0:
		switchDirection(horizontalDirection);
	
	updateAnimations(horizontalDirection);

func _physics_process(delta):
	if !is_on_floor():
		jump();
	if is_on_floor():
		canDoubleJump = true;
	
	if Input.is_action_just_pressed("jump") && is_on_floor():
		velocity.y = -jump_force;

	velocity.x  = horizontalDirection * speed;

	move_and_slide();

func updateAnimations(horizontalDirection):
	if is_on_floor():
		if horizontalDirection == 0:
			if isCrouching:
				animationPlayer.play("crouch");
			else:
				animationPlayer.play("idle");
		else:
			if isCrouching:
				animationPlayer.play("crouch_walk");
			else:
				animationPlayer.play("run");
	else:
		if !isCrouching:
			if velocity.y < 0:
				animationPlayer.play("jump");
			elif velocity.y > 0:
				animationPlayer.play("fall");
		else:
			animationPlayer.play("crouch");

func switchDirection(horizontalDirection):
	sprite.flip_h = (horizontalDirection == -1);
	sprite.position.x = horizontalDirection * 4;

func jump():
#consider using the `just` variants only
#if the just_released hasn't been triggered, keep going up (with conditions)
	if (!isCrouching):
		if (canDoubleJump && Input.is_action_just_pressed("jump")):
			canDoubleJump = false;
			velocity.y -= enhancedJumpForce;
		elif (velocity.y < 500):
			velocity.y += gravity;

func crouch():
	if !isCrouching:
		isCrouching = true;
		cShape.shape = crouchingCShape;
		cShape.position.y = -12;

func stand():
	if (isCrouching):
		isCrouching = false;
		cShape.shape = standingCShape;
		cShape.position.y = -16;

func isOverheadClear():
	return !crouchRaycast1.is_colliding() && !crouchRaycast2.is_colliding();

func resetStand():
	if (stuckUnderObject && isOverheadClear() && !Input.is_action_pressed("crouch")):
		stand();
		stuckUnderObject = false;

func toggleCrouch():
	if Input.is_action_just_pressed("crouch"):
		crouch();
	if Input.is_action_just_released("crouch"):
		if isOverheadClear():
			stand();
		else:
			if stuckUnderObject == false:
				stuckUnderObject = true;
	resetStand();
