extends CharacterBody3D


const SPEED = 5.5
const JUMP_VELOCITY = 5.0
var ResetClock = 0 # Used for reseting the game by holding "R".
var FlickerClock = 0 # Higher the flicker, the closer the player will run out of flashlight.
var reachTimeOut = 0 # Starts at zero, but will accumulate to 30 in the "_flicker()" event to simulate flashlights.

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# This is a new addition. Meant for head rotation.
@onready var head_attempt = $"Head Attempt"

# Control of the Flashlight is established.
# This is my attempt to manipulate the "SpotLight3D" node.
# Supposed to be turned ON/OFF
# I'm not using consistent labels because it's LITERALLY a flashlight.
@onready var Flashlight = $SpotLight3D 

# For the Flashlight sound effect.
# This is used alongside turning the flashlight ON/OFF
@onready var click = $"../Click"

# Ambient Noise Start
# This is used as nice background noise to accompany the adventure.
@onready var ambience = $"../Ambience"

# Theme of the Flashlight Start
# This is used to indicate the flashlight is being expended.
@onready var theme = $"../Flashlight Theme"

# This is the flicker noise for the flashlight. Used to indicate that it's running out.
@onready var flicker = $"../Flicker"

# Footstep Noise
# Cut because it was too awkward to implement.
#@onready var stepnoise = $"../Footstep"

# Jennifer's Notes: This variable is an original. Used to determine speed of player moving the mouse.
# Oddly enough, this variable has to be negative in order to prevent it from being backwards.
# i.e. If I drag the mouse left, it will go right, and vice versa.
const MOUSE_MOVMENT = -0.01 

# OLD CODE
# This is meant to hide the mouse for a seemless first-person experience.
# Use alt-tab to exit the window if needed.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	ambience.play()
# OLD CODE 
func _input(event):
	if event is InputEventMouseMotion:
		# I'm pretty sure that this is so x & y coordinate of movement is seemless.
		rotate_y(event.relative.x * MOUSE_MOVMENT)
		# I tried the inverse so you could get multiple axies, but it got all wonky.
		# rotate_x(event.relative.y * MOUSE_MOVMENT)
		

#func _stepSFX():
	##Putting them all here so I don't have to copy-past in physics process.
	#if Input.is_action_pressed("forward"):
		#stepnoise.play()
	#if Input.is_action_pressed("backward"):
		#stepnoise.play()
	#if Input.is_action_pressed("leftward"):
		#stepnoise.play()
	#if Input.is_action_pressed("rightward"):
		#stepnoise.play()
	#

func _physics_process(delta):
	
	# _stepSFX() #Play step sound effect if the play moves in any direction.
	# Cut because the execution was awkward.
	
	# Check to see if flashlight is on. If so, accumulate the flicker counter.
	if Flashlight.visible:
		FlickerClock += 1 # Go up by "1" every frame. This will be used for a flicker effect.
		# Below are the listed times (per frame) when the flicker sound will play.
		if FlickerClock == 600: 
			flicker.play()
			for reachTimeOut in 30: # Will time out the lights for 30 frames.
					Flashlight.visible = false
			Flashlight.visible = true # Turning the flashlight back on after the loop is over.
			reachTimeOut = 0 # Reset back to zero.
		if FlickerClock == 1000:
			flicker.play()
		if FlickerClock == 1010:
			flicker.play() 
		if FlickerClock == 1050: 
			flicker.play()
	# Reset the Game
	# This is a fail-safe to ensure that, if the player gets stuck,
	# they can reset the scene by just pressing "R" for 10 seconds.
	if Input.is_action_pressed("Reset"):
		ResetClock += 1 # Add 1 to the reset clock.
		# Assuming 60 FPS, it'll take 600 frames to reach the 10 second threshold.
		if ResetClock > 600: # Checks clock surpasses 600.
			get_tree().change_scene_to_file("res://Second Iteration - Maze.tscn") # Resets the scene.
			# File listed above is subject to change.
			# There is no need to reset the "ResetClock" variable because the scene reseting does that one its own.
			# I found this at: https://youtu.be/XHbrKdsZrxY?si=wYUMdFqHqOhZpikg&t=101
	# Turn Flashlight On/OFF by clicking the left button.
	if Input.is_action_just_pressed("Flashlight"): # Check if the flashlight button is pressed.
			# Toggle flashlight. 
			if Flashlight.visible: # Checking if flashlight is visible.
				#IT WILL NOT TURN ON AGAIN AFTER FLICKERCLOCK REACHES 70000.
				Flashlight.visible = false # Turning off it's on.
				click.play() # Play FlashlightClick
				theme.stop() # Flashlight Theme.
			else: 
				Flashlight.visible = true # Turning on if it's off.
				click.play() # Play FlashlightClick
				theme.play() # Play FlashlightTheme
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	# Original pre-set.
	# if Input.is_action_just_pressed("ui_accept") and is_on_floor():
	# Allows multijump.
	if Input.is_action_just_pressed("ui_accept"):
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("leftward", "rightward", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

#### HUB RING WARPS ####

# Warning: Each ring's area body has to be manually connected to this script.
# Also, the tet maps are here as placeholders until I fully implement the regular ones.
# Hub Ring 1 - Leads to Level 1
func _on_warp_area_1_body_entered(body):
	get_tree().change_scene_to_file("res://Second Iteration - Maze.tscn")
	pass # Replace with function body.

# Hub Ring 2 - Leads to Level 2
func _on_warp_area_2_body_entered(body):
	get_tree().change_scene_to_file("res://Main Map - First Iteration.tscn")
	pass # Replace with function body.

#### GOAL RING WARPS ####

# The variables pertaining to time and flashlight usage will used here.
# TODO: Create a function with a bunch of if-else statments to determine where to warp.
func _on_warp_goal_body_entered(body):
	get_tree().change_scene_to_file("res://Main Map - First Iteration.tscn")
	pass # Replace with function body.

#### BACK TO HUB WARP ####
# Warps player back to hub.
# TODO: Double-check later to make sure implementation is finished.
func _on_warp_hub_body_entered(body):
	get_tree().change_scene_to_file("res://1_aa_Hub.tscn")
	pass # Replace with function body.
