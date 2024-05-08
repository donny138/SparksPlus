
"""
This script runs the level up gui.  This gui will appear when the player levels up
"""

extends Control


# internal attributes of the gui
#var spark_source 				# pointer to the spark source object
var level						# pointer to the level object
var mod_1						# the modifier associated with button 1
var mod_2						# the modifier associated with button 2
var mod_3						# the modifier associated with button 3



# ====================== Initialization and Process functions ============================


# Called when the node enters the scene tree for the first time.
func _ready():
	# resize the gui to fit the window
	size = get_window().size
	# hide the gui, it should not be visible when it first appears
	disable_gui()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



# ======================= Helper functions for special events ================================


# function to enable the gui and all the things on it
func enable_gui():
	# TODO: if things need to be disabled while it is hidden, add re-enabling behavior here
	# show the gui
	show()


# function to disable the gui and all the things on it
func disable_gui():
	# TODO: if things need to be disabled while it is hidden, do that here
	# hide the gui
	hide()


# function to populate the gui with new modifier options
func load_modifiers(mod_list):
	# store the elements from the modlist
	mod_1 = mod_list[0]
	mod_2 = mod_list[1]
	mod_3 = mod_list[2]

	# update the text of each option button to reflect it's new modifier

	# update tooltips of each option button (if applicable)

	# update the reroll count if applicable



# function to provide a modifier back to the main level scene
func select_mod(selected_mod):
	# disable this gui
	disable_gui()

	# pass the selected modifier back to the main level scene
	level.finish_level_up_event(selected_mod)



# ====================== Event Handlers ============================


# triggers when the Mod1 button is pressed
func _on_mod_1_button_down():
	select_mod(mod_1)


# triggers when the Mod2 button is pressed
func _on_mod_2_button_down():
	select_mod(mod_2)


# triggers when the Mod3 button is pressed
func _on_mod_3_button_down():
	select_mod(mod_3)


# Triggers when the Reroll Options button is pressed
func _on_button_button_down():
	pass # Replace with function body.





