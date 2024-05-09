
"""
This script runs the level up gui.  This gui will appear when the player levels up
"""

extends Control


# internal attributes of the gui
#var spark_source 				# pointer to the spark source object
var level						# pointer to the level object
var unlock_1					# the modifier associated with button 1
var unlock_2					# the modifier associated with button 2
var unlock_3					# the modifier associated with button 3



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

	# begin the timer that will re-enable the buttons
	$EnableButtons.start()

	# show the gui
	show()


# function to disable the gui and all the things on it
func disable_gui():
	# TODO: if things need to be disabled while it is hidden, do that here
	
	# disable buttons so that they can't be clicked on 
	disable_gui_buttons()

	# hide the gui
	hide()


# function to populate the gui with new modifier options
func load_level_unlock_options(level_unlocks : Array):
	# store the elements from the modlist
	unlock_1 = level_unlocks[0]
	unlock_2 = level_unlocks[1]
	unlock_3 = level_unlocks[2]

	# update the text of each option button to reflect it's new modifier
	# update unlock1
	$Elements/LevelUnlocks/Unlock1/Title.text = unlock_1.name
	$Elements/LevelUnlocks/Unlock1/Button/Desc.text = unlock_1.desc
	# update unlock2
	$Elements/LevelUnlocks/Unlock2/Title.text = unlock_2.name
	$Elements/LevelUnlocks/Unlock2/Button/Desc.text = unlock_2.desc
	# update unlock3
	$Elements/LevelUnlocks/Unlock3/Title.text = unlock_3.name
	$Elements/LevelUnlocks/Unlock3/Button/Desc.text = unlock_3.desc

	# update tooltips of each option button (if applicable)

	# update the reroll count if applicable



# function to provide a modifier back to the main level scene
func select_unlock(selected_unlock):
	# disable this gui
	disable_gui()

	# pass the selected modifier back to the main level scene
	level.finish_level_up_event(selected_unlock)



# function to disable all the buttons on the gui
func disable_gui_buttons():
	# disable all the buttons on the interface so that the player can't click on them
	$Elements/LevelUnlocks/Unlock1/Button.disabled = true
	$Elements/LevelUnlocks/Unlock2/Button.disabled = true
	$Elements/LevelUnlocks/Unlock3/Button.disabled = true
	$Elements/Rerolls/Button.disabled = true


# ====================== Event Handlers ============================


# Triggers when the Enable buttons timer expires
func _on_enable_buttons_timeout():
	# the timer exists so that the player can't click the buttons the moment the gui appears and the game pauses
	# this prevents them accidently clicking something before the realize the gui has appeared

	# re-enable all the buttons on the interface so that the player can click on them again
	$Elements/LevelUnlocks/Unlock1/Button.disabled = false
	$Elements/LevelUnlocks/Unlock2/Button.disabled = false
	$Elements/LevelUnlocks/Unlock3/Button.disabled = false
	$Elements/Rerolls/Button.disabled = false


# Triggers when the button for unlock 1 is pressed
func _on_unlock_1_button_down():
	select_unlock(unlock_1)


# Triggers when the button for unlock 2 is pressed
func _on_unlock_2_button_down():
	select_unlock(unlock_2)


# Triggers when the button for unlock 3 is pressed
func _on_unlock_3_button_down():
	select_unlock(unlock_3)


# Triggers when the Reroll Options button is pressed
func _on_button_button_down():
	pass # Replace with function body.






