
"""
This class exists to represent a modifier(s) or ability that the player can pick and apply to their run mid-level.

This is a base class for common functionality between level unlockable classes and interfacing with the rest of the game

This class will store the following:
    - The name and description of this unlockable
    - The family and the branch of that family that the unlock belongs to
    - Any mandatory pre-requisites required for this ulockable to be available
    - Any unlockables that picking this unlockable should unlock (assuming all mandatory pre-requisites are met)
    - a flag indiating if the unlockable is selectable more than once or if it isn't
    - A list of modifier objects that should be applied when this unlockable is chosen
    - A list of abilities (or game rules) that should be applied when this unlockable is chosen


There are a few factors that influence if, and when, a Level Unlockable becomes availble within a game.

Repeatable:
    Each Level Unlockable includes a flag indicating whether this unlockable is repeatable or not.  If this is set to true,
    the unlockable will continue to appear after it has been chosen

Pre-Reqs:
    Each Level Unlockable can define a list of pre-req Level Unlockables that have to have been activated before this unlockable
    can appear

Next-Unlocks:
    Each Level Unlockable can define a list of other Level Unlockables that might become available after this unlockable was activated.
    The game will run checks on each of these listed Level Unlockables to see if all of it's pre-reqs have been met, giving it the chance
    to be added to the list of unlockables that can appear if they have been.

Family:
    Each Level Unlockable can belong to a family.  If it does, it must belong to a branch of that family (some int value).  The player
    can only choose one branch of a family of unlockables to pursue.  Once an Unlockable from a family is chosen, the game will make any
    other Unlockables from the same family but belonging to other branches unavailable. This allows for mutually exclusive 'paths' of
    Level Unlockables.
    If an Unlockable does not have a family, (value is undefined / null) then this mechanic is ignored for that Unlockable.
    If an Unlockable belongs to a family, the branch and branch_name attributes should also be defined. (name can be displayed to the player)


The above factors only apply to Level Unlockable objects that the game flags as 'potential unlockables' when the player starts a new level.
Achievements, a 'game level', Challenges, and store purchases will affect this initial potential list that the game uses for a given level.
NOTE:  This behavior is NYI and all unlockables will appear in this potential list.
"""

# class to represent all the things
class_name LevelUnlockable


# internal attributes of a Level Unlockable class
var name : String           # This is the name of the Unlockable and also uniquely identifies it
var desc : String           # This is a description of what this unlockable does
var family : Consts.UnlockFamily_e # This is the 'family' that this unlock belongs to
var branch : int            # This is the branch of the family that this unlock belongs to
var branch_name : String    # This is the name of the family branch that the unlockable belongs to
var repeatable : bool       # This flag indiates whether this unlockable can be aquired more than once or not
var pre_reqs : Array        # This is a list of other LevelUnlockables that must be unlocked before this becomes available
var next_unlocks : Array    # This is a list of other LevelUnlockables to make available (if able) once this ulockable has been picked
var mods : Array            # This is a list of modifiers to apply to the game when this unlockable is picked
var abilities : Array       # This is a list of abilities to apply to the game when this unlockable is picked




# ====================== Common Functions For LevelUnlockable classes ==================================


# TODO: move functions here as needed, could add parsing to mod lists or extra conditional behavior




