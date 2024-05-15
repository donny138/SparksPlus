
"""
This Level Unlockable increases the speed sparks travel at and makes quick successive hits deal bonus damage
"""


class_name RepeatedHits extends LevelUnlockable


# function to initialize the base LevelUnlockable object with values that make it unique
func _init():

    # define values specific to this class
    name = "Death by a Thousand Cuts"
    desc = "Sparks fly 25% faster and apply a debuff to enemies that increases the damage they take from sparks by 20% a stack"
    family = Consts.UnlockFamily_e.spark_production
    branch = 0
    branch_name = "Quantity"
    repeatable = false
    pre_reqs = [SwarmingSparks, RapidFire]
    next_unlocks = []
    
    # initialize arrays of mods and abilities
    mods = []
    abilities = []

    # create and store a modifier to increase the speed sparks fly by 25%
    var spark_prod = Mod.new()
    spark_prod.name = "Death by a Thousand Cuts: speed"
    spark_prod.repeatable = false
    spark_prod.mod_target = Consts.ModTarget_e.spark
    spark_prod.mod_attribute = Consts.ModAttribute_e.speed
    spark_prod.mod_type = Consts.ModType_e.multiplier
    spark_prod.mod_value = 1.25  
    mods.append(spark_prod)

    # create and store an ability that applies a debuff which buffs successive hits by 20% a stack
    # TODO: Implement this once abilities have been implemented

    # There is nothing else needed to define this unlockable
    pass