extends RigidBody3D

var start_pos
var roll_strength = 10

signal roll_finished(value)

func _ready():
	print("labubu")
	start_pos = global_position

func _process(delta):
	if Input.is_action_just_pressed("right_click"):
		_roll()

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
	while (sleeping == false):
		await get_tree().create_timer(0.1).timeout
	print("aaa")
