
"""
This Level Unlockable will increase spark speed and damage
"""


class_name RocketSparks extends LevelUnlockable


# function to initialize the base LevelUnlockable object with values that make it unique
func _init():

    # define values specific to this class
    name = "Rocket-Like Sparks"
    desc = "Sparks can fly 50% faster and do +5 additional damage when they collide with enemies"
    repeatable = false
    pre_reqs = []
    next_unlocks = []
    
    # initialize arrays of mods and abilities
    mods = []
    abilities = []

    # create and store a modifier to increase the movement speed of sparks by 50%
    var spark_spd = Mod.new()
    spark_spd.name = "Rocket-Like Sparks"
    spark_spd.repeatable = true
    spark_spd.mod_target = Consts.ModTarget_e.spark
    spark_spd.mod_attribute = Consts.ModAttribute_e.speed
    spark_spd.mod_type = Consts.ModType_e.multiplier
    spark_spd.mod_value = 1.50
    mods.append(spark_spd)

    # create and store a modifier to add a flat +5 extra damage to sparks
    var spark_dmg = Mod.new()
    spark_dmg.name = "Rocket-Like Sparks"
    spark_dmg.repeatable = true
    spark_dmg.mod_target = Consts.ModTarget_e.spark
    spark_dmg.mod_attribute = Consts.ModAttribute_e.damage
    spark_dmg.mod_type = Consts.ModType_e.flat_add
    spark_dmg.mod_value = 5
    mods.append(spark_dmg)

    # There is nothing else needed to define this unlockable
    pass
