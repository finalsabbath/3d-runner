extends CharacterBody3D
##
## Simple left/right character controller
##

## Speed of character movement
var speed = 5.0




func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	# We'll ignore up and down input, just using side to side
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()
#
	var collision = get_last_slide_collision()
	if collision:
		var death_blocks = get_tree().get_nodes_in_group("death_block")
		var collider = collision.get_collider()
		print("Collided with: ", collider)
		if collider in death_blocks:
			EventBus.death_block_hit.emit()
			
