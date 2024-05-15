
"""
This Level Unlockable will increase the rate at which sparks are generated and raises the spark cap
at the cost of reducing the damage each spark deals
"""


class_name SwarmingSparks extends LevelUnlockable


# function to initialize the base LevelUnlockable object with values that make it unique
func _init():

    # define values specific to this class
    name = "A Swarm of Sparks"
    desc = "Increases spark production speed by 30%, raises the spark cap by 10, but each spark deals 50% less damage"
    family = Consts.UnlockFamily_e.spark_production
    branch = 0
    branch_name = "Quantity"
    repeatable = false
    pre_reqs = [OverclockedSparks]
    next_unlocks = [RepeatedHits]
    
    # initialize arrays of mods and abilities
    mods = []
    abilities = []

    # create and store a modifier to increase the speed of spark production by 30%
    var spark_prod = Mod.new()
    spark_prod.name = "A Swarm of Sparks: production"
    spark_prod.repeatable = false
    spark_prod.mod_target = Consts.ModTarget_e.spark_source
    spark_prod.mod_attribute = Consts.ModAttribute_e.spark_gen
    spark_prod.mod_type = Consts.ModType_e.multiplier
    spark_prod.mod_value = 0.70  # this modifies the time it takes to make a spark, so 70% of some value is a 30% speedup
    mods.append(spark_prod)

    # create and store a modifier to raise the base spark cap of the players spark source by 10
    var active_abil = Mod.new()
    active_abil.name = "A Swarm of Sparks: cap"
    active_abil.repeatable = false
    active_abil.mod_target = Consts.ModTarget_e.spark_source
    active_abil.mod_attribute = Consts.ModAttribute_e.spark_cap
    active_abil.mod_type = Consts.ModType_e.base_value
    active_abil.mod_value = 10
    mods.append(active_abil)

    # create and store a modifier to decrease the damage a spark does by 50%
    var spark_dmg = Mod.new()
    spark_dmg.name = "A Swarm of Sparks: damage"
    spark_dmg.repeatable = false
    spark_dmg.mod_target = Consts.ModTarget_e.spark
    spark_dmg.mod_attribute = Consts.ModAttribute_e.damage
    spark_dmg.mod_type = Consts.ModType_e.multiplier
    spark_dmg.mod_value = 0.5
    mods.append(spark_dmg)

    # There is nothing else needed to define this unlockable
    pass