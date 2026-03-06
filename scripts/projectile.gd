extends RigidBody3D

@export var speed: float = 30.0
@export var lifetime: float = 3.0

var life_timer: float = 0.0

func _ready():
	gravity_scale = 0
	print("Projectile _ready() called, gravity_scale set to ", gravity_scale)

func _physics_process(delta):
	life_timer += delta
	if life_timer > lifetime:
		queue_free()
