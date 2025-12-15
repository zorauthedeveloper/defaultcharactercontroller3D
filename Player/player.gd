extends CharacterBody3D
@export var sens : int = 5

@export var walk_speed : int = 5
@export var sprint_speed : int = 10

@export var acceleration : float = 75
@export var deceleration : float = 75

@export_range(0,1,0.1) var character_rotation_smoothing : float = 15

@onready var pivot: Node3D = $CameraOrigin
@onready var camera: Camera3D = $CameraOrigin/SpringArm3D/Camera3D
@onready var character_model: Node3D = $CharacterModel
@onready var avatar: Node3D = $CharacterModel/Avatar

@onready var animation_player: AnimationPlayer = $CharacterModel/Avatar/AnimationPlayer

var speed = 5.0
var direction

var jump_velocity = 6

var sprinting : bool = false
var sprint_key_count : int = 0

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion and !Input.is_action_pressed("move_off"):
		if direction:
			rotation.y -= event.relative.x / 1000 * sens
		else:
			pivot.rotation.y -= event.relative.x / 1000 * sens
		var tempRot = pivot.rotation.x - event.relative.y / 1000 * sens
		tempRot = clamp(tempRot, -1, 0.625)
		pivot.rotation.x = tempRot
	if Input.is_action_pressed("move_off"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	if Input.is_action_just_pressed("sprint"):
		speed = sprint_speed
		sprinting = true
	elif !Input.is_action_pressed("sprint"):
		speed = walk_speed    
		sprinting = false

	var input_dir := Input.get_vector("left", "right", "up", "down")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		var yaw = pivot.rotation.y
		var transfer = Global.smooth_exp_angle(0.0, yaw, character_rotation_smoothing, delta)
		rotation.y += transfer
		pivot.rotation.y -= transfer
		character_model.rotation.y = Global.smooth_exp_angle(character_model.rotation.y, atan2(input_dir.x, input_dir.y), character_rotation_smoothing, delta)
		velocity.x = move_toward(velocity.x, direction.x * speed, acceleration * delta)
		velocity.z = move_toward(velocity.z, direction.z * speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)
		velocity.z = move_toward(velocity.z, 0, deceleration * delta)
		sprint_key_count = 0
	
	move_and_slide()


func _on_area_3d_body_entered(body: Node3D) -> void:
	# For standing on RigidBody3D's
	if body is RigidBody3D:
		body.collision_layer = 3
		body.collision_mask = 3


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is RigidBody3D:
		body.collision_layer = 2
		body.collision_mask = 3
