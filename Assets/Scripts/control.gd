extends Control

@onready var texture_rect: TextureRect = $Background
var aspect_ratio: float = 1.0

func _ready():
	var window = get_window()
	if texture_rect.texture:
		var image_size = texture_rect.texture.get_size()
		window.min_size = image_size  # Set minimum window size
		window.size = image_size  # Set initial window size
		aspect_ratio = float(image_size.x) / float(image_size.y)  # Ensure float division

		window.size_changed.connect(_on_window_resized)

func _on_window_resized():
	var window = get_window()
	var new_width = window.size.x
	var max_height = DisplayServer.window_get_size().y  # Get max available height

	# Compute new height while ensuring it doesn't exceed the screen
	var new_height = min(round(new_width / aspect_ratio), max_height)
	
	# Apply the new size while maintaining aspect ratio
	window.size = Vector2(new_width, new_height)
