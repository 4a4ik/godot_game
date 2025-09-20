# Main.gd
extends Node

# Получаем ссылки на дочерние узлы с помощью NodePath
@onready var tile_map_layer = $Map/TileMapLayer
@onready var player = $Map/Player
@onready var pathfinding_manager = $PathfindingManager
@onready var path_visualizer = $PathVisualizer
@onready var Click = $Battle/click
@onready var CanvasLayerrr = $Battle/CanvasLayer

func _ready():
	Click.visible = true
	CanvasLayerrr.visible = true

	# Инициализируем PathfindingManager, передавая ему ссылку на TileMapLayer.
	# Это ключевой шаг.
	pathfinding_manager.initialize(tile_map_layer)
		
	print("Main: Все узлы инициализированы и готовы к работе.")


func _process(delta):
	if Input.is_action_just_pressed("whitespace"):
		if Click.visible:
			Click.visible = false
			CanvasLayerrr.visible = false
		else: 
			Click.visible = true
			CanvasLayerrr.visible = true
