
"""
This class represents the HUD that the player sees on the screen while inside of a level
"""

extends Control


# attributes of the HUD class
var spark_source				# this is a pointer to the spark_source (player) object


# Called when the node enters the scene tree for the first time.
func _ready():
	# set the size of the gui container to match the size of the camera
	size = get_window().size
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# set the position of the hud to match the position of it's parent
	#get_viewport().gui_is_dragging()
	#position = get_parent().get_viewport_rect().get_center() - ((size * scale)/2)
	#position = get_parent().get_screen_center_position() - ((size * scale)/2)
	
	pass



# ===================== Functions for updating elements of the HUD ===========================


# update the xp bar
func update_xp(current_xp, needed_xp):
	# update the percent value to reflect how much xp we have vs how much we still need
	$PlayerLevelInfo/LevelProgress.value = (current_xp / needed_xp) * 100


# update the level text
func update_level(current_level):
	# change the level number text to be the the current level
	$PlayerLevelInfo/PlayerLevelText/Number.text = str(current_level)


# update the displayed time text
func update_time(time_in_seconds : int):
	# extract the components of time to display
	var seconds_0 = (time_in_seconds % 60) % 10
	var seconds_1 = int((time_in_seconds % 60) / 10.0)
	var minutes_0 = int(time_in_seconds / 60.0) % 10
	var minutes_1 = int(int(time_in_seconds / 60.0) / 10.0)
	# construct and display the time in text form
	$TimerText.text = str(minutes_1) + " " + str(minutes_0) + "  :  " + str(seconds_1) + " " + str(seconds_0)


# update the health bar and text
func update_health(current_health, max_health):
	# change the current health number to display the current health
	$PlayerHealthInfo/CurrentHealthBar/CurrentHealthText.text = str(int(current_health))
	# update the range of the progress bar
	$PlayerHealthInfo/CurrentHealthBar.value = (float(current_health) / float(max_health)) * 100

