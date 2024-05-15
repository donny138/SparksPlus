
"""
This Level Unlockable will increase the range at which the spark source can magnetize pickupables
"""


class_name PickUpRangeUp extends LevelUnlockable


# function to initialize the base LevelUnlockable object with values that make it unique
func _init():

    # define values specific to this class
    name = "PickUp-RangeUp"
    desc = "Increases the range that xp and other pickupables can be collected by 50%"
    family = Consts.UnlockFamily_e.no_family
    branch = 0
    branch_name = "Base"
    repeatable = true
    pre_reqs = []
    next_unlocks = []

    # initialize arrays of mods and abilities
    mods = []
    abilities = []

    # create and store a modifier to increase pickup range by 50%
    var range_up = Mod.new()
    range_up.name = "PickUp-RangeUp: Range"
    range_up.repeatable = true
    range_up.mod_target = Consts.ModTarget_e.spark_source
    range_up.mod_attribute = Consts.ModAttribute_e.pickup_range
    range_up.mod_type = Consts.ModType_e.multiplier
    range_up.mod_value = 1.50
    mods.append(range_up)

    # There is nothing else needed to define this unlockable
    pass
