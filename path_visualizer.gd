# PathVisualizer.gd
extends Node2D

var path_to_draw: Array = [] # This will store the tile coordinates to draw

# This function is called by another script (e.g., Main.gd)
# to update the path that should be visualized.
func update_path_display(new_path: Array):
	print("path_visualizer received new data")
	path_to_draw = new_path
	queue_redraw() # Request Godot to call _draw() again next frame

func _draw():
	if path_to_draw.is_empty():
		return # Nothing to draw

	# Iterate through the tile coordinates and draw a circle at each one
	for tile_coords in path_to_draw:
		# Drawing parameters
		var circle_radius = 2 # Adjust size as needed
		var circle_color = Color.WHITE
		draw_circle(tile_coords, circle_radius, circle_color)

		# Optional: Draw the tile grid coordinates for debugging
		# draw_string(get_theme_font("font"), local_draw_pos + Vector2(10, 10), str(tile_coords), Color.WHITE)
