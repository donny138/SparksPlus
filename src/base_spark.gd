
"""
This is the logical class to keep track of everything related to a single spark

This should be instantiated with values specific to the spark we want to generate
"""

# this class tracks info about sparks
class_name BaseSpark


# attributes of a spark
var damage
var speed
var debuff_list = []


# constructor for a spark
func _init(_damage, _speed, _debuffs):
    # set all of the things!
    damage = _damage
    speed = _speed
    debuff_list = _debuffs

