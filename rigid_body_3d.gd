extends RigidBody3D

@onready var raycasts = $Raycasts.get_children() 

var start_pos
var roll_strength = 10

signal roll_finished(value)

@onready var object_scene = $Battle/SubViewport

func spawn(position: Vector3):
	print("HELOU")
	var instance = object_scene.instantiate()
	add_child(instance)
	instance.global_position = position

func _ready():
	print("labubu")
	start_pos = global_position

func _process(delta):
	if Input.is_action_just_pressed("e"):
		print("PRRRIVET")
		spawn(Vector3(0, 5, 0))
	if Input.is_action_just_pressed("right_click"):
		_roll()
		
var _was_sleeping = false

func _physics_process(_delta):
	if sleeping != _was_sleeping:
		_was_sleeping = sleeping
		if !_was_sleeping:
			_on_sleeping_state_changed()
		
func _roll():
	# Reset state
	sleeping = false
	freeze = false
	transform.origin = start_pos
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO

	# Random rotation
	transform.basis = Basis(Vector3.RIGHT, randf_range(0, 2 * PI)) * transform.basis
	transform.basis = Basis(Vector3.UP, randf_range(0, 2 * PI)) * transform.basis
	transform.basis = Basis(Vector3.FORWARD, randf_range(0, 2 * PI)) * transform.basis

	# Random throw impulse
	var throw_vector = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
	angular_velocity = throw_vector * roll_strength / 2
	apply_central_impulse(throw_vector * roll_strength)
	#while (sleeping == false):
	#	await get_tree().create_timer(0.1).timeout

func _on_sleeping_state_changed():
	# не выводит когда меняется на false
	print("Stan się zmienił! Aktualnie is_sleeping: ", sleeping)
	var selected_value = null
	if sleeping:
		for raycast in raycasts:
			if raycast.is_colliding():
				if selected_value == null:
					selected_value = raycast.opposite_side
				else:
					_roll()
					return
		roll_finished.emit(selected_value)
