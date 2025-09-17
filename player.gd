extends CharacterBody3D

const JUMP_VELOCITY := 4.5

@export var walk_speed := 2.5
@export var run_speed := 5.0
@export var mouse_sensitivity := 0.002

var yaw := 0.0
var pitch := 0.0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var target_speed := 0.0
var blend_speed := 0.0
var is_running := false

@onready var head = $Head
@onready var anim_player = $PlayerModel/AnimationPlayer
@onready var anim_tree = $PlayerModel/AnimationTree

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	target_speed = walk_speed
	anim_tree.active = true
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * mouse_sensitivity
		pitch += event.relative.y * mouse_sensitivity
		
		pitch = clamp(pitch, deg_to_rad(-30), deg_to_rad(50))
		
		rotation.y = yaw
		#head.rotation.x = pitch
		
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	#if Input.is_action_just_pressed("Jump") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
	if Input.is_action_just_pressed("Sprint"):
		is_running = true
	
	if Input.is_action_just_released("Sprint"):
		is_running = false
	
	
	var input_dir = Input.get_vector("Right", "Left", "Back", "Forward")
	if input_dir == Vector2.ZERO:
		target_speed = 0.0
		is_running = false
	else:
		if is_running:
			target_speed = run_speed
		else:
			target_speed = walk_speed
	
	blend_speed = move_toward(blend_speed, target_speed, 3.0 * delta)
	print(blend_speed)
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * blend_speed
		velocity.z = direction.z * blend_speed
	else:
		velocity.x = move_toward(velocity.x, 0, blend_speed)
		velocity.z = move_toward(velocity.z, 0, blend_speed)
		
	move_and_slide()
	var speed = velocity.length()
	anim_tree.set("parameters/blend_position", speed)
