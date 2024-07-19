
"""
This is the ability script for the "Stronger Together" level unlockable

This will add an object to created sparks that adds the "Stronger Together" Debuff to enemies on hit
This debuff increases the damage the enemy takes from receiving successive hits
"""

class_name ScriptStrongerTogether extends AbilityScript


# override of base class function
func apply_ability(level_scene_object : LevelScene) -> bool:
    var success_status = true

    # pointer to the "Stronger Together" on hit effect object - This object will trigger it's effect on hit
    # var ability_object = OnHit_Stronger_Together
    var ability_object = preload("res://src/Abilities/SparkObjects/onhit_stronger_together.tscn")

    # check to see if an instance of this object already exists where we want to add this object
    for ability in level_scene_object.spark_abilities:
        if ability == ability_object:
            success_status = false
            break
    
    # add the abilty to the list of abilities to generate sparks with if it doesn't already exist
    if success_status:
        level_scene_object.spark_abilities.append(ability_object)

    # return true if the ability was successfully added
    return success_status

