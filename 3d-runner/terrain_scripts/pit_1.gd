extends Node3D

@onready var mesh: MeshInstance3D = %Mesh
@onready var collision: CollisionShape3D = %Collision

var block_details: Dictionary

func _ready() -> void:
	pass
	
func get_block_details() -> Dictionary:
	if not ready:
		await ready
	block_details["mesh_y"] = mesh.mesh.size.y/2
	
	return block_details
