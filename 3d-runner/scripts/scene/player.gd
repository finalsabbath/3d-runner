extends CharacterBody3D

@export var fall_acceleration = 75
@export var jump_impulse = 20
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var camera_3d: Camera3D = $Camera3D

var target_velocity = Vector3.ZERO
var sliding: bool = false

func _physics_process(delta: float) -> void:
	if not ready:
		await ready
	var input_dir := Input.get_vector("move_left", "move_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		target_velocity.x = direction.x * GameState.player_speed
	else:
		target_velocity.x = move_toward(target_velocity.x, 0, GameState.player_speed)

	if not is_on_floor():
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		target_velocity.y = jump_impulse
	
	velocity = target_velocity
	move_and_slide()
#	
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if collision:
			var death_blocks = get_tree().get_nodes_in_group("death_block")
			var collider = collision.get_collider()
			if collider in death_blocks:
				EventBus.run_end.emit("Hit a block")
	
	#check fall death
	if position.y < -10:
		EventBus.run_end.emit("Fell down a hole")
