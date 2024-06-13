
"""
This is the physical representation of a testing spark source entity for the Godot engine.
The focus of this class is interacting with the Godot interface, logically the spark source stuff is handled separately

This will instantiate an instance of teh BaseSparkSource class to use for all the spark source things
"""

extends Area2D

# signal variables
signal redraw_idle_orbit(orbit_radius)
signal redraw_defense_orbit(orbit_radius)	


# configurable attributes of this object
@export var base_health : float			# the base health of the spark source
@export var base_speed : float			# the base speed of the spark source
@export var base_defense : float		# the base defense of the spark source (NYI, DOES NOTHING)
@export var base_spark_gen_rate : float # the base time (seconds) it takes to generate a spark
@export var base_spark_cap : int		# the base number of sparks that can be in orbit
@export var base_xp_mult : float		# base multiplier for xp gain
@export var base_pickup_range : float   # base radius of the magnetic effect for pickupables around the spark source
@export var base_idle_orbit : float 	# base radius of the idle spark orbit
@export var base_defense_orbit : float	# base radius of the defensive orbit the sparks fly in
@export var spark_type : PackedScene 	# controls the type of spark this spark source spawns
@export var base_active_ability_ct : float# base time (in seconds) between uses of the active ability
@export var xp_needed_per_level : float	# the additional amount of xp needed in between levels

# internal game attributes:
var max_health : float					# max health (after mods) the spark source can have
var cur_health : float					# current health the spark source has
var cur_speed : float					# current speed (after mods) the spark source can travel (pixels / second)=
var cur_defense : float					# current defense (after mods) of the spark source (NYI, DOES NOTHING)
var cur_spark_gen_rate : float			# current time (seconds) (after mods) it takes to generate a spark
var cur_spark_cap : int					# current max count of sparks (after mods)
var cur_xp_mult : float					# current xp mult (after mods)
var cur_pickup_range : float			# current radius of magnetic pickup zone (after mods) around the spark source
var cur_idle_orbit : float				# current radius of the idle spark orbit
var cur_defense_orbit : float			# current radius of the defensive spark orbit
var cur_active_ability_ct : float		# current time (seconds) (after mods) between uses of the active ability

# modifier and ability attributes
var mods : Dictionary					# array of modifiers that apply to this spark source that aren't included in the global list
var abilities : Array 					# array of abilities that apply to this spark source that aren't included in the global list

# logic and game objects
var level_scene							# pointer to the level scene object that manages the level
var level_hud							# pointer to the level HUD the player will see on screen
var rotation_speed						# tracks rotation speed in rads/sec
var sparks = []							# list of active sparks currently in orbit around this spark source
var orbit_mult = 1.0					# multiplier to apply to orbit radius
var is_active_ability_ready = true		# allows use of active ability when true
var is_paused = false					# tracks if time should pass for this object
var cur_level : int						# tracks the current level of this object
var cur_xp_amount : float 				# the amount of xp we currently have
var next_level_xp_amount : float 		# the amoutn of xp we need for the next level


# ========================= Initialization and Utility Functions ====================================================


# Called when the node enters the scene tree for the first time.
func _ready():
	# link the spark source to the level scene it exists within
	level_scene = get_parent()
	# initialize health values to their starting amount
	max_health = base_health
	cur_health = max_health

	# Initialze current spark source attributes to base values / with any starting modifiers
	update_attributes()

	# Ensure that collision is enabled
	$CollisionShape2D.disabled = false
	# ensure that collision for pickups is enabled
	$PickupMagnetRange/CollisionShape2D.disabled = false
	$PickupCollectionRange/CollisionShape2D.disabled = false

	# initialize the spark spawning timer
	$SparkSpawnCountDown.wait_time = cur_spark_gen_rate
	$SparkSpawnCountDown.start()

	# we start at level 0
	cur_level = 0
	# set the initial amount of xp needed to advance to the next level
	next_level_xp_amount = xp_needed_per_level

	# initialize some temporary constants
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
	
	velocity = velocity.normalized() * cur_speed

	# adjust the position of the spark source based on the calculated velocity
	position = position + (velocity * delta)

	# adjust the rotation of this object based on the rotation speed
	rotation = rotation + (rotation_speed * delta)

	# handle the player using their active ability
	if (Input.is_action_just_pressed("active_ability") or Input.is_action_pressed("active_ability")) and (sparks.size() > 0) and is_active_ability_ready:
		# the active ability has been used, start the cool down timer
		$ActiveAbilityCooldown.wait_time = cur_active_ability_ct
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
		#auto_adjust_spark_orbit_pos()


# function to perform initial hud updates once the hud gui exists
func init_hud_update():
	# update the health display
	# TODO:  Update this when stats are moved into this class
	level_hud.update_health(cur_health, max_health)
	# TODO: update the curent xp progress and level if player can start with values above 0


# =====================  Helper Functions =======================

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
	#auto_adjust_spark_orbit_pos()


# function to handle being hit by an enemy
func hit_by_enemy(enemy):
	# take damage based on the enemies attack damage
	cur_health = cur_health - enemy.cur_damage
	# update the hud to reflect the current health status
	# TODO: Update this once stats are moved back into this class
	level_hud.update_health(cur_health, max_health)


# function to check and handle triggering a level up
func level_up():
	# check to see if we can level up
	if (cur_xp_amount >= next_level_xp_amount):
		# remove the xp used to level up
		cur_xp_amount = cur_xp_amount - next_level_xp_amount
		# update the amount of xp needed for the next level
		#TODO: update this calculation to be more balanced
		next_level_xp_amount = next_level_xp_amount + xp_needed_per_level
		# increment the current level by one
		cur_level = cur_level + 1

		# update the level on the level_hud gui
		level_hud.update_level(cur_level)
		
		# Trigger the level up gui
		get_parent().trigger_level_up_gui()		
	
	# update the xp bar on the hud to reflect the current amount
	level_hud.update_xp(cur_xp_amount, next_level_xp_amount)



# ==================== Modifier Functions ============================


# function to update all of the spark sources current attributes based on it's base value and it's list of modifiers
func update_attributes():
	# this function assumes that spark_source_mods is up to date and contains all the mods that it should

	# combine the global list of modifiers from the level scene with local modifiers on this spark source object
	# doing this with a dictionary allows the source to not need to iterate through the list a bunch of times later
	# (local list can contain temporary modifiers too)
	var all_mods = {}
	# get modifers from the level scene
	for mod_list : Array in level_scene.source_mods.values():
		for mod : Mod in mod_list:
			var attribute = mod.mod_attribute
			# get the list of modifers that affect this attribute
			var array = all_mods.get(attribute, [])
			array.append(mod)
			# if this is a new list, add it to the dictionary
			if array.size() == 1:
				all_mods[attribute] = array
	# get local modifiers
	for mod_list : Array in mods.values():
		for mod : Mod in mod_list:
			var attribute = mod.mod_attribute
			# get the list of modifers that affect this attribute
			var array = all_mods.get(attribute, [])
			array.append(mod)
			# if this is a new list, add it to the dictionary
			if array.size() == 1:
				all_mods[attribute] = array

	# isloate the modifiers that apply to each attribute and apply them to the current value on the spark source

	# Modify Health
	var health_mods = all_mods.get(Consts.ModAttribute_e.health, [])
	var health_ratio = cur_health / max_health
	max_health = Consts.calc_mods(health_mods, base_health)
	# the current health should (percentage wise) be the same as before the mod was applied
	cur_health = max_health * health_ratio
	if level_hud != null:
		level_hud.update_health(cur_health, max_health)

	# Modify Speed
	var speed_mods = all_mods.get(Consts.ModAttribute_e.speed, [])
	cur_speed = Consts.calc_mods(speed_mods, base_speed)

	# Modify Defense
	var defense_mods = all_mods.get(Consts.ModAttribute_e.defense, [])
	cur_defense = Consts.calc_mods(defense_mods, base_defense)

	# Modify Spark Gen Rate
	var spark_gen_mods = all_mods.get(Consts.ModAttribute_e.spark_gen, [])
	cur_spark_gen_rate = Consts.calc_mods(spark_gen_mods, base_spark_gen_rate)

	# Modify Spark Cap
	var spark_cap_mods = all_mods.get(Consts.ModAttribute_e.spark_cap, [])
	cur_spark_cap = int(Consts.calc_mods(spark_cap_mods, float(base_spark_cap)))

	# Modify xp multiplier
	var xp_mult_mods = all_mods.get(Consts.ModAttribute_e.xp_mult, [])
	cur_xp_mult = Consts.calc_mods(xp_mult_mods, base_xp_mult)

	# Modify the active ability cooldown time
	var active_ability_ct_mods = all_mods.get(Consts.ModAttribute_e.active_abil_ct, [])
	cur_active_ability_ct = Consts.calc_mods(active_ability_ct_mods, base_active_ability_ct)

	# Modify the current pickup range 
	var pickup_range_mods = all_mods.get(Consts.ModAttribute_e.pickup_range, [])
	cur_pickup_range = Consts.calc_mods(pickup_range_mods, base_pickup_range)
	# apply the pickup range to the pickup magnet range object
	$PickupMagnetRange/CollisionShape2D.shape.radius = cur_pickup_range

	# Modify the orbits the sparks take
	var orbit_range_mods = all_mods.get(Consts.ModAttribute_e.orbit_range, [])
	cur_idle_orbit = Consts.calc_mods(orbit_range_mods, base_idle_orbit)
	cur_defense_orbit = Consts.calc_mods(orbit_range_mods, base_defense_orbit)
	# redraw the orbits
	redraw_idle_orbit.emit(cur_idle_orbit)
	redraw_defense_orbit.emit(cur_defense_orbit)





# ================== Pickup object handlers ============================

# function to pickup a given xp orb
func pick_up_xp_orb(xp_orb):
	# add the xp from the orb to the spark source
	#TODO: add xp modifiers to this calculation
	cur_xp_amount = cur_xp_amount + xp_orb.xp_value
	# call the level up function to see if we can level up and handle it as needed
	level_up()
	# remove the xp orb from the game
	xp_orb.call_deferred("queue_free")

# =================== Functions triggered by signals / events =========================


# This is called when the spark countdown timer is called
func _on_spark_spawn_count_down_timeout():
	# reset the time until the next spark spawn
	$SparkSpawnCountDown.wait_time = cur_spark_gen_rate
	
	# if we have not yet hit our cap, spawn a spark
	if sparks.size() < cur_spark_cap:
		var new_spark = spark_type.instantiate()
	
		# set the stats of the spark accordingly
		new_spark.spark_source = self
		new_spark.position = position

		# add the spark as a child of the level scene
		get_parent().add_child(new_spark)
		# add the spark to the list of sparks in the level scene
		level_scene.active_sparks.append(new_spark)
		# add the spark to the list of sparks in orbit around this spark source
		sparks.append(new_spark)

		# alter the orbit percentage of each spark so they orbit evenly
		#auto_adjust_spark_orbit_pos()
	
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
	print("SPARK SOURCE DETECTED ENEMY HIT")
	body.hit_spark_source()

	pass # Replace with function body.


# this function is called when an object exists the inner wall of the collision thing for the first time
func _on_inner_spark_container_wall_body_exited(body):
	# this will activate for sparks just after they spawn.  
	# call the function to enable the physics collisions for the spark
	body.enable_physics_collision()
	print("ENABLING: ",body)

	pass # Replace with function body.


# function to handle when an area object enters the pickup magnet
func _on_pickup_magnet_range_area_entered(area):
	# the magnet pickup range only detects pickup-able things and should pull them towards the center of the spark source
	# magnetize the object to this object
	area.magnetize_to(self)


# function to handle when a area object enters the pickup collection range
func _on_pickup_collection_range_area_entered(area):
	# the collection range only detects pickup-able thigs and should collect whatever it touches
	# the object should call a handler for the correct pick-up behavior
	area.pick_up(self)


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








