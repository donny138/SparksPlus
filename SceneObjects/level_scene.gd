
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
var active_enemies = []		# a list of enemy objects that are currently active

var pause_menu_active = false


# Called when the node enters the scene tree for the first time.
func _ready():
	# configure the enemy spawn timer
	$EnemySpawnCountDown.wait_time = enemy_spawn_rate
	# store a pointer to the spark source object
	spark_source = $SparkSource

	# connect to the time control signal
	control_time.connect(handle_control_time)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	# debug event handling for the pause menu
	if Input.is_action_just_pressed("pause_menu"):
		# if the pause menu is not active, activate it. If it is, deactivate it
		control_time.emit(not pause_menu_active)
		pause_menu_active = not pause_menu_active




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
	print("Added enemy #", active_enemies.size(), " at: ", spawn_point)



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
	
	
	




