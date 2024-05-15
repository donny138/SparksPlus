
"""
This class exists to represent an abillity or effect to apply to some aspect of the game.
Unlike modifiers, these are designed to add a new Scene object to the game instead of modifying an existing one.
For example, to "apply a burn debuff on hit" A spark could have an ability with a pointer to a scene object
which is effectively the "burn" debuff and the information needed so that the game knows to apply it to an enemy
when the spark hits it.  The actual behavior and implementation of these abilities should be done within their
scene object.  The Ability class exists to manage how these abilities are applied, not to define what they are.



TODO:  Impelement a really rough version of this once some modifiers have been implemented
"""

# class to track and manage how an ability is applied
class_name Ability


# Internal attributes
var name
var repeatable
var scene_object

