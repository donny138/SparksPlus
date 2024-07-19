
"""
This is the base class for an ability object

An ability object is any object that can be created and applied to another game object.
This includes debuffs, new abilities, on-hit effects, pretty much anything that can be dynamically
applied to an existing object within the game during gameplay. 

This class should not be used directly.  Derived (extended) classes should be called instead

The name of the ability will be used for logging damage or other statistics, so abilities sharing a name
will count towards the same statistics.
"""

# class extends attributes of a node so that derived classes have access to all the node things if needed
class_name BaseAbilityObject extends Node2D


# attributes of AbilityObject classes
var ability_name : String                                       # This is the name of the ability
var ability_type : Consts.AbilityType_e                         # This describes what kind of ability / effect this object does
var ability_activation_type : Consts.AbilityActivationType_e    # This describes how this ability is activated
var parent : Node                                               # This is a pointer to the parent object of this ability
var level_scene : LevelScene                                    # pointer to the main level scene object that controls the game

var is_paused : bool = false                                    # This tracks if time passes for this object


# ============ generic functions of ability objects ============
# These can be overriden by derived classes as needed


# function to activate the ability
# This should be overriden by derived classes to do whatever behavior needs to be done by the ability
# This can remain unused by an ability if it passively has some effect
func activate_ability(_target : Node2D) -> bool:
	"""
	Returns true if successfully activated, false if it does not activate
	Takes a target as input if needed by certain abilities
	"""
	# the base class doen't do anything and should always flag failure to do anything
	var success_status = false
	return success_status


# function to remove this ability object from the game
func remove_ability():
	"""
	Removes the ability object from the game completely
	"""
	# base function only removes this ability 
	# derived classes will likely need extra behavior here to clean up modifiers, other objects, or tracking of this object from within the game.
	# can call "super()" to trigger this function once any extra needed behavior within the overriding function is done
	queue_free()


# function to allow this object to be frozen / paused
func handle_control_time(freeze_time : bool):
	"""
	Freezes / pauses or resumes time for this object depending on input
	"""
	# override with derived function for extra behavior as needed
	if freeze_time:
		# time stops for this object
		is_paused = true
	else:
		# time resumes for this object
		is_paused = false

