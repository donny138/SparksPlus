
"""
This is the base class for all spark source objects.

Each spark source object in the game will instantiate this class to track all the logical components
"""

# class to keep track of everything related to the spark source object
class_name BaseSparkSource

# attributes of every spark source class

# list of modifiers that apply to this spark source
var mod_list = []

# base stats of this spark source
# these values are set on initialization and then should not be changed directly
var base_speed
var base_spark_gen_rate
var base_health
var base_defense
var base_xp_mult
var base_spark_cap

# current stats of this spark source
# These stats will be updated on certain events so that calculations don't have to happen every time an operation occurs
var speed 
var spark_gen_rate
var health
var defense
var xp_mult
var spark_cap



# constructor for this class
func _init(_speed, _spark_gen_rate, _health, _defense, _xp_mult, _spark_cap):

    # initialize the base values of this spark source class
    base_speed = _speed
    base_spark_gen_rate = _spark_gen_rate
    base_health = _health
    base_defense = _defense
    base_xp_mult = _xp_mult
    base_spark_cap = _spark_cap

    # TODO: Add modifiers from external sources to the list of active mods

    # call the update function to initialize the current stats of this spark source class
    update_current_stats()



# function to add a new modifer to the spark source
func add_modifier(new_modifier):
    """Adds the provided modifier to this spark source. Returns true if this was successfull"""
    var status = true
    #TODO: add checks on any mods that shouldn't be added here?
    # if check fails, set status to false and 
    mod_list.append(new_modifier)

    #TODO: update the current stats of this spark source
    update_current_stats()

    return status


# function to create a new spark
func create_spark(_spark_type):
    """Creates a new spark if possible.  Returns the spark on success and a null type on failure"""
    #TODO: check to see if a spark can be generated
    #TODO: create a new spark object
    var new_spark = null
    #TODO: apply any spark related modifiers to the new spark
    #TODO: apply spark behavior on active and defensive ability use
    
    # return the spark object
    return new_spark


# function to update current stats of the spark source
func update_current_stats():
    """This function will use the base stats and any active modifiers to calculate the current stats of this spark source"""
    #TODO: Iterate through every active modifier and do the following:
    # - Determine what the modifier effects
    # - Add the modifier to a list of mods affecting the same stat

    #TODO:  For each statistic, calculate the value by passing the base value and the relevant list of mods into the calc_stat_value() function
    # - Set each current statistic to it's new value
    speed = calc_stat_value(base_speed, [])
    spark_gen_rate = calc_stat_value(base_spark_gen_rate, [])
    health = calc_stat_value(base_health, [])
    defense = calc_stat_value(base_defense, [])
    xp_mult = calc_stat_value(base_xp_mult, [])
    spark_cap = calc_stat_value(base_spark_cap, [])

    pass


# function to calculate a value of a statistic using a set of modifiers and a base value
func calc_stat_value(_base_stat_value, _mod_list):
    """This function calculates the modified value of a statistic and returns the new value of the statistic"""
    var stat_value = _base_stat_value

    #TODO: iterate through the list of mods and apply any mods that affect the base value

    #TODO: iterate through the list of mods and apply any multiplier affects

    #TODO: iterate through the list of mods and apply any flat value affects

    # return the modified value of the statistic
    return stat_value