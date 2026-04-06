extends Node

@export var dice_scene: PackedScene

func spawn():
	var instance = dice_scene.instantiate()
	add_child(instance)  # просто add_child, мы уже внутри SubViewport
	instance.global_position = Vector3(0, 5, 0)
