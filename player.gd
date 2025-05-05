extends Area2D

@export var speed = 30 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.

@onready var tile_map = $"../TileMapLayer" # our map
var move_delay = 50

var click_position = Vector2()
var clicked_tile_id = Vector2i()

var cnt = 0

func _ready():
	screen_size = get_viewport_rect().size
	
func _process(delta):
	
	#Mouse movement
	if Input.is_action_just_pressed("left_click"):
		click_position = get_global_mouse_position()
		clicked_tile_id = tile_map.local_to_map(click_position)
		print(clicked_tile_id)
	
	
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
		
	#print(velocity)
		
		
	var current_tile_id = tile_map.local_to_map(global_position)
	
	var target_tile = Vector2i(
		current_tile_id.x + velocity.x,
		current_tile_id.y + velocity.y,
	)
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
	
	var tile_data: TileData = tile_map.get_cell_tile_data(target_tile)
	if cnt < move_delay:
		cnt = cnt + 1
	elif tile_data.get_custom_data("walkable") == true:
		#position += velocity # * delta
		global_position = tile_map.map_to_local(target_tile)
		print(tile_map.get_cell_atlas_coords(current_tile_id))
		cnt = 0
	#position = position.clamp(Vector2.ZERO, screen_size)
