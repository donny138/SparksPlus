
"""
This script manages displaying damage text when an entity receives damage
"""

extends Label


# attributes of this class
@export var lifetime : int		# the duration the text will be displayed
var level_scene : LevelScene


# Called when the node enters the scene tree for the first time.
func _ready():

	# configure life time timer
	$LifeTime.wait_time = lifetime
	$LifeTime.start()

	# bind the control time signal to this object
	level_scene = get_parent()
	level_scene.control_time.connect(handle_control_time)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


# this function is called when the lifetime timer expires
func _on_life_time_timeout():
	# delete this object
	queue_free()


# handle control time signal 
func handle_control_time(freeze_time : bool):
	# pause or resume the lifetime timer depending on the input
	$LifeTime.set_paused(freeze_time)



# function to configure the displayed text based on a floating point number
func display_dmg(dmg : float):
	# split the generated string on the decimal point if it exists
	var temp_text = str(dmg).split(".")
	if len(temp_text) > 1:
		# if there are numbers after the decimal, extract the first two and add them to the string
		var decimal = "."
		if len(temp_text[1]) >=2:
			decimal = decimal + temp_text[1][0] + temp_text[1][1]
		else:
			decimal = decimal + temp_text[1][0]
		text = temp_text[0] + decimal
	else:
		# if there are no numbers after the decimal, just display the main number
		text = temp_text[0]





