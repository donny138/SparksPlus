
"""
This class exists to represent a modifier that can be applied to a variety of game objects
"""


# class to contain all the modifier info
class_name SparkMod


# enumerations that are important to identify aspects of modifiers

# This defines valid objects that can have modifiers
enum mod_object_e {
    SPARK,
    SPARK_SOURCE,
    ENEMY
}

# This defines valid stats that can be targeted by modifications
enum mod_target_e {
    SPEED,
    SPARK_GEN_RATE,
    HEALTH,
    DEFENSE,
    SPARK_CAP
}

# This defines valid types of modifiers that can be applied.  This affects how the modifier is applied when calculating stats
enum mod_type_e {
    BASE,       # base mods are added to the base value at the start of calculations
    MULT,       # mult mods multiply the base value during the middle of calculations
    FLAT        # falt mods are added to the final value at the end of calculations
}


# attributes of an instance of this class

var mod_id  # this is an identifier to keep track of this modifier if needed
var object  # this tracks the type of object that this modifier will affect
var target  # this tracks the attribute that this modifier will affect
var type    # this tracks how the modifier affects the calculation



# constructor for this class
func _init(_mod_id):
    # store the mod id
    mod_id = _mod_id


# function to set attributes of this modifier (need enumerations so can't be done externally in constructor)
func set_mods(_object, _target, _type):
    """This function will set attributes of the modifier to control what it affects and how"""
    #TODO:  Add error checking?  Inputs should only be valid values of the known enumerations
    object = _object
    target = _target
    type = _type

