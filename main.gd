# Main.gd
extends Node

# Получаем ссылки на дочерние узлы с помощью NodePath
@onready var tile_map_layer = $TileMapLayer
@onready var player = $Player
@onready var pathfinding_manager = $PathfindingManager
@onready var path_visualizer = $PathVisualizer

func _ready():
	# Инициализируем PathfindingManager, передавая ему ссылку на TileMapLayer.
	# Это ключевой шаг.
	pathfinding_manager.initialize(tile_map_layer)
		
	print("Main: Все узлы инициализированы и готовы к работе.")
