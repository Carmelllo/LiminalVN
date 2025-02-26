extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	# Get the size of the screen (viewport)
	var screen_size = get_viewport().size

	# Set the Control node size to match the screen size
	custom_minimum_size = screen_size
	
	# Set the anchors to full screen (so it scales with the viewport)
	anchor_left = 0
	anchor_top = 0
	anchor_right = 1
	anchor_bottom = 1

	# Set the size flags to fill the screen
	size_flags_horizontal = SIZE_FILL
	size_flags_vertical = SIZE_FILL

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
