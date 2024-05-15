
"""
This Level Unlockable increases the base speed of the spark source by 25 pixels / second
"""


class_name SourceSpeed extends LevelUnlockable


# function to initialize the base LevelUnlockable object with values that make it unique
func _init():

    # define values specific to this class
    name = "Improved Thrusters"
    desc = "Increases your spark sources movement speed by 25 pixels a second"
    family = Consts.UnlockFamily_e.no_family
    branch = 0
    branch_name = "Base"
    repeatable = true
    pre_reqs = []
    next_unlocks = []
    
    # initialize arrays of mods and abilities
    mods = []
    abilities = []

    # create and store a modifier to increase the movement speed of the spark source by 25 pixels a second
    var speed = Mod.new()
    speed.name = "Improved Thrusters: speed"
    speed.repeatable = true
    speed.mod_target = Consts.ModTarget_e.spark_source
    speed.mod_attribute = Consts.ModAttribute_e.speed
    speed.mod_type = Consts.ModType_e.base_value
    speed.mod_value = 25 
    mods.append(speed)

    # There is nothing else needed to define this unlockable
    pass