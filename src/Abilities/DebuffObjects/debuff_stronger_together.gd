
"""
This abilty object represents the "Stronger Together" debuff which can be applied to enemies

This debuff increases the amount of damage an enemy receives from attacks every time it is applied.
This debuff lasts for up to 5 seconds, but this timer refreshes every time the debuff is applied, so it
will only expire if the enemy has not been hit for at least 5 seconds

This debuff will reduce the enemies defence by 5% per stack, maxing out at a 95% reduction 

This object requires that it's parent object has an "active_debuffs" list
This object requires that it's parent object has a "mods" dict with it's name as the key and an array of mods as the value
This object requires that it's parent object has a working "update_attributes()" function
"""

class_name DebuffStrongerTogether extends BaseAbilityObject

# attributes exclusive to this debuff
var stack_count : int			# this stores how many stacks of the debuff are active
var debuff_mod : Mod			# this stores the modifier that is applied to the enemy which allows this debuff to function
@export var life_time : int		# this is how long the debuff will last before it expires (seconds)


# Called when the node enters the scene tree for the first time.
func _ready():
	# this ability object is related to the "Stronger Together" Level Unlockable
	ability_name = "Stronger Together"
	# this ability is a debuff
	ability_type = Consts.AbilityType_e.debuff
	# this ability is triggered under specific circumstances which are managed by other objects
	ability_activation_type = Consts.AbilityActivationType_e.passive
	# save a pointer to the parent object 
	parent = get_parent()
	# save a pointer to the level scene object
	level_scene = parent.level_scene
	# bind the control time signal to this object
	level_scene.control_time.connect(handle_control_time)

	# add this object to the list of active debuffs on the parent object
	parent.active_debuffs.append(self)

	# there are intially zero instances of the debuff on the enemy
	stack_count = 0

	# configure and activate the lifetime timer for this debuff
	$LifeTime.wait_time = life_time
	$LifeTime.start()

	# create the debuff modifier that is applied to the enemy
	debuff_mod = Mod.new()
	debuff_mod.name = ability_name
	debuff_mod.repeatable = true
	debuff_mod.mod_target = Consts.ModTarget_e.enemy
	debuff_mod.mod_attribute = Consts.ModAttribute_e.defense	# this debuff reduces how much defense the enemy has
	debuff_mod.mod_type = Consts.ModType_e.multiplier			# this debuff will be added as a multiplier to the enemies defense
	debuff_mod.mod_value = 0.95									# this initially provides a 5% reduction to the defense value of the enemy

	# activate the ability to apply the first stack of the debuff to the enemy
	activate_ability(self)  # self is not needed by the call, but is added to keep the function happy


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass



# ================  Callable functions ===============


# override the activate ability function in the base class to 
func activate_ability(_target : Node2D) -> bool:
	"""
	Applies an instance of the debuff modifier to the enemy
	Refreshes the expiration timer
	Returns true if the magnitude of the debuff was increased, false if the debuff was already maxed out
	"""
	var success_status = true

	# pause the lifetime timer
	$LifeTime.stop()

	# increment the number of debuffs that are active
	stack_count = stack_count + 1

	# calculate the defence reduction of the debuff
	var reduction = 0.05 * stack_count
	debuff_mod.mod_value = 1.0 - reduction
	# debug print
	print(self, " Debuff proc ", stack_count, " Times!")
	print()

	# special behavior if this is the first instance of this object
	if stack_count == 1:
		# add the initial instance of this debuff to the enemy
		parent.mods[debuff_mod.name] = [debuff_mod]
		# tell the parent object to recalculate it's attributes
		parent.update_attributes()

	# This debuff maxes out at a 95% armor reduction rate, no additional instances should be added after this point
	elif not(debuff_mod.mod_value <= 0.05):
		# replace the instance of this debuff with a stronger version
		var active_debuffs = parent.mods.get(debuff_mod.name)
		active_debuffs[0] = debuff_mod
		# tell the parent object to recalculate it's attribtues
		parent.update_attributes()
	
	# If the debuff cannot be increased any further, flag this behavior
	else:
		success_status = false
	
	# refresh the lifetime of the debuff and resume the lifetime timer
	$LifeTime.wait_time = life_time
	$LifeTime.start()

	# returns true if the magnitude of the debuff was increased
	return success_status


# override the function to remove this ability from the game
func remove_ability():
	# This is called automatically when the LifeTime timer emits the "timeout()" signal

	# debug print
	print(self, " DEBUFF EXPIRED!")
	# remove the debuff modifier from the parent
	parent.mods.erase(debuff_mod.name)
	# tell the parent to recalculate it's attributes to account for the debuff being gone
	parent.update_attributes()
	# remove the pointer to this object from the list of active debuffs on the enemy
	parent.active_debuffs.erase(self)
	
	# call the base class method to handle deleting this object from memory
	super()


# override of the handle control time function from the base class to include the timer
func handle_control_time(freeze_time : bool):
	# pause or resume the lifetime timer depending on the input
	$LifeTime.set_paused(freeze_time)
	# pass the freeze_time to the base class method to handle setting the is_paused flag
	super(freeze_time)

