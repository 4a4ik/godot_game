extends Node2D

class_name BaseEnemy

@onready var tile_map = $"../TileMapLayer" # our map

# Exported variables for setting up different enemies in the inspector
@export var enemy_name: String = "Base Enemy"
@export var max_health: int = 10
@export var dice_count: int = 1

# Variable to store the enemy's portrait for the combat screen
@export var combat_portrait: Texture2D

@onready var main_node = get_parent().get_parent()

var current_health: int
var grid_position: Vector2i



func _ready():
	current_health = max_health
	
	# Get the initial grid position based on the node's placement in the editor
	grid_position = tile_map.local_to_map(global_position)
	
	# Snap the visual position to the center of the tile
	global_position = tile_map.map_to_local(grid_position)
	
	# Add to group for collision/interaction checks
	add_to_group("enemies")
	
	# Register the enemy in the main grid dictionary
	main_node.register_entity(grid_position, self)
