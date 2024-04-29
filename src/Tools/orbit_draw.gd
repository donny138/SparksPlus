
"""
This is code stolen from online that will draw near circles that I can use to make orbit paths for sparks.

This has been modified to accept events that redraw the orbit using a different radius (works well mid-game)

This script creates a circular path for an orbit size that is defined in the editor
"""

#@tool
extends Path2D

@export var INIT_SIZE : float
@export var NUM_POINTS : int
@export var CLOCKWISE : bool


# runs when this object is added to the scene
func _ready() -> void:
	# draw the curve using the initial size defined in the editor for this orbit
	draw_curve(INIT_SIZE)


# This funciton catches and handles the "redraw_orbits" signal from the spark source
func _on_spark_source_redraw_orbits(orbit_radius_mult):
	"""This function redraws the orbit with some multiplier applied to the original orbit"""
	draw_curve(INIT_SIZE * orbit_radius_mult)


# function to draw the curve
func draw_curve(size):
	# determine which direction to draw the circle in
	var tau : float
	if CLOCKWISE:
		tau = TAU
	else:
		tau = -TAU
	curve = Curve2D.new()
	for i in NUM_POINTS:
		curve.add_point(Vector2(0, -size).rotated((i / float(NUM_POINTS)) * tau))

	# End the circle.
	curve.add_point(Vector2(0, -size))

	


