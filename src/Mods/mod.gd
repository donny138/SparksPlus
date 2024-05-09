
"""
This class exists to describe a modifier that can be applied in the game
This is the object that will phsyically be stored and used as a modifier by other game objects
This class should be instantiated and populated by derived LevelUnlockable classes

This object keeps track of the following:
    - The name (id) of the modifier
    - A flag indicating whether or not this modifier is unique and can or can't be applied more than once
    - An enum value indicating what game object this modifier applies to
    - An enum value indicating what attribute is being modified
    - An enum value indicating how this modifier should be applied during calculations
    - A value to apply during calculations to actually apply the modifier

TODO:  Determine if conditional modifier qualifiers should be added here, or if these should be tracked elsewhere


Modifier Behavior:
    Every spark, projectile, enemy, spark source, and level will maintain a list of mods.  However, only the game level
    and the spark source need to maintain a live list of modifiers. 
    The current plan is only apply / update modifiers at these two locations whenever they are added or removed.  The reasoning
    here is that they are responsible for creating all the other entities that enter the level and there will only ever be one
    of each in the level at a given time, making it far easier to manage.
    When something like an enemy or a spark is generated, relevant mods from the spark source or the level will be applied to
    the created entity. If these entities create more entities (debuff / ability / extra projectiles / etc.) Then they will do
    the same at that time, but since they are more ephemeral during the run, they will not be updated as soon as a new mod is
    applied through a LevelUnlockable being chosen.
"""


# Class to store info for a modifier
class_name Mod


# Internal Attributes
var name : String                           # This is the name (and id) of the modifier
var repeatable : bool                       # flag is true if modifier can be applied more than once
var mod_target : Consts.ModTarget_e         # Defines the target object of this modifier
var mod_attribute : Consts.ModAttribute_e   # Defines the target attribute of this modifier
var mod_type : Consts.ModType_e             # Defines how this modifier is applied during calculations
var mod_value : float                       # The value to apply during calculations



# TODO:  Make a couple constructors to make creating instances of these easier

