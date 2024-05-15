
"""
This Level Unlockable increases the health of the spark source by 10%
"""


class_name SourceHealth extends LevelUnlockable


# function to initialize the base LevelUnlockable object with values that make it unique
func _init():

    # define values specific to this class
    name = "Robust Defenses"
    desc = "Increases the health of your spark source by 10%"
    family = Consts.UnlockFamily_e.no_family
    branch = 0
    branch_name = "Base"
    repeatable = true
    pre_reqs = []
    next_unlocks = []
    
    # initialize arrays of mods and abilities
    mods = []
    abilities = []

    # create and store a modifier to increase the health of the spark source by 10%
    var health = Mod.new()
    health.name = "Robust Defense: health"
    health.repeatable = true
    health.mod_target = Consts.ModTarget_e.spark_source
    health.mod_attribute = Consts.ModAttribute_e.health
    health.mod_type = Consts.ModType_e.multiplier
    health.mod_value = 1.1
    mods.append(health)

    # There is nothing else needed to define this unlockable
    pass