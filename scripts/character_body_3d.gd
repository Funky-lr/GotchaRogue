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

func _physics_process(delta: float) -> void:
	# Add gravity if not on floor
	if can_jump and not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump input
	if can_jump and Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Handle walking input
	if can_walk:
		var input_dir := Input.get_vector("walk_left", "walk_right", "walk_straight", "walk_back")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED * delta)
			velocity.z = move_toward(velocity.z, 0, SPEED * delta)

	# Placeholder for basic attack (to be implemented)
	if can_basic_attack:
		# Example: if Input.is_action_just_pressed("basic_attack"):
		#     perform_basic_attack()
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

# Example function to reduce cooldown timers (call this every frame or timer)
func update_cooldowns(delta: float) -> void:
	for key in cooldowns.keys():
		if cooldowns[key] > 0.0:
			cooldowns[key] = max(cooldowns[key] - delta, 0.0)

# Example function to perform a basic attack (to be implemented)
func perform_basic_attack():
	if cooldowns["basic_attack"] <= 0.0:
		# Attack logic here
		cooldowns["basic_attack"] = 1.0  # Example cooldown duration in seconds
		print("Basic attack performed!")

# You can add similar functions for special_attack, ultimate, dash, air_dash
