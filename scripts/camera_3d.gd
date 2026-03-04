extends Camera3D

# Path to the player node the camera will follow
@export var target_path: NodePath

# Distance behind the player the camera will stay
@export var follow_distance: float = 6.0

# Height offset above the player
@export var follow_height: float = 3.0

# Speed at which the camera smoothly moves to the desired position
@export var smoothing_speed: float = 5.0

# Sensitivity for mouse movement controlling camera rotation
@export var mouse_sensitivity: float = 0.3

# Sensitivity for gamepad stick controlling camera rotation (degrees per second)
@export var stick_sensitivity: float = 150.0

# Minimum vertical angle (pitch) the camera can rotate to (in degrees)
@export var min_pitch: float = -30.0

# Maximum vertical angle (pitch) the camera can rotate to (in degrees)
@export var max_pitch: float = 60.0

# Reference to the player node (CharacterBody3D)
var target: CharacterBody3D

# Current horizontal rotation angle (yaw) in degrees
var yaw: float = 0.0

# Current vertical rotation angle (pitch) in degrees
var pitch: float = 10.0

func _ready():
	# Get the player node from the given path, or null if not found
	target = get_node_or_null(target_path)
	
	# Warn if target not found to help debugging
	if target == null:
		push_warning("Target node not found at path: %s" % target_path)
	else:
		# Initialize yaw to the player's current facing direction (Y-axis rotation)
		yaw = rad_to_deg(target.global_transform.basis.get_euler().y)

	# Capture the mouse cursor so relative mouse movement can be tracked
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	# Handle mouse motion events to update camera rotation angles
	if event is InputEventMouseMotion:
		# Decrease yaw by horizontal mouse movement (invert if needed)
		yaw -= event.relative.x * mouse_sensitivity
		
		# Invert vertical mouse movement: increase pitch by vertical mouse movement
		pitch += event.relative.y * mouse_sensitivity
		
		# Clamp pitch to prevent camera flipping upside down
		pitch = clamp(pitch, min_pitch, max_pitch)

func _physics_process(delta):
	if target:
		# Read gamepad stick input for camera rotation (right stick assumed)
		var stick_input = Vector2(
			Input.get_action_strength("camera_right") - Input.get_action_strength("camera_left"),
			Input.get_action_strength("camera_down") - Input.get_action_strength("camera_up")
		)
		
		# Adjust yaw by stick horizontal input scaled by sensitivity and delta time
		yaw -= stick_input.x * stick_sensitivity * delta
		
		# Invert vertical stick input for pitch
		pitch += stick_input.y * stick_sensitivity * delta
		
		# Clamp pitch again after stick input
		pitch = clamp(pitch, min_pitch, max_pitch)

		# Convert yaw and pitch from degrees to radians for math functions
		var yaw_rad = deg_to_rad(yaw)
		var pitch_rad = deg_to_rad(pitch)

		# Calculate the camera offset from the player using spherical coordinates
		var offset = Vector3()
		offset.x = follow_distance * cos(pitch_rad) * sin(yaw_rad)  # Horizontal offset X
		offset.y = follow_distance * sin(pitch_rad)                 # Vertical offset Y
		offset.z = follow_distance * cos(pitch_rad) * cos(yaw_rad)  # Horizontal offset Z

		# Calculate the desired camera position relative to the player's position plus height offset
		var desired_position = target.global_transform.origin + offset + Vector3(0, follow_height, 0)

		# Smoothly interpolate the camera's current position towards the desired position
		global_transform.origin = global_transform.origin.lerp(desired_position, smoothing_speed * delta)

		# Make the camera look at the player’s position plus height offset, with the up direction as Vector3.UP
		look_at(target.global_transform.origin + Vector3(0, follow_height, 0), Vector3.UP)
