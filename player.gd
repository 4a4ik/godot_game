extends Area2D

@export var speed = 30 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.

@onready var nav_agent = $NavigationAgent2D as NavigationAgent2D


@onready var tile_map = $"../TileMapLayer" # our map
var move_delay = 20

var click_position = Vector2()
var clicked_tile_id = Vector2i()
var clicked_tile_gl_pos = Vector2()

var cnt = 0

func _ready():
	screen_size = get_viewport_rect().size
	nav_agent.debug_enabled = true # shows red line for navigation algorithm
	
var target_tile = Vector2i(0,0)
var velocity = Vector2.ZERO # The player's movement vector.

func _process(delta):
	
	#Mouse movement
	if Input.is_action_just_pressed("left_click"):
		click_position = get_global_mouse_position()
		clicked_tile_id = tile_map.local_to_map(click_position)
		clicked_tile_gl_pos = tile_map.map_to_local(clicked_tile_id)
		#print(clicked_tile_id)
	
	nav_agent.target_position = clicked_tile_gl_pos
	#print(nav_agent.target_position)
	
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
		
	#print(velocity)
		
	if velocity.length() > 0:
		#prints(current_tile_id, target_tile)
		
		velocity = velocity.normalized() * speed
		if velocity.x > 0:
			$AnimatedSprite2D.set_animation("going_right")
		elif velocity.x < 0:
			$AnimatedSprite2D.set_animation("going_left")
		elif velocity.y < 0:
			$AnimatedSprite2D.set_animation("going_up")
		else:
			$AnimatedSprite2D.set_animation("goind_down")
		$AnimatedSprite2D.play()
		
	else:
		$AnimatedSprite2D.stop()
		
func _physics_process(delta):
	var next_move_pos = nav_agent.get_next_path_position()
	var move_dir = global_position.direction_to(next_move_pos)
	
		
	var current_tile_id = tile_map.local_to_map(global_position)
	
	target_tile = Vector2i(
		current_tile_id.x + velocity.x,
		current_tile_id.y + velocity.y,
	)

	if cnt < move_delay:
		cnt = cnt + 1
	else:
		#position += velocity # * delta
		global_position = tile_map.map_to_local(target_tile)
		#print(global_position)
		
		global_position = next_move_pos
		cnt = 0
	#position = position.clamp(Vector2.ZERO, screen_size)
	print("current position", global_position)
	print(next_move_pos)
