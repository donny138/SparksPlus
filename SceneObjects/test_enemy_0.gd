
"""
This script controls the AI for a placeholder enemy

This is a generic enemy that will always follow the player around the map

TODO:
	- add collision between enemies
	- add ability for them to be hit by sparks
"""

class_name Base_Enemy extends RigidBody2D

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
@export var base_health = 10		# this is the amount of health this enemy has
@export var base_speed = 100		# this is how fast the enemy will move
@export var base_damage = 5			# this is how much damage the enemy will do if it hits the player
@export var base_attack_ct = 0.5 	# this is the attack cooldown time for this enemy
@export var base_defense = 1.0		# this is how much incomming attack damage is divided by before affecting health
@export var enemy_name : String 	# this is the name of this kind of enemy


# temp configurable attributes
@export var xp_orb : PackedScene
@export var xp_orb_count_min : int
@export var xp_orb_count_max : int

# internal game attributes
var max_health						# tracks the maximum amount of health this enemy can have
var cur_health						# tracks the current amount of health this enemy has
var cur_speed						# the current speed (pixels / second) this enemy moves at
var cur_damage						# the current damage the enemy deals on hit
var cur_attack_ct					# the current cooldown between enemy attacks
var cur_defense						# the current value of this objects defense

# local modifiers and abilities
var mods = {}						# tracks the dict of modifiers that apply to this enemy object
var abilities = []					# tracks the list of abilities that apply to this enemy object

# internal attributes of this enemy
var rot_rate = TAU/4 				# this is how fast the enemy rotates
var rot_dir = 0						# this affects the direction of rotation
var active_debuffs = []				# a list of debuffs currently affecting the enemy (damage over time, slow, etc)
var spark_source 					# this is a pointer to the spark source object (the player)
var level_scene						# this is a pointer to the level scene object that runs the game
var is_attack_available = true 		# this controls whether or not this enemy can hit the player
var is_alive : bool					# tracks if the enemy is alive

# variable to track if time passes for this object or not
var is_paused


# Called when the node enters the scene tree for the first time.
func _ready():
	# save pointer to the level scene object
	level_scene = get_parent()

	# initialze the current and max health of the enemy
	max_health = base_health
	cur_health = max_health

	# update attributes based on modifiers and base stats
	update_attributes()

	# make sure collision is enabled
	$CollisionShape2D.disabled = false

	# initialize the attack cooldown time to the starting value
	cur_attack_ct = base_attack_ct
	$AttackCooldown.wait_time = cur_attack_ct

	# choose a random direction that this enemy will rotate in
	while rot_dir == 0:
		rot_dir = randi_range(-1, 1)
	
	# the enemy starts out alive
	is_alive = true
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
	var was_hit = false
	# it's possible for two sparks to hit the enemy in the same frame, so detect if we are still alive
	if (is_alive):
		# handle being hit by the spark
		was_hit = true
		# take damage based on the damage that the given spark object will deal
		var dmg = (spark.cur_damage / cur_defense)
		cur_health = cur_health - dmg
		# if dmg text is enabled, then display the dmg
		if level_scene.enable_dmg_text:
			var dmg_text = level_scene.dmg_text_scene.instantiate()
			dmg_text.position = position
			dmg_text.position.y = dmg_text.position.y - 50
			dmg_text.position.x = dmg_text.position.x - 25
			dmg_text.display_dmg(dmg)
			level_scene.add_child(dmg_text)
		# if hp has run out, then the enemy dies
		if cur_health <= 0:
			on_death()
	
	# return a status indicating if the attack hit the enemy or not
	return was_hit


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
		$AttackCooldown.wait_time = cur_attack_ct
		$AttackCooldown.start()


#TODO:  modify this to add additional on death behavior
# function to handle any special behavior when this enemy dies
func on_death():
	is_alive = false
	# spawn xp orbs on death
	# TODO: pull this from a different place than a predefined scene object
	var new_xp_orb
	for i in range(randi_range(xp_orb_count_min, xp_orb_count_max)):
		new_xp_orb = xp_orb.instantiate()
		new_xp_orb.position = position
		# put the xp orb in as a child of the level
		get_parent().call_deferred("add_child", new_xp_orb)

	# tell the level to remove this enemy from the list of active enemies
	get_parent().call_deferred("remove_active_enemy", self)

	# remove this object from the game
	self.call_deferred("queue_free")




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
			$AttackCooldown.wait_time = cur_attack_ct
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



# =================== Functions to handle modifier related stuffs =============================


# function to update all of the spark sources current attributes based on it's base value and it's list of modifiers
func update_attributes():
	# this function assumes that all lists of modifers are up to date

	# combine the global and local list of modifiers that should apply to this enemy
	var all_mods = {}
	# get all the mods from the global list of modifiers
	for mod_list : Array in level_scene.enemy_mods.values():
		for mod : Mod in mod_list:
			var attribute = mod.mod_attribute
			# get the list of modifers that affect this attribute
			var array = all_mods.get(attribute, [])
			array.append(mod)
			# if this is a new list, add it to the dictionary
			if array.size() == 1:
				all_mods[attribute] = array
	# get all the mods from the local list of modifiers
	for mod_list : Array in mods.values():
		for mod : Mod in mod_list:
			var attribute = mod.mod_attribute
			# get the list of modifers that affect this attribute
			var array = all_mods.get(attribute, [])
			array.append(mod)
			# if this is a new list, add it to the dictionary
			if array.size() == 1:
				all_mods[attribute] = array
	
	# Get the modifiers that should apply to each attribute and apply them to the enemies current attribute

	# Modify Health
	var health_mods = all_mods.get(Consts.ModAttribute_e.health, [])
	var health_ratio = cur_health / max_health
	max_health = Consts.calc_mods(health_mods, base_health)
	# the current health should (percentage wise) be the same as before the mod was applied
	cur_health = max_health * health_ratio

	# Modify Speed
	var speed_mods = all_mods.get(Consts.ModAttribute_e.speed, [])
	cur_speed = Consts.calc_mods(speed_mods, base_speed)

	# Modify Damage
	var damage_mods = all_mods.get(Consts.ModAttribute_e.damage, [])
	cur_damage = Consts.calc_mods(damage_mods, base_damage)

	# Modify Attack Cooldown
	var attack_ct_mods = all_mods.get(Consts.ModAttribute_e.active_abil_ct, [])
	cur_attack_ct = Consts.calc_mods(attack_ct_mods, base_attack_ct) # gets set when the enemy hits an attack, don't need to set timer value here

	# Modify Defense
	var defense_mods = all_mods.get(Consts.ModAttribute_e.defense, [])
	cur_defense = Consts.calc_mods(defense_mods, base_defense)







