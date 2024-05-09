
"""
This class exists to represent a modifier(s) or ability that the player can pick and apply to their run mid-level.

This is a base class for common functionality between level unlockable classes and interfacing with the rest of the game

This class will store the following:
    - The name and description of this unlockable
    - Any mandatory pre-requisites required for this ulockable to be available
    - Any unlockables that picking this unlockable should unlock (assuming all mandatory pre-requisites are met)
    - a flag indiating if the unlockable is selectable more than once or if it isn't
    - A list of modifier objects that should be applied when this unlockable is chosen
    - A list of abilities (or game rules) that should be applied when this unlockable is chosen
"""

# class to represent all the things
class_name LevelUnlockable


# internal attributes of a Level Unlockable class
var name : String           # This is the name of the Unlockable and also uniquely identifies it
var desc : String           # This is a description of what this unlockable does
var repeatable : bool       # This flag indiates whether this unlockable can be aquired more than once or not
var pre_reqs : Array        # This is a list of other LevelUnlockables that must be unlocked before this becomes available
var next_unlocks : Array    # This is a list of other LevelUnlockables to make available (if able) once this ulockable has been picked
var mods : Array            # This is a list of modifiers to apply to the game when this unlockable is picked
var abilities : Array       # This is a list of abilities to apply to the game when this unlockable is picked




# ====================== Common Functions For LevelUnlockable classes ==================================


# TODO: move functions here as needed, could add parsing to mod lists or extra conditional behavior




