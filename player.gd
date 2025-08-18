extends Area2D

var delta = 50

@onready var main_node = get_parent() # Получаем ссылку на родительский узел (Main)

var move_delay = 20

var click_position = Vector2()
var clicked_tile_id = Vector2i()
var clicked_tile_gl_pos = Vector2()
var move_with_mouse_after_press = false
var move_with_keyboard_after_press = false

var path: Array = []
var global_path: Array = []

var cnt = 0

var current_path_index = 0
var path_centers: Array = [] # Массив центров тайлов на пути
var path_centers_global: Array = [] # Массив центров тайлов на пути

#signal path_ready(new_path_array: Array) # Renamed for clarity: path_ready or path_calculated

func _ready():
	global_position = Vector2i(144, 112)


var target_tile = Vector2i(0,0)
var velocity = Vector2.ZERO # The player's movement vector.


func _process(delta):
	
	#Mouse movement
	if Input.is_action_just_pressed("left_click"):
		click_position = get_global_mouse_position()
		clicked_tile_id = main_node.tile_map_layer.local_to_map(click_position)
		clicked_tile_gl_pos = main_node.tile_map_layer.map_to_local(clicked_tile_id)
		
		# Запрашиваем путь у PathfindingManager, который находится в Main.
		var start_tile_coords = main_node.tile_map_layer.local_to_map(global_position)
		path = main_node.pathfinding_manager.get_coordinates_path(start_tile_coords, clicked_tile_id)

		
		if not path.is_empty():
			print("Найден новый путь!")
			print(path)
			main_node.path_visualizer.update_path_display(path)
		
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

	var current_tile_id = main_node.tile_map_layer.local_to_map(global_position)
	

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
	
	var current_tile_id = main_node.tile_map_layer.local_to_map(global_position)

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
	
	var tile_data: TileData = main_node.tile_map_layer.get_cell_tile_data(target_tile)
	if cnt < move_delay:
		cnt = cnt + 1
	else:
		if (move_with_keyboard_after_press):
			if tile_data.get_custom_data("walkable") == true:
				global_position = main_node.tile_map_layer.map_to_local(target_tile)
		elif (move_with_mouse_after_press) and not path.is_empty():
			# Перемещаем игрока в центр следующего тайла
			global_position = path[0]
				
			# Удаляем первый элемент из массива
			path.pop_front()
			if path.is_empty():
				move_with_mouse_after_press = false
		
		cnt = 0
		

		
