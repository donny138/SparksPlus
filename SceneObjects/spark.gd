
"""
This is a testing class for creating a spark object

Logically, everything related to actual sparks is in the logistical BaseSpark class
This class handles the sparks interactions in physical space and connecting with other godot objects
"""

extends Area2D


# signals


# attributes of this class

# this is the logical spark object that holds all the logical info
var spark : BaseSpark
# if the spark is "fired" it will no longer orbit the spark source or follow any patterns
@export var has_been_fired = false
# this is the rotational speed of the spark
@export var rotation_speed = 0
@export var damage = 0
@export var speed = 0
@export var orbit_rate = 0.0

@export var max_durability = 1		# this controls how many things the spark can hit before it is destroyed
var cur_durability					# this tracks how much durability the spark has left

var spark_source
var orbit_point
var fixed_velocity_vector : Vector2

var fired_life_time

# controls if this object is paused
var is_paused = false



# Called when the node enters the scene tree for the first time.
func _ready():
	# use the values that will be set by a caller to initialize the logical spark
	spark = BaseSpark.new(damage, speed, [])
	# initialze the rotational speed of the spark
	rotation_speed = PI/2
	
	# initialize aspects of the positions in the orbit
	orbit_point = 0.0
	#orbit_rate = PI/4
	# orbit rate should depend on max spark count and the move speed.
	# - max spark count depenendancy means they'll be spaced out evenly
	# - speed dependency means they will actually keep up with the orbit
	# - also depends on radius of the orbit once that is a factor
	orbit_rate = ((2 * PI) / 10) * 1.7

	# configure the initial durability to be the sparks max durability
	cur_durability = max_durability

	# this configures how long the projectile lasts once it is fired (in seconds)
	fired_life_time = 3

	# connect to the time control signal
	get_parent().control_time.connect(handle_control_time)

	# show the spark
	#show()
	pass 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# do not do anything if time is paused for this object
	if is_paused:
		return

	# initialze variables used here
	var orbit
	var target_position
	var velocity_direction

	# There are a few things that can affect how the spark moves

	# if the spark has been fired, handle how it moves along it's fixed velocity vector
	if has_been_fired:
		velocity_direction = fixed_velocity_vector
		# set the target position to the position it will have a second from now 
		# this prevents the later calculations from reducing the speed
		target_position = position + (speed * velocity_direction * (delta + 1))

	# if the spark is in special orbit, handle how it moves
	elif Input.is_action_pressed("defense_ability"):
		orbit = spark_source.get_node("DefenseOrbit/OrbitPoint")
		orbit.progress_ratio = orbit_point / (TAU)
		target_position = orbit.position + spark_source.position
		velocity_direction = position.direction_to(target_position)

	# if the player has not told this spark to do something, then it is in idle orbit around the spark source
	else:
		orbit = spark_source.get_node("IdleOrbit/OrbitPoint")
		orbit.progress_ratio = orbit_point / (TAU)
		target_position = orbit.position + spark_source.position
		velocity_direction = position.direction_to(target_position)

	# work out if we are traveling more than needed to get to our destination and reduce if more
	var dist_to = position.distance_to(target_position)
	var delta_position = velocity_direction * speed * delta
	if (speed * delta) > dist_to:
		delta_position = velocity_direction * dist_to * delta
	# adjust our actual position accordingly
	position = position + delta_position

	# adjust the rotation of the spark
	rotation = rotation + (rotation_speed * delta)

	# increment how far along it's orbit the spark should be
	orbit_point = orbit_point + (orbit_rate * delta)



# this function handles launching the spark out of any orbits (this happens when the user uses an active ability)
func fire_spark(angle : Vector2):
	# flag the "has been fired" flag to change how movement is handled
	has_been_fired = true
	#var angle = position.direction_to(mouse_position)
	# the spark will now move in a fixed direction until it hits something or expires
	# we need to extract the angle from this spark, not the middle node
	var spark_angle = spark_source.position - position
	#var spark_angle = position - spark_source.position
	fixed_velocity_vector = (angle + spark_angle).normalized()
	# start the timer that tracks the new lifetime of the spark
	$LifeTime.wait_time = fired_life_time
	$LifeTime.start()



# this function handles what happens when the spark runs out of durability 
func handle_spark_break():
	#TODO:  add a fun animation that plays when the spark breaks and maybe some cool partical effects

	# if the spark has not been fired, remove it from the list of active sparks within the spark source
	if has_been_fired == false:
		spark_source.remove_spark(self)

	# remove the spark object from the game
	queue_free()
	



#================ Event Handlers =====================

	
# This function gets called when the sparks lifetime timer expires
func _on_life_time_timeout():
	# remove this object from the game
	queue_free()


# This functio gets called when the spark enters another body
func _on_body_entered(body):
	# decrement the sparks remaining durability
	cur_durability = cur_durability - 1
	
	# tell the body that we just hit to announce itself and that it was hit by this spark
	body.got_hit(self)

	# if the spark is out of durability, destroy the spark
	if cur_durability == 0:
		handle_spark_break()


# function to handle controlling time.  This should be connected to the "control time signal" within the level
func handle_control_time(freeze_time):
	# freeze time or resume time depending on the given input
	# pause or unpause all active timers
	$LifeTime.set_paused(freeze_time)
	if freeze_time:
		# enable the is_paused flag
		is_paused = true
	else:
		# disable the is_paused flag
		is_paused = false


