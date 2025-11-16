extends Shootable

# Get a reference to the DeathRay node
@onready var raggio_santo = $RaggioSantoMesh
# Get a reference to the ShaderMaterial (for setting uniforms)
var ray_material: ShaderMaterial

@onready var impact = $Area3D
@export var impulse : float = 20
# Time control for animation in the shader
var ray_active_time: float = 0.0
const RAY_FADE_SPEED: float = 8.0 # How fast the ray fades out after release

var shoot : bool = false

func _on_impact(body : Node3D):
	body.apply_central_impulse(Vector3(0,impulse,0))

func _ready():
	# It's good practice to hide the ray on startup
	raggio_santo.visible = false
	# Cache the material reference for faster access
	ray_material = raggio_santo.get_active_material(0) as ShaderMaterial
	impact.connect("body_entered", Callable(self, "_on_impact"))

func on_shoot(position: Vector3) -> bool:
	# 2. Calculate the direction vector
	var direction = Vector3(0,1,0)
	global_position = position
	impact.global_position = position

	shoot = true
	# 3. Calculate the new length for the shader uniform
	var ray_length =  1000.

	if ray_material:
		ray_material.set_shader_parameter("ray_length", ray_length)
		# Also set the active_time parameter for animation
		ray_material.set_shader_parameter("active_time", ray_active_time)
		
		ray_material.set_shader_parameter("ray_color", GameInstance.player_color[playerID])

	# Note: If your cylinder's long axis is Z, you might need to adjust the up vector 
	# or the look_at alignment.

	raggio_santo.visible = true

	return true

func _process(delta):
	if(!shoot):
		return
	ray_active_time += delta
	# Pass the accumulated active time to the shader
	if ray_material:
		ray_material.set_shader_parameter("active_time", ray_active_time)
	
	impact.global_position.y += 100*delta
	if(ray_active_time >= 1.2):
		queue_free()
