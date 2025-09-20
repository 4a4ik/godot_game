# PathfindingManager.gd
extends Node
class_name PathfindingManager

# Используем AStar2D вместо AStarGrid2D
var astar_service: AStar2D = AStar2D.new()
var tile_map_layer: TileMapLayer

# in main.gd _ready pathfinding_manager.initialize(tile_map_layer)
func initialize(tilemap_node: TileMapLayer):
	self.tile_map_layer = tilemap_node
	_populate_astar_service()
	print("PathfindingManager готов к работе.")

func _populate_astar_service():
	var map_rect = tile_map_layer.get_used_rect()
	print("entered _populate_astar_service")

	# Шаг 1: Добавляем все проходимые точки в AStar2D
	for x in range(map_rect.position.x, map_rect.end.x):
		for y in range(map_rect.position.y, map_rect.end.y):
			var tile_coords = Vector2i(x, y)
			var tile_data = tile_map_layer.get_cell_tile_data(tile_coords)
			
			if tile_data and tile_data.get_custom_data("walkable") == true:
				# Используем координаты тайла как уникальный ID точки
				# Используем координаты тайла как позицию точки
				# Вес по умолчанию 1.0
				astar_service.add_point(hash(tile_coords), tile_coords, 1.0)

	# Шаг 2: Соединяем соседние проходимые точки
	for x in range(map_rect.position.x, map_rect.end.x):
		for y in range(map_rect.position.y, map_rect.end.y):
			var current_tile = Vector2i(x, y)
			var current_id = hash(current_tile)
			
			# Проверяем, существует ли текущая точка в astar_service
			if astar_service.has_point(current_id):
				var neighbors = get_hex_neighbors(current_tile)
				for neighbor_tile in neighbors:
					var neighbor_id = hash(neighbor_tile)
					# Если сосед тоже существует, соединяем их
					if astar_service.has_point(neighbor_id):
						astar_service.connect_points(current_id, neighbor_id)
						

func get_hex_neighbors(tile_coords: Vector2i) -> Array[Vector2i]:
	var neighbors = []
	var x = tile_coords.x
	var y = tile_coords.y
	
	if y % 2 != 0:
		neighbors.append(Vector2i(x, y - 1))
		neighbors.append(Vector2i(x + 1, y - 1))
		neighbors.append(Vector2i(x - 1, y))
		neighbors.append(Vector2i(x + 1, y))
		neighbors.append(Vector2i(x, y + 1))
		neighbors.append(Vector2i(x + 1, y + 1))
	else:
		neighbors.append(Vector2i(x - 1, y - 1))
		neighbors.append(Vector2i(x, y - 1))
		neighbors.append(Vector2i(x - 1, y))
		neighbors.append(Vector2i(x + 1, y))
		neighbors.append(Vector2i(x - 1, y + 1))
		neighbors.append(Vector2i(x, y + 1))
	
	var map_rect = tile_map_layer.get_used_rect()
	var valid_neighbors: Array[Vector2i] = []
	for neighbor in neighbors:
		if map_rect.has_point(neighbor):
			valid_neighbors.append(neighbor)
	
	return valid_neighbors

func get_coordinates_path(start_tile: Vector2i, end_tile: Vector2i):
	print("entered get_hex_path")
	var start_id = hash(start_tile)
	var end_id = hash(end_tile)
	
	print("start_id")
	print(start_id)
	print("end_id")
	print(end_id)
	
	if not astar_service.has_point(start_id) or not astar_service.has_point(end_id):
		print("Ошибка: Начальный или конечный тайл непроходим.")
		return []

	# Get the path as an array of IDs (which are Vector2is in your case)
	var path_ids: Array = astar_service.get_id_path(start_id, end_id)
	# remove first element, bebcause we are standing on it
	path_ids.pop_front()
	print("path_ids")
	print(path_ids)
	
	# Create a new array with the correct type
	# Это нужно, чтобы избежать ошибки "Trying to return an array of type Array where expected return type is Array[Vector2i]".
	var tile_path: Array[Vector2i] = []
	
	# Iterate through the returned IDs and add them to the new array
	# Для каждого ID в пути, получаем его позицию (координаты тайла)
	for id in path_ids:
		var tile_coords: Vector2i = astar_service.get_point_position(id)
		tile_path.append(tile_coords)
		
# tile_map - это ваша переменная, которая ссылается на узел TileMap.
# path - это массив с координатами тайлов, которые вы получили.

	var coordinates_path: Array[Vector2] = []
	for tile_coords in tile_path:
		# map_to_local() преобразует координаты тайла (Vector2i)
		# в локальную позицию (Vector2) в мире.
		var global_pos = tile_map_layer.map_to_local(tile_coords)
		coordinates_path.append(global_pos)

		# Теперь массив 'global_positions' содержит мировые координаты
		# центров тайлов, по которым должен двигаться игрок.
		
	return coordinates_path
