
"""
This script is for xp objects.

This should be configured within scene objects to set certain values.

When an xp orb spawns it will launch itself away from it's spawn location in a random direction at a random velocity
between some specified max and min value.  
"""

extends Area2D


# configurable attributes
@export var xp_value : float        # this controls how much xp the orb gives when it is collected
@export var disable_xp_drift : bool # the xp will spawn exactly where the enemy died if this is enabled
@export var max_speed : float       # this controls the max speed on the orb when it spawns
@export var min_speed : float       # this controls the min speed of the orb when it spawns
@export var slow_down : float       # this controls how fast the orb slows down when it spawns
@export var mag_speed_max : float	# this controls how fast the orb can be magnetized
@export var mag_accel : float 		# this controls the acceleration of the orb towards whatever magnetizes it

# internal attributes
var init_speed : float				# this is the initial speed to move away from where the xp orb spawns
var cur_speed : float				# this tracks the current speed of the xp orb
var direction : float				# this tracks the direction the orb should move in
var magnetized : bool				# this tracks whether or not the xp orb has been magnetized
var mag_speed : float				# this tracks the current speed of the xp orb due to being magnetized
var is_paused : bool 				# tracks if time should pass for this object or not

# less defined internal attributes
var mag_obj							# a pointer to the object that has magnetized the xp orb (needs a .position attribute)


# Called when the node enters the scene tree for the first time.
func _ready():
	# make sure collision is enabled
	$CollisionShape2D.disabled = false
	# the xp orb is not initially magnetized 
	magnetized = false
	mag_speed = 0.0
	# randomize the rotation
	rotation = TAU * randf()
	# calculate the initial angle and speed the xp orb will travel at / in if this is enabled
	if not(disable_xp_drift):
		# randomize the angle we travel in 
		direction = TAU * randf()
		# get a random initial speed in the range of valid speeds
		init_speed = randf_range(min_speed, max_speed)
		cur_speed = init_speed
	# connect to the control time signal
	get_parent().control_time.connect(handle_control_time)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# if time should be paused for this object, do nothing else
	if is_paused:
		return
	# if the xp orb is magnetized, it should be sucked towards some position
	if (magnetized):
		# calculate the speed the xp orb should be moving towards the magnetized source
		mag_speed = mag_speed + (mag_accel * delta)
		if (mag_speed > mag_speed_max):
			mag_speed = mag_speed_max
		# move the xp orb towards the object magnetizing it
		position = position + (mag_speed * position.direction_to(mag_obj.position) * delta)
	# otherwise, if xp drift is not disabled, move the orb based on the remaining drift
	elif not(disable_xp_drift):
		# adjust the position of the object based on the current speed
		position = position + ((cur_speed * Vector2.ONE.normalized().rotated(direction)) * delta)
		# calculate the new current speed
		# if we slow down enough to totally stop, disable xp drift
		if (cur_speed - (slow_down * delta)) <= 0:
			cur_speed = 0
			disable_xp_drift = true
		# otherwise, reduce the current speed by the slow down
		else:
			cur_speed = cur_speed - (slow_down * delta)


# ================== Helper Functions =================================


# Function to magnetize the xp orb to a given object
func magnetize_to(object):
	# store a pointer to the object that has magnetized the xp orb (must have a .position attribute)
	mag_obj = object
	# flag the xp orb as being magnetized
	magnetized = true


# Function to tell the given object to pickup this xp orb
func pick_up(object):
	# call the pick up handler for xp orbs on the given object
	object.pick_up_xp_orb(self)


# Function to handle receiving the control time signal
func handle_control_time(freeze_time):
	# TODO: disable any timers that get added to xp objects

	# set the is_paused flag to match the freeze time signal
	if freeze_time:
		is_paused = true
	else:
		is_paused = false

