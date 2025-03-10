extends CharacterBody3D

@export var speed = 5.0
@export var fall_acceleration = 75
@export var jump_impulse = 20

var target_velocity = Vector3.ZERO

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
	
	velocity = target_velocity
	move_and_slide()
#
	var collision = get_last_slide_collision()
	if collision:
		var death_blocks = get_tree().get_nodes_in_group("death_block")
		var collider = collision.get_collider()
		if collider in death_blocks:
			EventBus.death_block_hit.emit()
			
