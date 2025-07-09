extends Area2D

@export var speed = 1 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.

var delta = 50

@onready var nav_agent = $NavigationAgent2D as NavigationAgent2D



@onready var tile_map = $"../TileMapLayer" # our map
var move_delay = 20

var click_position = Vector2()
var clicked_tile_id = Vector2i()
var clicked_tile_gl_pos = Vector2()
var move_with_mouse_after_press = false
var move_with_keyboard_after_press = false

var cnt = 0

var current_path_index = 0
var path_centers: Array = [] # Массив центров тайлов на пути

func _ready():
	# Подключаемся к сигналу о завершении вычисления пути
	nav_agent.path_changed.connect(on_path_changed)
	
	
	screen_size = get_viewport_rect().size
	nav_agent.debug_enabled = true # shows red line for navigation algorithm
	global_position = tile_map.map_to_local(Vector2i(4,4))

var target_tile = Vector2i(0,0)
var velocity = Vector2.ZERO # The player's movement vector.

func _process(delta):
	
	#Mouse movement
	if Input.is_action_just_pressed("left_click"):
		click_position = get_global_mouse_position()
		clicked_tile_id = tile_map.local_to_map(click_position)
		clicked_tile_gl_pos = tile_map.map_to_local(clicked_tile_id)
		#print("nav_agent.distance_to_target() before")
		#print(nav_agent.distance_to_target())
		#
		#print("nav_agent.get_current_navigation_path()")
		#print(nav_agent.get_current_navigation_path())
		
		nav_agent.target_position = clicked_tile_gl_pos
		nav_agent.get_next_path_position() # compute path
		
		#print("nav_agent.distance_to_target() before")
		#print(nav_agent.distance_to_target())
		move_with_keyboard_after_press = false
		move_with_mouse_after_press = true
			#print(clicked_tile_id)
	
	#print("\n nav_agent.target_position:")
	#print(nav_agent.target_position)
	
	velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
		
	if (velocity.length() != 0):	# no button is pressed
		move_with_keyboard_after_press = true
		move_with_mouse_after_press = false
		

	# print(velocity)
		
		
	var current_tile_id = tile_map.local_to_map(global_position)
	

	if velocity.length() > 0:
		# prints(current_tile_id, target_tile)
		
		#velocity = velocity.normalized() * speed
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
		
var debug_counter = 0		
var debug_delay = 200

func _physics_process(delta):
	
	debug_counter += 1
	
	#var next_move_pos = nav_agent.get_next_path_position()
	#var move_dir = global_position.direction_to(next_move_pos)
	#var move_angle = move_dir.angle()
	#
	#
	#var next_clicked_move_tile_id = tile_map.local_to_map(next_move_pos)
	
	#if debug_counter % debug_delay == 0:
		#print("\n next_move_pos")
		#print(next_move_pos)
		#
		#print("\n next_clicked_move_tile_id")
		#print(next_clicked_move_tile_id)
	#
		#print("\n move_angle")
		#print(move_angle)
		
		#global_position = tile_map.map_to_local(next_clicked_move_tile_id)
	
	
	
	var current_tile_id = tile_map.local_to_map(global_position)
	
	#print("\ncurrent_tile_id")
	#print(current_tile_id)
#
	#print("\velocity")
	#print(velocity)

		# Если y чётный, то направо x не менять, если y нечётный, то налево x не менять
	var xChange
	if ((current_tile_id.y % 2 == 0 and velocity.x <= 0 or current_tile_id.y % 2 != 0 and velocity.x >= 0) or velocity.y == 0):
		xChange = current_tile_id.x + velocity.x
	else:
		xChange = current_tile_id.x
	
	var target_tile = Vector2i(
		xChange,
		current_tile_id.y + velocity.y,
	)
	#print("\ntarget_tile")
	#print(target_tile)
	
	var tile_data: TileData = tile_map.get_cell_tile_data(target_tile)
	#print("\ntile_data:")
	#print(tile_data)
	if cnt < move_delay:
		cnt = cnt + 1
	else:
		if (move_with_keyboard_after_press):
			if tile_data.get_custom_data("walkable") == true:
				global_position = tile_map.map_to_local(target_tile)
		#print(current_tile_id)
		#elif (next_move_pos != Vector2(0,0)): # check that we are moving with mouse
			#global_position = tile_map.map_to_local(next_move_pos)
		elif (move_with_mouse_after_press) and !path_centers.is_empty():
			global_position = tile_map.map_to_local(path_centers[current_path_index])
			current_path_index += 1
			if current_path_index >= path_centers.size():
				path_centers.clear() # Путь пройден, очищаем
				current_path_index = 0
		
		cnt = 0
	#position = position.clamp(Vector2.ZERO, screen_size)
	# print("current position", global_position)
	# print(next_move_pos)
	
	#if debug_counter % debug_delay == 0:
		#print("\n current_path_index:")
		#print(current_path_index)
		#print("\n path_centers.size():")
		#print(path_centers.size())
		#print("\n end of process")

func on_path_changed():
	print("on_path_changed()")
	# Эта функция будет вызвана, когда NavigationAgent2D найдет путь
	var path = nav_agent.get_current_navigation_path()
	var inbetween_tile = Vector2i()
	
	# Очищаем старый путь и формируем новый из центров тайлов
	path_centers.clear()
	current_path_index = 0

	for p in path:
		var tile_coords = tile_map.local_to_map(p)
		
		# Добавляем тайла, только если его еще нет в пути
		if path_centers.is_empty():
			path_centers.append(tile_coords)
		elif path_centers.back()  != tile_coords:
			# fix jump over tiles
			#for i in range(5):
			if (tile_coords - path_centers.back()).length() > 2:
				print("problem between tiles")
				print(tile_coords)
				print(path_centers.back())
				inbetween_tile = tile_coords
				if abs(tile_coords.x - path_centers.back().x) > 1:
					# get tile coordinates in between
					inbetween_tile.x = (tile_coords.x + path_centers.back().x) / 2
				if abs(tile_coords.y - path_centers.back().y) > 1:
					# get tile coordinates in between
					inbetween_tile.y = (tile_coords.y + path_centers.back().y) / 2
				path_centers.append(inbetween_tile)
				print("result")
				print(inbetween_tile)
			
			path_centers.append(tile_coords)
			
	print("new path")
	for i in path_centers:
		print(i)

	# Если игрок уже находится на первом тайле пути, пропускаем его
	if not path_centers.is_empty():
		var player_tile_coords = tile_map.local_to_map(global_position)
		if player_tile_coords == path_centers[0]:
			current_path_index = 1 # Начинаем со второй точки, если уже на первой
