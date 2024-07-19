
"""
An ability script will make a change to the game when it is run.  For example, a script could add a new on-hit effect
or change the attributes of an existing effect.  The sky's the limit with these things.  

The Script objects can be specified within Level Unlockable objects.  When the Level Unlockable object is chosen,
a new instance of the ability script will be created and then run from the Level scene object

Each ability script will need a "apply_ability" function that executes whatever the ability is doing.

This is the base version of the ability script and should not be directy called, instead instantiated versions of this
that enforce various abilities should be created and called to do whatever you want.
"""

# class to track and manage how an ability is applied
class_name AbilityScript


# Internal attributes shared by abilities
# TODO:  Move attributes into here as it makes sense


# a derived class should override this function to do it's initial ability implementation
func apply_ability(_level_scene_object) -> bool:
    """
    Returns true if the ability was applied, false if it was not 
    (there may be some instances where abilities should not be applied and calling func should know)

    Takes a pointer to the level scene object as input so it can reference any object within the game level
    """
    # base class doesn't do anything, returns false in case it is ever called directly
    var success_status = false
    return success_status


