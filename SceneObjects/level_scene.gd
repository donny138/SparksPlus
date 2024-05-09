
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
var active_level_unlockables = [] # a list of level unlockables that the player has activated and how many many times they have been chosen

# modifiers and ability attributes
var level_mods = []
var enemy_mods = []
var level_abilities = []
var enemy_abilities = []

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

	# TODO: implement random level unlockable selection once modifiers exist
	# randomly pick 3 available level unlockables (TODO make random)
	var fake_mod_list = [
		temp_valid_unlockables[0].new(),
		temp_valid_unlockables[1].new(),
		temp_valid_unlockables[2].new()
	]
	# Pass the level unlockables off to the level up gui (it will associate each option with a button and display the description)
	level_up_gui.load_level_unlock_options(fake_mod_list)

	# tell the level up gui to un-hide itself and wait for the user to click one of the options
	level_up_gui.enable_gui()


# function to apply the selected mod from the level up event and flag it as complete
func finish_level_up_event(chosen_unlock : LevelUnlockable):
	#TODO:  flush out this behavior once mods are actually added
	#print("Selected Mod: ", chosen_unlock)

	# Add this level unlockable to the list of activated unlockables
	var repeat_unlock = false
	for unlock : Array in active_level_unlockables:
		# if the unlockable is already in the list of chosen unlockables, add one to the number of times it has been picked
		if unlock[0] == chosen_unlock.name:
			unlock[1] = unlock[1] + 1
			repeat_unlock = true
			print(chosen_unlock.name, " Has been unlocked ", unlock[1], " times!")
	# if the unlock was not already present in the list, add it to the end
	if not repeat_unlock:
		var entry = [
			chosen_unlock.name,
			1
		]
		active_level_unlockables.append(entry)
		print(chosen_unlock.name, " Has been unlocked for the first time!")

	# Add Modifiers from the chosen unlock to the spark source
	var new_mods = Consts.filter_mods_by_target(chosen_unlock.mods, Consts.ModTarget_e.spark_source)
	for mod : Mod in new_mods:
		spark_source.spark_source_mods.append(mod)
	
	# Add Modifiers from the chosen unlock to the spark mod list on the spark source
	new_mods = Consts.filter_mods_by_target(chosen_unlock.mods, Consts.ModTarget_e.spark)
	for mod : Mod in new_mods:
		spark_source.spark_mods.append(mod)
	
	# Add Modifiers from the chosen unlock to the level 
	new_mods = Consts.filter_mods_by_target(chosen_unlock.mods, Consts.ModTarget_e.level)
	for mod : Mod in new_mods:
		level_mods.append(mod)
	
	# Add Modifiers from the chosen unlock to the enemy mod list within the level
	new_mods = Consts.filter_mods_by_target(chosen_unlock.mods, Consts.ModTarget_e.enemy)
	for mod : Mod in new_mods:
		enemy_mods.append(mod)

	# tell the spark source to update it's current attributes to make sure that they account for the new modifiers
	spark_source.update_attributes()

	# TODO: Add Abilities to arrays in the level and on the spark source

	
	# resume time
	
	# start the unpause delay timer so that there is a small delay after the gui goes away before time resumes
	$UnpauseDelayTimer.start()



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
	



