
"""
This is the ability object that allows the "Stronger Together" Debuff to be applied on hit
"""

class_name OnHit_Stronger_Together extends BaseAbilityObject

# attributes of the class
var stronger_together_debuff = preload("res://src/Abilities/DebuffObjects/debuff_stronger_together.tscn")
var debuff_class = DebuffStrongerTogether


# Called when the node enters the scene tree for the first time.
func _ready():
	# this ability object is related to the "Stronger Together" Level Unlockable
	ability_name = "Stronger Together"
	# this ability adds new behavior to the game
	ability_type = Consts.AbilityType_e.new
	# this abilities effect will trigger on hit
	# NOTE:  This tells the game to call this objects "activate_ability()" function when the spark hits something
	ability_activation_type = Consts.AbilityActivationType_e.on_hit

	# save a pointer to the parent object 
	parent = get_parent()
	# add this to the dictionary of active abilities on the parent object
	var parent_abilities = parent.abilities.get(ability_activation_type, [])
	parent_abilities.append(self)
	if len(parent_abilities) == 1:
		parent.abilities[ability_activation_type] = parent_abilities

	# save a pointer to the level scene object
	level_scene = parent.level_scene
	# bind the control time signal to this object
	level_scene.control_time.connect(handle_control_time)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


# override the active ability function
func activate_ability(target : Node2D) -> bool:
	"""
	the target must have a "active_debuffs" attribute
	"""
	var success_status = true

	# check to see if an instance of the debuff already exists on the enemy
	var exists = false
	var object : DebuffStrongerTogether
	for debuff in target.active_debuffs:
		if debuff.ability_name == ability_name:
			exists = true
			object = debuff
			break
	
	# if there was not an existing instance of the debuff, add one to the target
	if not(exists):
		object = stronger_together_debuff.instantiate()
		target.add_child(object)
		# (this will add the inital stack of the debuff)
	# if there is an existing intance of the debuff, activate it's ability to add another stack of the debuff to the target
	else:
		success_status = object.activate_ability(object)	# argument provided but unused by function

	# return true if the target received a new stack of the debuff, will be false if no further stacks can be applied to the target
	return success_status

