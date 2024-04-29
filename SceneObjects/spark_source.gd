
"""
This is the physical representation of a testing spark source entity for the Godot engine.
The focus of this class is interacting with the Godot interface, logically the spark source stuff is handled separately

This will instantiate an instance of teh BaseSparkSource class to use for all the spark source things
"""

extends Area2D

# signal variables

signal redraw_orbits(orbit_radius_mult) # this signal gets sent to the scripts that draw the orbit paths and tell them to redraw with some radius multiplier

# variables to use for this object

@export var spark_type : PackedScene # controls the type of spark this spark source spawns
@export var active_ability_ct = 0.5

# this is the object that tracks all the common spark source behavior and all our stats
var spark_source : BaseSparkSource
# this is the speed this object will rotate in radians per second
var rotation_speed
# this is a list containing all the sparks that are active
var sparks = []
var orbit_mult = 1.0
var is_active_ability_ready = true

# this variable controls if time passes for this object
var is_paused = false


# Called when the node enters the scene tree for the first time.
func _ready():
	# create an instance of the spark source object with some constants specific to this spark source
	spark_source = BaseSparkSource.new(150, 1, 10, 1, 1, 10)

	# Ensure that collision is enabled
	$CollisionShape2D.disabled = false

	# initialize the spark spawning timer
	$SparkSpawnCountDown.wait_time = spark_source.spark_gen_rate

	# initialize some constants
	rotation_speed = PI/3

	# connect to the time control signal
	get_parent().control_time.connect(handle_control_time)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# if time is paused, exit before processing anything else
	if is_paused:
		return

	# handle calculating velocity based on user input
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("move_left"):
		velocity.x = velocity.x - 1
	if Input.is_action_pressed("move_right"):
		velocity.x = velocity.x + 1
	if Input.is_action_pressed("move_up"):
		velocity.y = velocity.y - 1
	if Input.is_action_pressed("move_down"):
		velocity.y = velocity.y + 1
	
	velocity = velocity.normalized() * spark_source.speed

	# adjust the position of the spark source based on the calculated velocity
	position = position + (velocity * delta)

	# adjust the rotation of this object based on the rotation speed
	rotation = rotation + (rotation_speed * delta)

	# handle the player using their active ability
	if (Input.is_action_just_pressed("active_ability") or Input.is_action_pressed("active_ability")) and (sparks.size() > 0) and is_active_ability_ready:
		# the active ability has been used, start the cool down timer
		$ActiveAbilityCooldown.wait_time = active_ability_ct
		$ActiveAbilityCooldown.start()
		# the active ability was just used, set it's ready status to false
		is_active_ability_ready = false
		# get a vector from our position to the users mouse
		var mouse_position : Vector2 = get_viewport().get_mouse_position()
		var mid_pos : Vector2 = get_viewport_rect().size / 2
		var angle : Vector2 = mouse_position - mid_pos
		# get the oldest spark from the list of sparks
		var old_spark = sparks.pop_front()
		# fire the old spark along the vector
		old_spark.fire_spark(angle)
		# update the orbit points of all remanining sparks so that they are evenly distributed
		auto_adjust_spark_orbit_pos()





# function to alter the orbit position that each spark tries to maintain so that they are evenly distributed
func auto_adjust_spark_orbit_pos():
	"""This function adjusts the 'orbit_point' attribute of sparks so they are evenly spread out"""

	# only adjust the orbit points if there are at least two sparks currently orbiting the spark source
	if sparks.size() > 1:
		# use the oldest spark as the starting reference point
		var ref_point = sparks[0].orbit_point  # this is a percentage value of how far along the orbit path the spark is (with TAU = 100%)
		# determine how far apart the sparks need to be
		var dist_between_sparks = TAU / sparks.size()

		# adjust the orbit point for all the other sparks
		var start_index = 1
		var next_point = 0.0
		for i in range(sparks.size() - 1):
			# calculate the orbit point for the next spark
			next_point = ref_point - ((start_index + i) * dist_between_sparks)
			# TODO: isloate fractional component?  may not be needed
			# set the orbit point for the next spark
			sparks[start_index + i].orbit_point = next_point



# function to handle removing a spark from the list of active sparks if it has not been fired
func remove_spark(spark):
	# find the spark to be removed in the list of active sparks
	var index = -1
	for i in range(sparks.size()):
		if sparks[i] == spark:
			index = i
			break
	# if the spark was found, remove it from the list
	if index != -1:
		sparks.pop_at(index)
	# if the spark was not found, print an error and do nothing
	else:
		print("ERROR!  Spark not found!")

	# adjust the orbits of the remaining sparks
	auto_adjust_spark_orbit_pos()


# function to handle being hit by an enemy
func hit_by_enemy(enemy):
	# take damage based on the enemies attack damage
	spark_source.health = spark_source.health - enemy.damage
	print("Just took ", enemy.damage, " damage.  ", spark_source.health, " health remaining")



# =================== Functions triggered by signals / events =========================


# This is called when the spark countdown timer is called
func _on_spark_spawn_count_down_timeout():
	# reset the time until the next spark spawn
	$SparkSpawnCountDown.wait_time = spark_source.spark_gen_rate
	
	# if we have not yet hit our cap, spawn a spark
	if sparks.size() < spark_source.spark_cap:
		var new_spark = spark_type.instantiate()
	
		# set the stats of the spark accordingly
		new_spark.spark_source = self
		new_spark.damage = 5
		new_spark.speed = 250
		new_spark.position = position

		# add the spark to the list so we can track it
		get_parent().add_child(new_spark)
		sparks.append(new_spark)

		# alter the orbit percentage of each spark so they orbit evenly
		auto_adjust_spark_orbit_pos()
	
	# test code to see if the redraw orbit signals work
	# update:  They do!  use this signal when there are new modifiers affecting the orbit size
	#else:
		#print("Emitting Redraw orbits")
		#redraw_orbits.emit(orbit_mult)
		#orbit_mult = orbit_mult + 0.1


# This is called whenever the active ability cooldown timer expires
func _on_active_ability_cooldown_timeout():
	# since the cooldown has elapsed, set the ready flag of the active ability to 'true'
	is_active_ability_ready = true


# this function is called when a body enteres the spark source
func _on_body_entered(body):
	# because of the collision layers of the spark source, the only things that can collide and trigger this are enemies (layer 2)
	
	# this function just exists to detect impacts from enemies, enemies will handle what happens on hit

	# trigger hit function on the enemy
	# this way any unique behavior for a unique enemy can occur
	body.hit_spark_source()

	pass # Replace with function body.


# function to handle controlling time.  This should be connected to the "control time signal" within the level
func handle_control_time(freeze_time):
	# freeze time or resume time depending on the given input
	# pause or unpause all timers
	$SparkSpawnCountDown.set_paused(freeze_time)
	$ActiveAbilityCooldown.set_paused(freeze_time)
	if freeze_time:
		# enable the is_paused flag
		is_paused = true
	else:
		# disable the is_paused flag
		is_paused = false



