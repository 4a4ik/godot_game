extends RayCast3D

@export var opposite_side: int

func _ready():
	var body: RigidBody3D = get_parent().get_parent()
	add_exception(body)
