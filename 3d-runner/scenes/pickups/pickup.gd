extends Node3D

@export var value: float = .5

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.has_method("process_pickup"):
		body.process_pickup(value)
		queue_free()
		
func _physics_process(delta: float) -> void:
	self.rotation.y +=2 *delta
