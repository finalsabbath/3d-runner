extends Node3D
class_name TerrainController

# Terrain gen constants
const TERRAIN_LENGTH: float = 16.0
const TERRAIN_WIDTH: float = 16.0
const VELOCITY_MULT: int = 10
const STARTER_BLOCKS: int = 1
const MAX_OBSTACLES: int = 5
const BARRIER_LIMIT: int = 2

const PICKUP = preload("res://scenes/prefabs/pickup.tscn")

var count_starter_blocks = 0
var terrain_belt: Array[Node3D] = []
var last_obstacle

@export var num_terrain_blocks = 4

func _ready() -> void:
	_init_blocks(num_terrain_blocks)

func _physics_process(delta: float) -> void:
	if not ready:
		await ready
	_progress_terrain(delta)
	GameState.distance += GameState.terrain_velocity * delta
	GameState.terrain_velocity += (delta*delta) * VELOCITY_MULT

func _init_blocks(number_of_blocks: int) -> void:
	for block_index in number_of_blocks:
		var block = GameState.terrainBlocks.pick_random().instantiate()
		
		if block_index == 0:
			block.position.z = TERRAIN_LENGTH/2
		else:
			if count_starter_blocks >= STARTER_BLOCKS:
				_append_to_far_edge(terrain_belt[block_index-1], block,true)
			else:
				count_starter_blocks +=1
				_append_to_far_edge(terrain_belt[block_index-1], block,false)
		
		terrain_belt.append(block)
		add_child(block)

func _progress_terrain(delta: float) -> void:
	for block in terrain_belt:
		block.position.z += GameState.terrain_velocity * delta

	if terrain_belt[0].position.z >= TERRAIN_LENGTH:
		var last_terrain = terrain_belt[-1]
		var first_terrain = terrain_belt.pop_front()

		var block = GameState.terrainBlocks.pick_random().instantiate()
		_append_to_far_edge(last_terrain, block,true)
		add_child(block)
		terrain_belt.append(block)
		first_terrain.queue_free()

func _append_to_far_edge(target_block: Node3D, appending_block: Node3D, add_obstacles: bool) -> void:
	appending_block.position.z = (target_block.position.z) - TERRAIN_LENGTH
	if add_obstacles:
		_add_obstacles(appending_block)

func _add_obstacles(block: Node3D) -> void:
	var barrier_count: int = 0
	var num_obstacles = GameState.current_level + 1
	if num_obstacles > MAX_OBSTACLES:
		num_obstacles = MAX_OBSTACLES
	if !GameState.debug_enabled:
		_add_pits(block,num_obstacles)
		for i in range(num_obstacles):
			var selected_obstacle = GameState.obstacles.pick_random()
			
			# Try not to make later levels impossible
			if "barrier" in selected_obstacle.resource_path:
				barrier_count +=1
				if last_obstacle:
					if barrier_count > BARRIER_LIMIT or "barrier" in last_obstacle.resource_path:
						selected_obstacle = GameState.obstacles_no_barrier.pick_random()
			last_obstacle = selected_obstacle
			
			var new_obstacle = selected_obstacle.instantiate()
			new_obstacle.position.x = _get_obstacle_position(new_obstacle.type)
			var separation: float = TERRAIN_LENGTH/num_obstacles/2
			new_obstacle.position.z -= (i+1) * separation
			#_spawn_pickup(new_obstacle.position)
			new_obstacle.add_to_group("death_blocks")
			block.add_child(new_obstacle)
			
	
func _add_pits(block: Node3D,num_obstacles: int) -> void:
	for i in range(num_obstacles):
		var remove = randi_range(0,15)
		var remove_panel = block.get_children()[remove]
		var pickup_pos = remove_panel.position
		pickup_pos.y += 2
		_spawn_pickup(pickup_pos, block)
		remove_panel.queue_free()
		
func _spawn_pickup(pos: Vector3,block: Node3D) -> void:
	var new_pickup = PICKUP.instantiate()
	new_pickup.position = pos
	block.add_child(new_pickup)

func _get_obstacle_position(type) -> float:
	var pos_x: float = 0
	var options: Array = []
	match type:
		Enums.ObstacleType.BARRIER:
			options.append(4)
			options.append(-4)
			options.append(0)
			pos_x = options[randi() % options.size()]
		Enums.ObstacleType.BOX:
			pos_x = randf_range((-TERRAIN_WIDTH/2)+1,(TERRAIN_WIDTH/2)-1)
		
	return pos_x
