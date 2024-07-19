
"""
This class exists primarily to keep track of a few Enumerations, constants, and functions that will be 
needed when handling abilities or modifiers by most other objects in the game.

No changes to this class should be made while the game is running or from within the game at all
"""


# class to contain Enums, global constants, and generic common mod / ability functions
class_name Consts



# ====================== Enumerations ===============================

# TODO:  Add an enumeration for a Mod_ID?  This way every modifier in the game can explicitly be listed here
# This would make searching for, editing, or removing existing modifiers easier


# Defines targets of modifiers.  This determines what object a modifier should be applied to
enum ModTarget_e{
    spark_source,       # mod affects the spark source (player)
    spark,              # mod affects sparks
    enemy,              # mod affects all enemies
    level               # mod affects the main level
}


# Defines attributes that can be modified.  This determines the attribute that this modifier will modify
enum ModAttribute_e{
    health,             # mod applies to health
    speed,              # mod applies to speed
    damage,             # mod applies to ALL damage
    defense,            # mod applies to defense (defense mechanic is NYI)
    durability,         # mod applies to durability (how many hits a spark can endure before breaking)
    pickup_range,       # mod applies to the range pickup-ables can be picked up at
    orbit_range,        # mod applies to the range of orbits
    spark_gen,          # mod applies to spark generation (the rate)
    spark_cap,          # mod applies to the spark cap
    xp_mult,            # mod applies to the xp multiplier
    active_abil_ct,     # mod applies to the cooldown time of the active ability
    spawn_event         # mod applies to enemy spawning events (the rate)
}


# Defines types of modifiers.  This determines how a modifier is applied to calculations
enum ModType_e{
    base_value,         # mod is added to the base value at the beginning of calculations
    multiplier,         # mod is multiplies the base value and other multipliers during calculations
    flat_add            # mod is added to the final value at the end of calculations
}


# Defines families of unlockables.  This affects which unlockables are available during gameplay
enum UnlockFamily_e{
    no_family,          # 'family' an unlockable can belong to when it does not have a family
    spark_production,   # family of unlockables related to producing new sparks
    battle_tactics,     # family of unlockables involving active and defensive abilities
    spark_tempering,    # family of unlockables which can apply fire or ice debuffs
    spark_treatment     # family of unlockables which can apply viruses or affect spark stability
}


# Defines types of active abilities.  This allows the game or other abilities to categorize ability objects
enum AbilityType_e{
    debuff,             # Effect counts as a debuff, usually hinders the object it is applied to
    buff,               # Effect counts as a buff, usually helps the object it is applied to
    override,           # Effect overrides or replaces an existing game object or game behavior
    new,                # Effect adds some new behavior to existing game objects
    passive             # Effect is passive or doesn't fall under any of the above categories
}


# Defines types of ability activations.  This allows the game to recognize when to apply different abilities
enum AbilityActivationType_e{
    on_hit,             # Effect is applied on-hit
    on_death,           # Effect is applied on-death
    retaliate,          # Effect is applied when parent gets hit
    passive             # Effect is passively applied or controls when it applies itself
}


# Defines all of the potential damage types that can be applied
# TODO: Implement this later, once some unlockables require this
enum DmgType_e{
    normal,             # a generic damage type
    fire                # fire related damage
}




# ============================ Helper Modifier Functions ============================
"""
These are generic functions to use to apply modifiers to calculations or to sort modifiers based on different things

The Mods should be applied to stats whenever a new modifier is applied to an object or a modifier is removed
"""


# function to filter mods out of a list based on their target object
static func filter_mods_by_target(mod_list : Array, target : ModTarget_e):
    var target_mods = []

    # get every mod from the list with the desired target
    for mod : Mod in mod_list:
        if mod.mod_target == target:
            target_mods.append(mod)

    # return the list of mods that have the same target
    return target_mods


# function to filter mods out of a list based on the attribute they affect
static func filter_mods_by_attribute(mod_list : Array, attribute : ModAttribute_e):
    var attribute_mods = []

    # get every mod from the list with the desired attribute
    for mod : Mod in mod_list:
        if mod.mod_attribute == attribute:
            attribute_mods.append(mod)
    
    # return the list of mods that apply to the given attribute
    return attribute_mods


# function to sort modifiers based on how they apply to calculations.  Returns an array for each mod type
static func split_mods_by_type(mod_list : Array):
    var base_mods = []
    var mult_mods = []
    var flat_mods = []

    # iterate through the list of modifiers
    for mod : Mod in mod_list:
        # Add the modifier to the array of mods with the corresponding type
        if mod.mod_type == ModType_e.base_value:
            base_mods.append(mod)
        elif mod.mod_type == ModType_e.multiplier:
            mult_mods.append(mod)
        elif mod.mod_type == ModType_e.flat_add:
            flat_mods.append(mod)
    
    # put the lists of modifiers into an array (can't return more than one object)
    var sorted_mods = []
    sorted_mods.append(base_mods)
    sorted_mods.append(mult_mods)
    sorted_mods.append(flat_mods)

    # return the sorted lists of modifiers
    return sorted_mods


# function to do the calculation that applies modifiers to a value
static func calc_mods(mod_list : Array, base_value : float):
    # this function assumes that every mod in the given mod_list should apply to the base_value (no attribute check)
    var modded_value = base_value

    # split the given mods by type
    var sorted_mods = split_mods_by_type(mod_list)
    # extract the sorted lists for each type of modifier
    var base_mods = sorted_mods[0]
    var mult_mods = sorted_mods[1]
    var flat_mods = sorted_mods[2]

    # apply any modifiers that impact the base value before multipliers
    for mod : Mod in base_mods:
        modded_value = modded_value + mod.mod_value
    
    # apply any multiplier modifiers
    for mod : Mod in mult_mods:
        modded_value = modded_value * mod.mod_value
    
    # apply any flat addition modifiers
    for mod : Mod in flat_mods:
        modded_value = modded_value + mod.mod_value
    
    # return the modified value 
    return modded_value

