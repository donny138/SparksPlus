
"""
This Level Unlockable will increase the rate at which sparks are generated and can be fired using the active ability
"""


class_name OverclockedSparks extends LevelUnlockable


# function to initialize the base LevelUnlockable object with values that make it unique
func _init():

    # define values specific to this class
    name = "Overclocked Spark Systems"
    desc = "Increases spark production speed by 30% and decreases the active ability cooldown by 50%"
    repeatable = false
    pre_reqs = []
    next_unlocks = []
    
    # initialize arrays of mods and abilities
    mods = []
    abilities = []

    # create and store a modifier to increase the speed of spark production by 30%
    var spark_prod = Mod.new()
    spark_prod.name = "Overclocked Spark Systems"
    spark_prod.repeatable = true
    spark_prod.mod_target = Consts.ModTarget_e.spark_source
    spark_prod.mod_attribute = Consts.ModAttribute_e.spark_gen
    spark_prod.mod_type = Consts.ModType_e.multiplier
    spark_prod.mod_value = 0.70  # this modifies the time it takes to make a spark, so 70% of some value is a 30% speedup
    mods.append(spark_prod)

    # create and store a modifier to decrease the active ability cooldown time
    var active_abil = Mod.new()
    active_abil.name = "Overclocked Spark Systems"
    active_abil.repeatable = true
    active_abil.mod_target = Consts.ModTarget_e.spark_source
    active_abil.mod_attribute = Consts.ModAttribute_e.active_abil_ct
    active_abil.mod_type = Consts.ModType_e.multiplier
    active_abil.mod_value = 0.50
    mods.append(active_abil)

    # There is nothing else needed to define this unlockable
    pass
