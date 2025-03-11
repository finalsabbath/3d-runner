extends CharacterBody3D

const SLIDE_SCALE: float = 0.5

@export var speed = 5.0
@export var fall_acceleration = 75
@export var jump_impulse = 20
@onready var slide_timer: Timer = $Slide
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var camera_3d: Camera3D = $Camera3D

var slide_scale = Vector3(SLIDE_SCALE,SLIDE_SCALE,SLIDE_SCALE)

var target_velocity = Vector3.ZERO
var sliding: bool = false

func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "ui_up", "ui_down")
	# We'll ignore up and down input, just using side to side
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		target_velocity.x = direction.x * speed
	else:
		target_velocity.x = move_toward(target_velocity.x, 0, speed)

	# Vertical Velocity
	if not is_on_floor(): # If in the air, fall towards the floor. Literally gravity
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)
	# Jumping.
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		target_velocity.y = jump_impulse
	
	#this is bad, if its going to stay make it better
	if is_on_floor() and Input.is_action_just_pressed("slide") and !sliding:
		sliding = true
		collision_shape_3d.scale = slide_scale
		camera_3d.position.y = camera_3d.position.y/2
		slide_timer.start()
		
	if sliding:
		target_velocity.x = 0
	velocity = target_velocity
	move_and_slide()
#	
	#Check collision death
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if collision:
			var death_blocks = get_tree().get_nodes_in_group("death_block")
			var collider = collision.get_collider()
			if collider in death_blocks:
				EventBus.death_block_hit.emit()
	
	#check fall death
	if position.y < -10:
		EventBus.death_block_hit.emit()

func _on_slide_timeout() -> void:
	sliding = false
	collision_shape_3d.scale = Vector3(1,1,1)
	camera_3d.position.y = camera_3d.position.y*2
