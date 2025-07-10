extends TextureRect

var window_rect: Rect2
var current_bounds: Vector4

func on_resize():
	window_rect = get_viewport_rect()

func _ready():
	get_tree().get_root().size_changed.connect(on_resize) 
	window_rect = get_viewport_rect()

func _input(event):
	if not event is InputEventMouseButton or not event.pressed:
		return
		
	# TODO: figure out why I can't call this in _ready() instead
	if current_bounds == Vector4():
		current_bounds = get_instance_shader_parameter("mandelbrot_bounds")

	
	event = event as InputEventMouseButton
	
	var mouse_point = event.position
	var zoom
	
	match event.button_index:
		MOUSE_BUTTON_WHEEL_UP:
			zoom = 1.1
		MOUSE_BUTTON_WHEEL_DOWN:
			zoom = 0.9
		_:
			return
	
	var x = map_range(mouse_point.x, window_rect.position.x, window_rect.size.x, current_bounds[0], current_bounds[2] - current_bounds[0])
	var y = map_range(mouse_point.y, window_rect.position.y, window_rect.size.y, current_bounds[1], current_bounds[3] - current_bounds[1])
	
	current_bounds = zoom_to(current_bounds, Vector2(x, y), zoom)
	
	print("Updating bounds to %v" % current_bounds)
	
	set_instance_shader_parameter("mandelbrot_bounds", current_bounds)

func map_range(x: float, x0: float, w0: float, x1: float, w1: float) -> float:
	return (x - x0) / w0 * w1 + x1

# Zooms to a given point by the specified zoom amount. Maintains the relative position
# of the supplied point in the viewport.
#
# The equations here were derived as follows (for a single dimension):
# |--------.--------------------------------|
# X     x  m               x+w              X+W
#
# X, W are the original x/width values
# x, w are the new x/width values
# m is the zoom point
# z is the zoom factor
# p is m's percent in the viewport (see below for the calculation)
#
# We know m, X, W, and z. We can compute p directly. So we are solving for
# x and w using the equations below.
# 1. p = (m - X) / W  <-- Percent in original viewport from [0, 1]
# 2. m = X + p * W    <-- m is p% in the original viewport
# 3. m = x + p * w    <-- m is also p% in the new viewport
# 4. z = W / w        <-- The zoom factor scales the input range to the output range
#
# You can solve the system of equations via substitution and you get the equations below.
# bounds = (x0, y0, x1, y1)
func zoom_to(bounds: Vector4, point: Vector2, zoom: float) -> Vector4:
	var X = bounds[0]
	var Y = bounds[1]
	var W = bounds[2] - bounds[0]
	var H = bounds[3] - bounds[1]
	
	var x0 = X + (point[0] - X) * (1 - 1 / zoom)
	var y0 = Y + (point[1] - Y) * (1 - 1 / zoom)
	var x1 = x0 + W / zoom
	var y1 = y0 + H / zoom

	return Vector4(x0, y0, x1, y1)
