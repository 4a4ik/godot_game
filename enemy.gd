extends Node2D

@onready var tile_map = $"../TileMapLayer" # our map

func _ready():
	global_position = tile_map.map_to_local(Vector2i(11,18))
