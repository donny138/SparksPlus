
"""
This script controls the AI for a placeholder enemy

This is a generic enemy that will always follow the player around the map

TODO:
	- add collision between enemies
	- add ability for them to be hit by sparks
"""

extends RigidBody2D

# TODO:
# - create an attribute class to track the stats and modifiers of a generic enemy
# 		- this should replace all the stat stuff here
# 		- this should be common and useable for any number of enemies
#
# - create an AI class that is in charge of moving / continuous behavior
#		- generc and useable for multiple enemies with the same kind of behavior
#
# - Work out where to implement death behavior.  Should be enemy specific, but run at level level


# Configurable attributes of this enemy
@export var health = 10		# this is the amount of health this enemy has
@export var speed = 100		# this is how fast the enemy will move
@export var damage = 5		# this is how much damage the enemy will do if it hits the player
@export var enemy_name : String # this is the name of this kind of enemy
@export var rot_rate = TAU/4 # this is how fast the enemy rotates
@export var rot_dir = 0		# this affects the direction of rotation
@export var attack_ct = 0.5 # this is the attack cooldown time for this enemy

# internal attributes of this enemy
var cur_health				# tracks the current amount of health this enemy has
var max_health				# tracks the maximum amount of health this enemy can have
var cur_speed				# the current speed (pixels / second) this enemy moves at
var cur_damage				# the current damage the enemy deals on hit
var active_debufs = []		# a list of debuffs currently affecting the enemy (damage over time, slow, etc)
var spark_source 			# this is a pointer to the spark source object (the player)
var is_attack_available = true # this controls whether or not this enemy can hit the player

# variable to track if time passes for this object or not
var is_paused


# other attributes of the enemy
var mod_list = []  			# this is a list of modifiers relevant to this enemy


# Called when the node enters the scene tree for the first time.
func _ready():
	#TODO:  Initialize attribute manager with base values for this enemy
	# 		- Pass initial modifiers to the attribute manager

	# make sure collision is enabled
	$CollisionShape2D.disabled = false

	# initialize the attack cooldown time to the starting value
	$AttackCooldown.wait_time = attack_ct

	# choose a random direction that this enemy will rotate in
	while rot_dir == 0:
		rot_dir = randi_range(-1, 1)
	
	# temporary code that should be configured elsewhere
	max_health = health
	cur_health = max_health
	cur_speed = speed
	
	# connect to the time control signal
	get_parent().control_time.connect(handle_control_time)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# do not allow time to pass if this object is paused
	if is_paused:
		linear_velocity = Vector2.ZERO
		angular_velocity = 0.0
		return
	#TODO:  pass delta to the "AI behavior" class for movement behavior calculations instead of doing these here

	# calculate the direction that the spark source is in 
	var angle_to_spark_source = position.direction_to(spark_source.position)

	# update the enemies velocity
	var raw_velocity = (cur_speed * angle_to_spark_source)
	#linear_velocity =  raw_velocity.rotated(rotation * -1)
	linear_velocity = raw_velocity

	# Update the enemies rotation based on it's rotation rate
	#rotation = rotation + (rot_rate * rot_dir)
	angular_velocity = rot_rate * rot_dir
	pass


# function that gets called when a spark hits this object
func got_hit(spark):
	# take damage based on the damage that the given spark object will deal
	cur_health = cur_health - spark.damage
	
	# if hp has run out, then the enemy dies
	if cur_health <= 0:
		print("THE ENEMY HAS BEEN SLAIN")
		on_death()


# function to manage hitting the spark source
func hit_spark_source():
	# The only body the enemy needs to care about entering is the spark source
	print("SOURCE HIT")
	# attack the spark source if we are able
	if is_attack_available:
		# trigger hit behavior on the spark source
		spark_source.hit_by_enemy(self)
		# flag this enemies attack to be unuseable
		is_attack_available = false
		# start the attack cooldown timer (will re-enable the attack after a duration)
		$AttackCooldown.wait_time = attack_ct
		$AttackCooldown.start()


#TODO:  modify this to add additional on death behavior
# function to handle any special behavior when this enemy dies
func on_death():
	# TODO:  drop xp / do on death things

	# tell the level to remove this enemy from the list of active enemies
	get_parent().remove_active_enemy(self)

	# remove this object from the game
	queue_free()







#================= Functions triggered by events ====================

# This function is activated when a physical body enters the enemy
func _on_body_entered(body):
	# The only body the enemy needs to care about entering is the spark source
	print("hit body")
	if body == spark_source:
		print("SOURCE HIT")
		# attack the spark source if we are able
		if is_attack_available:
			# trigger hit behavior on the spark source
			spark_source.hit_by_enemy(self)
			# flag this enemies attack to be unuseable
			is_attack_available = false
			# start the attack cooldown timer (will re-enable the attack after a duration)
			$AttackCooldown.wait_time = attack_ct
			$AttackCooldown.start()


# This function is called when the attack cooldown timer for this enemy exipres
func _on_attack_cooldown_timeout():
	# make this enemies attack useable again
	is_attack_available = true


# function to handle controlling time.  This should be connected to the "control time signal" within the level
func handle_control_time(freeze_time):
	# freeze time or resume time depending on the given input
	# pause or unpause all active timers
	$AttackCooldown.set_paused(freeze_time)
	if freeze_time:
		# enable the is_paused flag
		is_paused = true
	else:
		# disable the is_paused flag
		is_paused = false



# ========== functions that should be moved to the common internal generic enemy attribute manager class ================


# This function adds a list of modifiers to this enemy
func add_mod_list():
	pass


# This funciton adds a single modifier to this enemy
func add_single_mod():
	pass


# This function updates the stats of the enemy to apply all active modifiers.  This should be called whenever a modifier is added or removed
func update_cur_stas():
	pass






