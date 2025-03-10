extends CharacterBody3D
##
## Simple left/right character controller
##

## Speed of character movement
var speed = 5.0
@onready var world_environment: WorldEnvironment = $"../WorldEnvironment"
@onready var music: AudioStreamPlayer = $"../Music"
@onready var pulse_audio: AudioStreamPlayer3D = $"../Pulse"


var pulse: float = 0.0
var pulse_up: bool = true

func _physics_process(delta: float) -> void:
	
	_pulse(delta)

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
			get_tree().quit()

func _pulse(delta: float) -> void:
	world_environment.environment.background_energy_multiplier = pulse
	if pulse_up: 
		pulse +=(GameStats.terrain_velocity * delta) * delta
	else: 
		pulse -= (GameStats.terrain_velocity * delta) * delta
	
	if pulse > 2:
		pulse_up = false
		pulse_audio.play()
	elif pulse < 1:
		pulse_up = true


func _on_timer_timeout() -> void:
	pass
