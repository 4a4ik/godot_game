extends Area2D

@export var speed = 1 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.

var delta = 50

@onready var nav_agent = $NavigationAgent2D as NavigationAgent2D
@onready var path_line_2d = $"../Line2D" # Path to your Line2D node
@onready var finish_line_2d = $"../finish_line2d" # Path to your Line2D node


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
var path_centers_global: Array = [] # Массив центров тайлов на пути

signal path_ready(new_path_array: Array) # Renamed for clarity: path_ready or path_calculated

func _ready():
	# Подключаемся к сигналу о завершении вычисления пути
	nav_agent.path_changed.connect(on_path_changed)
	
	screen_size = get_viewport_rect().size
	#nav_agent.debug_enabled = true # shows red line for navigation algorithm
	global_position = tile_map.map_to_local(Vector2i(4,4))
	

var target_tile = Vector2i(0,0)
var velocity = Vector2.ZERO # The player's movement vector.

# Declare the custom signal
# The argument type (Array[Vector2i]) is optional but good for clarity and type-checking
signal path_updated(new_path_array: Array[Vector2i])

func _process(delta):
	
	#Mouse movement
	if Input.is_action_just_pressed("left_click"):
		click_position = get_global_mouse_position()
		clicked_tile_id = tile_map.local_to_map(click_position)
		clicked_tile_gl_pos = tile_map.map_to_local(clicked_tile_id)
		
		nav_agent.target_position = clicked_tile_gl_pos
		nav_agent.get_next_path_position() # compute path
		
		move_with_keyboard_after_press = false
		move_with_mouse_after_press = true
	
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

	var current_tile_id = tile_map.local_to_map(global_position)
	

	if velocity.length() > 0:
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
	
	var current_tile_id = tile_map.local_to_map(global_position)

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
	
	var tile_data: TileData = tile_map.get_cell_tile_data(target_tile)
	if cnt < move_delay:
		cnt = cnt + 1
	else:
		if (move_with_keyboard_after_press):
			if tile_data.get_custom_data("walkable") == true:
				global_position = tile_map.map_to_local(target_tile)
		elif (move_with_mouse_after_press) and current_path_index < path_centers.size():
			global_position = tile_map.map_to_local(path_centers[current_path_index])
			current_path_index += 1
			nav_agent.get_next_path_position() # compute path
			if current_path_index >= path_centers.size():
				path_centers.clear() # Путь пройден, очищаем
				current_path_index = 0
		
		cnt = 0
		
		
func on_path_changed():
	print("\n on_path_changed()")
	finish_line_2d.clear_points()
	path_centers_global.clear()
	
	print("nav_agent.target_position")
	print(nav_agent.target_position)
	# Эта функция будет вызвана, когда NavigationAgent2D найдет путь
	var path = nav_agent.get_current_navigation_path()
	
	path_line_2d.points = path
	
	print("path")
	print(path)
	var inbetween_tile = Vector2i()
	
	# Очищаем старый путь и формируем новый из центров тайлов
	path_centers.clear()
	current_path_index = 0
	
	var tmpvec2 = Vector2(200,200)

	for p in path:
		var tile_coords = tile_map.local_to_map(p)
		#print(p)
		
		# Добавляем тайла, только если его еще нет в пути
		if path_centers.is_empty():
			path_centers.append(tile_coords)
			print(tile_coords)
		elif path_centers.back() != tile_coords:
			print(tile_coords)
			# fix jump over tiles
			#if (tile_coords - path_centers.back()).length() > 2:
			inbetween_tile = tile_coords
			# if we jump over 2 rows on Y
			if abs(inbetween_tile.y - path_centers.back().y) > 1:
				print("problem with Y coords between last 2 tiles")
				#print(path_centers.back())
				inbetween_tile.y = (inbetween_tile.y + path_centers.back().y) / 2
				print("result")
				print(inbetween_tile)
				
				
			# X jump with the same Y
			if inbetween_tile.y == path_centers.back().y:
				if abs(inbetween_tile.x - path_centers.back().x) > 1:
					inbetween_tile.x = (inbetween_tile.x + path_centers.back().x) / 2
			# different Y
			else:
				# if we on even row
				if inbetween_tile.y % 2 == 1:
					# moving right
					if inbetween_tile.x > path_centers.back().x:
						# on even row, if we go to down right, x not changes
						print("problem with X coord on even tile")
						inbetween_tile.x = path_centers.back().x
				# if we on UNeven row
				elif inbetween_tile.y % 2 == 0:
					# moving left
					if inbetween_tile.x < path_centers.back().x:
						# on even row, if we go to down right, x not changes
						print("problem with X coord on even tile")
						inbetween_tile.x = path_centers.back().x
						
				if abs(inbetween_tile.x - path_centers.back().x) > 1:
					inbetween_tile.x = (inbetween_tile.x + path_centers.back().x) / 2
					
						
			if inbetween_tile != tile_coords:
				path_centers.append(inbetween_tile)
				
			path_centers.append(tile_coords)
			
	print("new path")
	for i in path_centers:
		print(i)
		finish_line_2d.add_point(tile_map.map_to_local(i))
		path_centers_global.append(tile_map.map_to_local(i))

	# Если игрок уже находится на первом тайле пути, пропускаем его
	if not path_centers.is_empty():
		if tile_map.local_to_map(global_position) == path_centers[0]:
			current_path_index = 1 # Начинаем со второй точки, если уже на первой

	# Emit the signal with the path array
	path_ready.emit(path_centers_global)
	print("new data was emitted")
