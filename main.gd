# Main.gd
extends Node

@onready var player_node = $Player # Adjust path as needed
@onready var path_visualizer = $PathVisualizer # Adjust path as needed

func _ready():
	if player_node:
		# Connect the player's path_ready signal to the visualizer's update_path_display function
		player_node.path_ready.connect(path_visualizer.update_path_display)
		print("Main: Connected player_node.path_ready to path_visualizer.update_path_display.")
	else:
		print("Main: Error: Player node not found.")

	if path_visualizer == null:
		print("Main: Error: PathVisualizer node not found.")
