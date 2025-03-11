extends Node3D
class_name TerrainController

const TERRAIN_LENGTH: int = 16
const TERRAIN_WIDTH: int = 16
const VELOCITY_MULT: int = 10
const MAX_OBSTACLES: int = 3
const MAX_PITS: int = 3
const STARTER_BLOCKS: int = 1

var count_starter_blocks = 0

## Holds the catalog of loaded terrian block scenes
var TerrainBlocks: Array = []
var Obstacles: Array = []
## The set of terrian blocks which are currently rendered to viewport
var terrain_belt: Array[Node3D] = []
## The number of blocks to keep rendered to the viewport
@export var num_terrain_blocks = 16
## Path to directory holding the terrain block scenes
@export_dir var terrian_blocks_path = "res://terrain_blocks"
@export_dir var obstacles_path = "res://obstacles"


func _ready() -> void:
	_load_terrain_scenes(terrian_blocks_path)
	_load_obstacles_scenes(obstacles_path)
	_init_blocks(num_terrain_blocks)

func _physics_process(delta: float) -> void:
	_progress_terrain(delta)
	GameStats.distance += GameStats.terrain_velocity * delta
	GameStats.terrain_velocity += (delta*delta) * VELOCITY_MULT

func _init_blocks(number_of_blocks: int) -> void:
	for block_index in number_of_blocks:
		var block = TerrainBlocks.pick_random().instantiate()
		
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
		block.position.z += GameStats.terrain_velocity * delta

	if terrain_belt[0].position.z >= TERRAIN_LENGTH:
		var last_terrain = terrain_belt[-1]
		var first_terrain = terrain_belt.pop_front()

		var block = TerrainBlocks.pick_random().instantiate()
		_append_to_far_edge(last_terrain, block,true)
		add_child(block)
		terrain_belt.append(block)
		first_terrain.queue_free()

func _append_to_far_edge(target_block: Node3D, appending_block: Node3D, add_obstacles: bool) -> void:
	appending_block.position.z = (target_block.position.z) - TERRAIN_LENGTH
	if add_obstacles:
		_add_obstacles(appending_block)

func _add_obstacles(block: Node3D) -> void:
	_add_pits(block)
	for i in range(MAX_OBSTACLES):
		var new_obstacle = Obstacles.pick_random().instantiate()
		new_obstacle.position.x = _get_obstacle_position(new_obstacle.type)
		new_obstacle.position.z += i * 4
		new_obstacle.add_to_group("death_blocks")
		block.add_child(new_obstacle)
	

func _add_pits(block: Node3D) -> void:
	for i in range(MAX_PITS):
		var remove = randi_range(0,15)
		var panels = block.get_children()
		panels[remove].queue_free()

func _load_terrain_scenes(target_path: String) -> void:
	var dir = DirAccess.open(target_path)
	for scene_path in dir.get_files():
		print("Loading terrian block scene: " + target_path + "/" + scene_path)
		TerrainBlocks.append(load(target_path + "/" + scene_path))

func _load_obstacles_scenes(target_path: String) -> void:
	var dir = DirAccess.open(target_path)
	for scene_path in dir.get_files():
		print("Loading obstacle scene: " + target_path + "/" + scene_path)
		Obstacles.append(load(target_path + "/" + scene_path))
		
func _get_obstacle_position(type) -> float:
	var pos_x: float = 0
	var options: Array = []
	match type:
		Enums.ObstacleType.BARRIER:
			options.append(4)
			options.append(-4)
			pos_x = options[randi() % options.size()]
		Enums.ObstacleType.BOX:
			pos_x = randf_range(-TERRAIN_WIDTH/2,TERRAIN_WIDTH/2)
		
	return pos_x
