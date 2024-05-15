
"""
This Level Unlockable dramatically increases the rate sparks can be fired at
"""


class_name RapidFire extends LevelUnlockable


# function to initialize the base LevelUnlockable object with values that make it unique
func _init():

    # define values specific to this class
    name = "Rapid Fire Launchers"
    desc = "Dramatically increases the rate sparks can be fired at"
    family = Consts.UnlockFamily_e.spark_production
    branch = 0
    branch_name = "Quantity"
    repeatable = false
    pre_reqs = [OverclockedSparks]
    next_unlocks = [RepeatedHits]
    
    # initialize arrays of mods and abilities
    mods = []
    abilities = []

    # create and store a modifier to decrease the active ability cooldown time
    var active_abil = Mod.new()
    active_abil.name = "Rapid Fire Launchers: cooldown"
    active_abil.repeatable = false
    active_abil.mod_target = Consts.ModTarget_e.spark_source
    active_abil.mod_attribute = Consts.ModAttribute_e.active_abil_ct
    active_abil.mod_type = Consts.ModType_e.multiplier
    active_abil.mod_value = 0.2   # decreasese ability cooldown time by 80%
    mods.append(active_abil)

    # There is nothing else needed to define this unlockable
    pass