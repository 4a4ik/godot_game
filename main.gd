# Main.gd
extends Node

# Получаем ссылки на дочерние узлы с помощью NodePath
@onready var tile_map_layer = $Map/TileMapLayer
@onready var player = $Map/Player
@onready var pathfinding_manager = $PathfindingManager
@onready var path_visualizer = $PathVisualizer
@onready var Click = $Battle/click
@onready var CanvasLayerrr = $Battle/CanvasLayer
@onready var enemy_portrait = $Battle/CanvasLayer/Panel/EnemyPortrait
@onready var player_portrait = $Battle/CanvasLayer/Panel/PlayerPortrait

# New paths for the health UI in the HUD layer
@onready var player_health_label = $HUD/HealthLabel
@onready var player_health_bar = $HUD/HealthBar

# Dictionary to store entities on the map. Key: Vector2i, Value: Node
var grid_entities: Dictionary = {}

# Called by entities when they spawn to register their position
func register_entity(tile_coords: Vector2i, entity: Node2D):
	grid_entities[tile_coords] = entity
	print("Entity ", entity.name, " registered at ", tile_coords)


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
