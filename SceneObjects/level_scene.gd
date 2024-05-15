
"""
This script manages the level object of the game during a run

TODO:
	- Create a class that stores a list of spawnable enemies and modifiers that can be applied based on time
		- This would define a 'time block' with a list of enemies that can be spawned
		- this class would describe a particular level, this would be loaded depending on what level the player wants to play
	- Add spawning events to handle spawning enemies in different ways
	
"""

extends Node2D

# signals
signal control_time(freeze_time : bool)  # this signal will be emitted and controls if time should pass for all game objects


# configurable attributes of the level
@export var enemy_count_cap = 25	# max number of enemies that can be on the game at once
@export var enemy_spawn_rate = 2.5	# the time (in seconds) between enemy spawn events

# TEMPORARY ATTRIBUTES
# TODO:  Make this dependent on the specific level instead of relying on manual input here
@export var enemy_type : PackedScene # the enemy scene to spawn

# internal attributes of the level
var spark_source 			# pointer to the active spark source (the player)
var level_hud 				# pointer to the level hud
var level_up_gui			# pointer to the leve up gui
var active_enemies = []		# a list of enemy objects that are currently active
var active_sparks = []		# a list of spark objects that exist within the game


# modifiers and ability attributes
var level_mods = {}			# a dict of modifiers that apply to the level scene object
var source_mods = {}		# a dict of modifiers that apply to the spark source object
var spark_mods = {}			# a dict of modifiers that apply to EVERY spark object
var enemy_mods = {}			# a dict of modifiers that apply to EVERY enemy object
var level_abilities = []	
var source_abilities = []
var spark_abilities = []
var enemy_abilities = []

# Level Unlockable related variables
var valid_unlockables = {}	# a dict of level unlockables that are valid to be chosen
var potential_unlockables = []# the level unlockables that could possibly appear in the game
var active_unlockables = {}	# a dict of level unlockables that the player has activated storing the number of times they have been chosen

# time related vars
var time_passed_sec 		# tracks the number of seconds that have passed since the level started
var pause_menu_active = false
var disable_paise_menu = false

# TEMPORARY VARIABLES ONLY
# list of level unlockables that can appear for testing
var temp_valid_unlockables = [
	OverclockedSparks,
	PickUpRangeUp,
	RocketSparks
]


# Called when the node enters the scene tree for the first time.
func _ready():
	# configure the enemy spawn timer
	$EnemySpawnCountDown.wait_time = enemy_spawn_rate
	# store a pointer to the spark source object
	spark_source = $SparkSource

	# connect to the time control signal
	control_time.connect(handle_control_time)

	# set initial information for the level HUD
	level_hud = $GuiLayer/LevelHud
	spark_source.level_hud = level_hud
	# allow the spark_source to do it's initial hud udpates
	spark_source.init_hud_update()

	# configure initial values for the level up gui
	level_up_gui = $GuiLayer/LevelUpGui
	level_up_gui.level = self
	
	# initialize time things
	time_passed_sec = 0		# the level is just starting, no time has passed
	level_hud.update_time(time_passed_sec)

	# TODO: Move this behavior to exist outside of the level and passed into the level once initialized
	# do this when a main Menu / parent level exists that encompasses the level object
	# (set all the level unlockables that are allowed to appear in the game)
	potential_unlockables = [
		OverclockedSparks,
		SwarmingSparks,
		RapidFire,
		RepeatedHits,
		PickUpRangeUp,
		RocketSparks,
		SourceHealth,
		SourceSpeed,
	]
	# Generate the initial list of valid unlockables
	valid_unlockables = get_initial_valid_unlockables()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	# debug event handling for the pause menu
	if Input.is_action_just_pressed("pause_menu"):
		# if the pause menu is not active, activate it. If it is, deactivate it
		# don't do this if we are leveling up, level up gui needs input before game can resume
		if not disable_paise_menu:
			control_time.emit(not pause_menu_active)
			pause_menu_active = not pause_menu_active



# ======================= Spawning Events ==================================


# function to select a point to spawn an enemy at based on the spark sources enemy spawning path
func select_rand_enemy_spawn_point():
	# get a pointer to the spawn point along the spawn path of the spark source
	var point = $SparkSource/EnemySpawnDist/EnemySpawnPoint
	# choose a random point along the path
	point.progress_ratio = randf()
	# adjust the point to reference global coordinates instead of coordinates relative to the spark source
	var location = point.position + spark_source.position
	# return this location
	return location



# function to handle spawning 'test_enemy_0' enemies
func spawn_test_enemy(_room_to_enemy_count_cap):
	#TODO: implement multi-enemy spawning
	#TODO: limit multi-enemy spawning based on remaining enemy count

	# select a random point that an enemy can spawn on
	var spawn_point = select_rand_enemy_spawn_point()

	# spawn a new test enemy at this location
	var new_enemy = enemy_type.instantiate()
	new_enemy.position = spawn_point
	new_enemy.spark_source = spark_source
	
	# add the enemy to this level and as a child of the level object
	active_enemies.append(new_enemy)
	add_child(new_enemy)
	# debug print
	#print("Added enemy #", active_enemies.size(), " at: ", spawn_point)


# ===================== Handlers for specific events ============================


# function to remove an enemy from the list of active enemies
func remove_active_enemy(enemy):
	# find the enemy to be removed in the list of active enemies
	var index = -1
	for i in range(active_enemies.size()):
		if active_enemies[i] == enemy:
			index = i
			break
	# if the enemy was found, remove it from the list
	if index != -1:
		active_enemies.pop_at(index)
	# if the enemy was not found, print an error and do nothing
	else:
		print("ERROR!  Enemy not found!")


# function to remove an active spark
func remove_active_spark(spark):
	# find the spark in the list of active sparks
	var index = -1
	for i in range(active_sparks.size()):
		if active_sparks[i] == spark:
			index = i
			break
	# if the spark was found, remove it from the list
	if index != -1:
		active_sparks.pop_at(index)
	# if the spark was not found, print an error and do nothing
	else:
		print("ERROR!  Spark not found!")
	pass


# function to handle controlling time.  This should be connected to the "control time signal" within the level
func handle_control_time(freeze_time):
	# freeze time or resume time depending on the given input
	# pause or unpause all timers
	$EnemySpawnCountDown.set_paused(freeze_time)
	$LevelTimer.set_paused(freeze_time)


# function to update the level up gui and make it appear
func trigger_level_up_gui():
	# triggered by the spark_source when it detects a level up
	# TODO: Finalize this behavior

	# pause time
	disable_paise_menu = true
	control_time.emit(true)

	# TODO: add a cool visual effect / sound trigger here at some point
	# put a blur effect onto everything normally in the game (hud too, but not level up gui)

	# randomly pick 3 available level unlockables (TODO make random)
	var rand_unlocks = {}
	var valid_unlocks_names = valid_unlockables.keys()
	print('\n')
	print(valid_unlocks_names)
	# select 3 different level unlockables
	while rand_unlocks.size() < 3:
		var rand = valid_unlocks_names.pick_random()
		if not rand_unlocks.has(rand):
			rand_unlocks[rand] = valid_unlockables[rand]
	# get an array of instantiated level unlockable objects
	print(rand_unlocks.keys())
	var unlock_objects = rand_unlocks.values()
	var inst_unlock_objects = [
		unlock_objects[0].new(),
		unlock_objects[1].new(),
		unlock_objects[2].new()
	]
	# Pass the level unlockables off to the level up gui (it will associate each option with a button and display the description)
	level_up_gui.load_level_unlock_options(inst_unlock_objects)

	# tell the level up gui to un-hide itself and wait for the user to click one of the options
	level_up_gui.enable_gui()


# function to apply the selected mod from the level up event and flag it as complete
func finish_level_up_event(chosen_unlock : LevelUnlockable):
	#TODO:  flush out this behavior once mods are actually added

	# Add this level unlockable to the list of activated unlockables
	# get any occurances of this unlock being selected before
	var count = active_unlockables.get(chosen_unlock.name, 0)
	# increment the number of times it has been chosen
	count = count + 1
	# set the new value (creates a new entry in the dict if it didn't already exist)
	active_unlockables[chosen_unlock.name] = count
	print(chosen_unlock.name, " Has been unlocked ", count, " times!")
	
	# update the set of valid unlockables based on the chosen unlock
	update_valid_unlockables(chosen_unlock)

	# add new modifiers from the level unlock object to the game
	add_new_mods(chosen_unlock.mods)
	
	# Add any new Abilities to the relevant game objects
	# TODO: Update this implementation once abilities are implemented
	add_new_abilities(chosen_unlock.abilities)

	# resume time
	
	# start the unpause delay timer so that there is a small delay after the gui goes away before time resumes
	$UnpauseDelayTimer.start()


# ================= Functions that handle modifiers =======================


# function to update the mod lists for every object type with new mods and update the attributes of objects as needed
func add_new_mods(mod_list : Array):
	# variables to track if different entities have had their mods updated or not
	var source_updated = false
	var spark_updated = false
	var level_updated = false
	var enemy_updated = false

	# Add Modifiers from the chosen unlock to the spark source
	var new_mods = Consts.filter_mods_by_target(mod_list, Consts.ModTarget_e.spark_source)
	if new_mods.size() > 0:
		add_mods_to_dict(source_mods, new_mods)
		# flag the source as needing an update
		source_updated = true
	
	# Add Modifiers from the chosen unlock to the spark mod list on the spark source
	new_mods = Consts.filter_mods_by_target(mod_list, Consts.ModTarget_e.spark)
	if new_mods.size() > 0:
		add_mods_to_dict(spark_mods, new_mods)
		# flag the sparks as needing an update
		spark_updated = true
	
	# Add Modifiers from the chosen unlock to the level 
	new_mods = Consts.filter_mods_by_target(mod_list, Consts.ModTarget_e.level)
	if new_mods.size() > 0:
		add_mods_to_dict(level_mods, new_mods)
		# flag the level as needing an update
		level_updated = true
	
	# Add Modifiers from the chosen unlock to the enemy mod list within the level
	new_mods = Consts.filter_mods_by_target(mod_list, Consts.ModTarget_e.enemy)
	if new_mods.size() > 0:
		add_mods_to_dict(enemy_mods, new_mods)
		# flag the enemies as needing an update
		enemy_updated = true

	# Tell any objects that have had their mod lists updated to re-calculate their attributes
	if source_updated:
		# tell the spark source to update it's current attributes to make sure that they account for the new modifiers
		spark_source.update_attributes()
	if spark_updated:
		# update all the active sparks with their new modifiers
		for spark in active_sparks:
			spark.update_attributes()
	if enemy_updated:
		# update all active enemy objects with their new attributes
		# TODO: Implement this once enemies have an update attribute function
		pass
	if level_updated:
		# update modifiers that affect the level
		# TODO: implement once there are any modifiers that actual do this
		pass


# function to add a list of modifiers to a dictionary
func add_mods_to_dict(mod_dict : Dictionary, mod_list : Array):
	for mod : Mod in mod_list:
		# Add each mod to the dictionary using it's name as the key
		var array = mod_dict.get(mod.name, [])
		# if there is already an array of these mods, check to see if the mod is repeatable or not
		if array.size() > 0:
			if mod.repeatable:
				# add another instance of this mod to the dictionary	
				array.append(mod)
			else:
				# cannot add the modifier since one already exists and it is not repeatable
				# debug log to log the attempt
				print("WARNING: attempted to add unrepeatable modifier: ", mod.name)
				# this shouldn't happen, debug log will alert you to it happening if level unlockables are not configured right
		else:
			# if an array for this modifiers name didn't already exist, then just add it to the dictionary
			array.append(mod)
			mod_dict[mod.name] = array
	


# function to add a new abilities array and apply the new abilities to each object in the game
func add_new_abilities(_ability_list : Array):
	# TODO: Implement this function once abilities are implemented
	pass


# ====================== Functions that deal with Level Unlockable logic ======================


# function to return a list of potential level unlockables that can be initially generated
func get_initial_valid_unlockables():
	var initial_unlocks = {}
	# add any unlockable that have no pre-requisites to the list of initial unlocks
	for unlock in potential_unlockables:
		# create a temporary instantiation of the unlock so that it's initial attributes are accessible
		var temp_inst = unlock.new()
		# if there are no pre-requisite unlocks needed, then add the unlock to the array of initial unlocks
		if temp_inst.pre_reqs.size() == 0:
			initial_unlocks[temp_inst.name] = unlock
	return initial_unlocks


# function to update the list of valid unlockables after an unlockable was chosen
func update_valid_unlockables(chosen_unlock : LevelUnlockable):
	# Check to see if the chosen unlock can be chosen again
	if not chosen_unlock.repeatable:
		# the chosen unlock is not repeatable, remove it from the valid unlock dict
		valid_unlockables.erase(chosen_unlock.name)
	
	# Check to see if this unlockable belongs to a family
	var in_family = false
	if chosen_unlock.family != Consts.UnlockFamily_e.no_family:
		in_family = true
	
	# Check to see if any of the defined 'next unlocks' unlockables are valid
	for next_unlock in chosen_unlock.next_unlocks:
		# ensure that this next unlockable exists within the list of potential unlockables
		var is_potential = false
		for unlock in potential_unlockables:
			if unlock == next_unlock:
				is_potential = true
				break
		# create a temp instance of the next unlock to load its initial values
		var temp : LevelUnlockable = next_unlock.new()
		# check to see if all of this unlockables pre-reqs have been met
		var pre_reqs_met = true
		if is_potential:
			for unlock in temp.pre_reqs:
				# create a temp intance of the pre-req to load its initial values
				var temp2 : LevelUnlockable = unlock.new()
				# check to see if the unlockable has been unlocked
				if not active_unlockables.has(temp2.name):
					# if we have not unlocked this pre-req then disable the flag and break the loop
					pre_reqs_met = false
					break
		# if all the pre-reqs were met, and the next unlock exists within the set of potential unlocks, add it to the valid unlocks
		if is_potential and pre_reqs_met:
			valid_unlockables[temp.name] = next_unlock

	# if chosen unlockable belongs to a family, remove any valid unlockable belonging to a different branch of the same family
	if in_family:
		var names : Array = valid_unlockables.keys()
		for unlock_name in names:
			# create a temp instance of the Level Unlockable to load its initial values
			var temp : LevelUnlockable = valid_unlockables[unlock_name].new()
			# if the selected unlockable belongs to the same family but a different branch as the chosen ulockable, remove it
			if (temp.family == chosen_unlock.family) and (temp.branch != chosen_unlock.branch):
				valid_unlockables.erase(unlock_name)




#=============== timer expiration handlers =================


# This function is called by a timer when it's time to trigger another enemy spawn event
func _on_enemy_spawn_count_down_timeout():
	# reset the time until the next spawn event (catches if spawn rate changes mid game)
	$EnemySpawnCountDown.wait_time = enemy_spawn_rate

	# check to make sure we have room to spawn another enemy
	if active_enemies.size() < enemy_count_cap:
		#TODO:  check a list of possible spawn events and choose one
		# call the function to spawn the chosen type of enemy (test_enemy_0 is the only option atm)
		spawn_test_enemy(enemy_count_cap - active_enemies.size())
	
	
# This function is called when the level timer expires
func _on_level_timer_timeout():
	# The level timer will timeout once every second
	# increment the local amount of time that has passed
	time_passed_sec = time_passed_sec + 1
	# update the hud to display the current time in seconds
	level_hud.update_time(time_passed_sec)


# function to resume the game when the unpause timer expires
func _on_unpause_delay_timer_timeout():
	# emit the event to trigger game objects to resume
	control_time.emit(false)
	# allow the pause menu to work normally
	disable_paise_menu = false
	



