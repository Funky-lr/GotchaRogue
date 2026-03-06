extends CharacterBody3D

# Constants for movement
const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# --- Properties every Ground borg should have ---
@export var character_name: String = "Ground Borg"
@export var number: int = 0
@export var health_points: int = 100
@export var max_health_points: int = 100
@export var level: int = 1
@export var tribe: String = "Default Tribe"
@export var rarity: String = "Common"  # Could be Enum or String
@export var cost: int = 10

# Cooldowns dictionary to track ability cooldowns (in seconds)
var cooldowns := {
	"basic_attack": 0.0,
	"special_attack": 0.0,
	"ultimate": 0.0,
	"dash": 0.0,
	"air_dash": 0.0
}

# Damage scaled by level (example base damage)
@export var base_damage: int = 10

# Computed damage based on level
func get_damage() -> int:
	return base_damage * level

# --- Ability flags (to be implemented) ---
var can_walk: bool = true
var can_jump: bool = true
var can_basic_attack: bool = false
var can_special_attack: bool = false
var can_ultimate: bool = false
var can_dash: bool = false
var can_air_dash: bool = false

# Reference to the camera node for movement direction
@export var camera_path: NodePath
var camera: Camera3D

# Projectile scene to instantiate when shooting
@export var projectile_scene: PackedScene

func _ready():
	camera = get_node_or_null(camera_path)
	if camera == null:
		push_warning("Camera node not found at path: %s" % camera_path)

func _process(delta):
	if Input.is_action_just_pressed("special_attack"):
		shoot_projectile()

func _physics_process(delta: float) -> void:
	# Add gravity if not on floor
	if can_jump and not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump input
	if can_jump and Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Handle walking input relative to camera
	if can_walk and camera:
		var input_dir := Vector2(
			Input.get_action_strength("walk_right") - Input.get_action_strength("walk_left"),
			Input.get_action_strength("walk_straight") - Input.get_action_strength("walk_back")
		).normalized()

		if input_dir.length() > 0:
			# Get camera basis vectors
			var cam_basis = camera.global_transform.basis

			# Camera forward vector (ignore vertical component)
			var forward = -cam_basis.z
			forward.y = 0
			forward = forward.normalized()

			# Camera right vector (ignore vertical component)
			var right = cam_basis.x
			right.y = 0
			right = right.normalized()

			# Calculate movement direction relative to camera
			var move_dir = (forward * input_dir.y) + (right * input_dir.x)
			move_dir = move_dir.normalized()

			# Apply movement speed
			velocity.x = move_dir.x * SPEED
			velocity.z = move_dir.z * SPEED
		else:
			# No input, slow down smoothly
			velocity.x = move_toward(velocity.x, 0, SPEED * delta)
			velocity.z = move_toward(velocity.z, 0, SPEED * delta)

	# Placeholder for basic attack (to be implemented)
	if can_basic_attack:
		pass

	# Placeholder for special attack (to be implemented)
	if can_special_attack:
		pass

	# Placeholder for ultimate (to be implemented)
	if can_ultimate:
		pass

	# Placeholder for dash (to be implemented)
	if can_dash:
		pass

	# Placeholder for air dash (to be implemented)
	if can_air_dash:
		pass

	# Move the character using velocity
	move_and_slide()

func shoot_projectile():
	if projectile_scene == null:
		push_warning("Projectile scene not assigned!")
		return

	var projectile_instance = projectile_scene.instantiate()
	get_parent().add_child(projectile_instance)  # Add to scene tree first

	var forward = Vector3.FORWARD
	var spawn_position = Vector3.ZERO

	if camera:
		forward = -camera.global_transform.basis.z.normalized()
		spawn_position = global_transform.origin + Vector3(0, 1.5, 0) + forward * 1.5
	else:
		forward = Vector3.FORWARD
		spawn_position = global_transform.origin + Vector3(0, 1.5, 0)

	projectile_instance.global_transform.origin = spawn_position
	projectile_instance.global_transform.basis = Basis.looking_at(forward, Vector3.UP)

	var speed = 20.0
	if "speed" in projectile_instance:
		speed = projectile_instance.speed

	if projectile_instance is RigidBody3D:
		projectile_instance.linear_velocity = forward * speed
		print("Projectile velocity set to: ", projectile_instance.linear_velocity)


func update_cooldowns(delta: float) -> void:
	for key in cooldowns.keys():
		if cooldowns[key] > 0.0:
			cooldowns[key] = max(cooldowns[key] - delta, 0.0)

func perform_basic_attack():
	if cooldowns["basic_attack"] <= 0.0:
		cooldowns["basic_attack"] = 1.0
		print("Basic attack performed!")
