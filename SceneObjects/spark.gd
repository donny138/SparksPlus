
"""
This is a testing class for creating a spark object

Logically, everything related to actual sparks is in the logistical BaseSpark class
This class handles the sparks interactions in physical space and connecting with other godot objects
"""

extends RigidBody2D


# this is the logical spark object that holds all the logical info
var spark : BaseSpark



# configurable base attributes of the spark

@export var base_damage : float
@export var base_speed : float
@export var base_orbit_rate = ((2 * PI) / 10) * 1.7
@export var base_durability : int					# this controls how many things the spark can hit before it is destroyed

# current attributes of the spark
var cur_damage : float
var cur_speed : float
var cur_durability : int

# Pointers and misc internal variables
var level_scene 						# pointer to the level scene object that runs the game
var spark_source						# pointer to the spark source that created this spark
var orbit_point							# the point (in radians) on the sparks orbit that the spark should try to get to
var has_been_fired = false				# a flag to track if the spark is attached to the spark source or not
var fixed_velocity_vector : Vector2		# a velocity vector to follow once the spark is not following an orbit
var cur_orbit_rate : float				# the value that the orbit_point changes per second
var has_physics_been_enabled : bool		# this var tracks if collision was initially enabled or not

# spark engine and movement variables
var engine : BasicSparkEngine			# this is the object that drives the sparks movement

# time related attributes
var is_paused = false					# tracks if time applies to this object or if it does not
var fired_life_time						# time that the spark lasts after being fired before expiring

# modifiers and abilities
var mods = {}							# a dict of modifiers that apply specifically to this spark
var abilities = []						# a list of abilities that apply specifically to this spark





# Called when the node enters the scene tree for the first time.
func _ready():
	# link the spark to the level scene object that it exists within
	level_scene = get_parent()
	# use the values that will be set by a caller to initialize the logical spark
	spark = BaseSpark.new(base_damage, base_speed, [])
	# calculate a base orbit rate based on the base speed and idle orbit size
	base_orbit_rate = TAU / (((TAU * spark_source.base_defense_orbit) / base_speed) * 1.5)
	# initialze the current attributes based on the base attributes of the spark
	update_attributes()

	# initialze the initial movement of the spark
	#rotation_speed = PI/2
	#prev_direction = Vector2.ONE

	engine = BasicSparkEngine.new()
	engine.init_engine(self)
	
	# initialize aspects of the positions in the orbit
	orbit_point = 0.0
	#orbit_rate = PI/4
	# orbit rate should depend on max spark count and the move speed.
	# - max spark count depenendancy means they'll be spaced out evenly
	# - speed dependency means they will actually keep up with the orbit
	# - also depends on radius of the orbit once that is a factor

	# initialize collision to be on for both the physics and enemy detection collision objects
	$PhysicsCollisionPolygon.disabled = false
	$EnemyHitDetection/CollisionPolygon2D.disabled = false

	# randomly determine the sparks initial direction
	var initial_angle = randf_range(0, TAU)

	# initialize the sparks velocity based on it's speed
	linear_velocity = Vector2.from_angle(initial_angle) * cur_speed

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
		#linear_velocity = Vector2.ZERO
		return

	# determine what orbit this spark should be in
	var is_idle = true
	# detect user input to determine if the spark should be in it's defensive mode
	if Input.is_action_pressed("defense_ability"):
		# the spark is in defensive mode
		is_idle = false

	# call the spark engine to handle any motion the spark experiences
	engine.drive_spark(self, is_idle)

	# LEGACY ORBIT POINT THINGS
	# update the orbit point of the spark
	#orbit_point = orbit_point + (randf_range(cur_orbit_rate / 4, cur_orbit_rate) * delta)

	

"""
Old spark movement code for future order use:
"""
	# do not do anything if time is paused for this object
	#if is_paused:
		#return

	# initialze variables used here
	#var orbit
	#var target_position
	#var velocity_direction
	#if has_been_fired:
		#velocity_direction = fixed_velocity_vector
		# set the target position to the position it will have a second from now 
		# this prevents the later calculations from reducing the speed
		#target_position = position + (cur_speed * velocity_direction * (delta + 1))

	# if the spark is in special orbit, handle how it moves
	#elif Input.is_action_pressed("defense_ability"):
		#orbit = spark_source.get_node("DefenseOrbit/OrbitPoint")
		#orbit.progress_ratio = orbit_point / (TAU)
		#target_position = orbit.position + spark_source.position
		#velocity_direction = position.direction_to(target_position)

	# if the player has not told this spark to do something, then it is in idle orbit around the spark source
	#else:
		#orbit = spark_source.get_node("IdleOrbit/OrbitPoint")
		#orbit.progress_ratio = orbit_point / (TAU)
		#target_position = orbit.position + spark_source.position
		#velocity_direction = position.direction_to(target_position)

	# work out if we are traveling more than needed to get to our destination and reduce if more
	#var dist_to = position.distance_to(target_position)
	#var delta_position = velocity_direction * cur_speed * delta
	# adjust our actual position accordingly
	#if (cur_speed * delta) > (dist_to * 2):
		#position = target_position
	#else:
		#position = position + delta_position

	# adjust the rotation of the spark
	#rotation = rotation + (rotation_speed * delta)

	# increment how far along it's orbit the spark should be
	#orbit_point = orbit_point + (cur_orbit_rate * delta)


# function to check and see if physics collision should be enabled and enable it if it should
func enable_physics_collision():
	if not(has_physics_been_enabled) and not(has_been_fired):
		has_physics_been_enabled = true
		$PhysicsCollisionPolygon.disabled = true


# ======================= Handling special spark behavior ==================================


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

	# tell the spark engine that the spark was fired
	engine.fire_spark(self, fixed_velocity_vector)

	# start the timer that tracks the new lifetime of the spark
	$LifeTime.wait_time = fired_life_time
	$LifeTime.start()



# this function handles what happens when the spark runs out of durability 
func handle_spark_break():
	#TODO:  add a fun animation that plays when the spark breaks and maybe some cool partical effects

	# remove the spark from the game
	remove_self()
	

# function to handle removing this spark
func remove_self():
	# if the spark has not been fired, remove it from the list of sparks in orbit around the spark source
	if has_been_fired == false:
		spark_source.remove_spark(self)
	
	# remove the spark from the level scene
	level_scene.remove_active_spark(self)

	# remove the spark object from the game
	queue_free()



# ======================== Modifier Handling ============================


# function to determine current attributes based on base values and modifiers
func update_attributes():
	# this function assumes the "mods" array contains the right modifiers to apply to the spark
	# TODO:  change particle effects or colors here based on mods?

	# combine the global list of spark modifiers from the level scene object with the list of local modifiers
	# doing this in a dictionary to make finding the lists of mods affecting each attribute easier
	var all_mods = {}
	# get all the global modifiers from the level scene
	for mod_list : Array in level_scene.spark_mods.values():
		for mod : Mod in mod_list:
			var attribute = mod.mod_attribute
			# get the list of modifers that affect this attribute
			var array = all_mods.get(attribute, [])
			array.append(mod)
			# if this is a new list, add it to the dictionary
			if array.size() == 1:
				all_mods[attribute] = array
	# get all the unique modifiers from this object
	for mod_list : Array in mods.values():
		for mod : Mod in mod_list:
			var attribute = mod.mod_attribute
			# get the list of modifers that affect this attribute
			var array = all_mods.get(attribute, [])
			array.append(mod)
			# if this is a new list, add it to the dictionary
			if array.size() == 1:
				all_mods[attribute] = array

	# get the array of modifers for each attribute and use them to update each calculation

	# Damage attribute calculation
	var damage_mods = all_mods.get(Consts.ModAttribute_e.damage, [])
	cur_damage = Consts.calc_mods(damage_mods, base_damage)

	# Speed attribute calculation
	var speed_mods = all_mods.get(Consts.ModAttribute_e.speed, [])
	cur_speed = Consts.calc_mods(speed_mods, base_speed)
	cur_orbit_rate = TAU / (((TAU * spark_source.cur_defense_orbit) / cur_speed) * 1.3)
	
	# Durability attribute calculation
	var durability_mods = all_mods.get(Consts.ModAttribute_e.durability, [])
	cur_durability = int(Consts.calc_mods(durability_mods, float(base_durability)))




#================ Event Handlers =====================

	
# This function gets called when the sparks lifetime timer expires
func _on_life_time_timeout():
	# remove this object from the game
	remove_self()


# This function gets called when the spark enters another body
func _on_enemy_hit_detection_body_entered(body):
	# attempt to hit the enemy
	var hit_enemy = body.got_hit(self)
	# if the attack successfully hit the enemy, handle how that affects the spark
	if(hit_enemy):
		# decrement the sparks remaining durability
		cur_durability = cur_durability - 1
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
		# freeze the physics for this object
		set_deferred("freeze", true)
		#constant_force = Vector2.ZERO
		#linear_velocity = Vector2.ZERO
	else:
		# disable the is_paused flag
		is_paused = false
		# un-freeze the physics for this object
		set_deferred("freeze", false)


