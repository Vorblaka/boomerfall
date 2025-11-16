extends Shootable

# --- Configurable Settings ---
@export var segment_length: float = 0.5   # Length of each segment/constraint (Rest Length)
@export var num_segments: int = 20        # Number of segments (Total points = segments + 1)
@export var stiffness: float = 0.8        # Constraint stiffness (0.0=soft, 1.0=rigid)
@export var damping: float = 0.98         # Velocity damping factor
@export var constraint_iterations: int = 5 # How many times to resolve constraints per frame (more = stabler)

# --- External Attachments ---
@export var start_body_path: NodePath # Path to the RigidBody3D at the start (Node A)
@export var end_body_path: NodePath   # Path to the RigidBody3D at the end (Node B)

var start_body_velocity : Vector3 = Vector3(0,0,0)
var end_body_velocity : Vector3 = Vector3(0,0,0)

# --- Internal State ---
var positions: Array[Vector3] = []    # Current position of each particle
var prev_positions: Array[Vector3] = [] # Position in the previous frame (used for velocity)
var visuals: Array[Node3D] = []      # Visual representation nodes (e.g., MeshInstances)

# --- Scene References ---
var start_body: Node3D
var end_body: Node3D
var total_points: int

enum State {Inactive, Boomer1, Boomer2, Active}

var curr_state : State = State.Inactive

# You can use a dedicated sphere/cube scene for visuals
const VISUAL_SCENE = preload("res://Core/LaccioSfera.tscn")

func _ready():
	total_points = num_segments + 1
	
	# 1. Get references to the attached bodies
	if start_body_path:
		start_body = get_node(start_body_path)
	if end_body_path:
		end_body = get_node(end_body_path)

	if not start_body or not end_body:
		print("PBDString: Start or End body paths are not valid.")
		set_process(false)
		return
		
	# 2. Initialize particle positions and visuals
	_initialize_particles()
	
	# Optional: Connect the visuals to the physics system
	# This ensures the PBD script handles physics, but the visuals are separate
	set_physics_process(true)

func _initialize_particles():
	var start_pos = start_body.global_position
	var end_pos = end_body.global_position
	var direction = (end_pos - start_pos).normalized()
	
	for i in range(total_points):
		# Initial position: straight line between the two bodies
		var p = start_pos + direction * segment_length * i
		positions.append(p)
		prev_positions.append(p)
		
		# Instantiate and add visualizer sphere
		var visual = VISUAL_SCENE.instantiate()
		visual.global_position = p
		add_child(visual)
		visuals.append(visual)


func _physics_process(delta):
	if(curr_state == State.Inactive):
		return
	# 1. External Forces (Integration)
	if(curr_state >= State.Boomer1):
		positions[0] += start_body_velocity * delta
	else: 
		positions[0] =start_body.global_position
		
	if(curr_state >= State.Boomer2):
		positions[total_points-1] += end_body_velocity * delta
	else: 
		positions[total_points-1] += end_body.global_position
	
	_apply_external_forces(delta)
	
	# 2. Resolve Constraints (The PBD Magic)
	for i in range(constraint_iterations):
		_resolve_distance_constraints()
		
	# 3. Apply Boundary Conditions (Attachment to Rigid Bodies)
	#_apply_attachment_constraints()
	
	# 4. Update Visuals
	_update_visuals()
	

func apply_velocity_start_body(velocity : Vector3):
	start_body_velocity = velocity
	
func apply_velocity_end_body(velocity : Vector3):
	end_body_velocity = velocity

func _apply_external_forces(delta):
	# Apply gravity and update positions based on velocity
	for i in range(total_points):

		var current_pos = positions[i]
		var old_pos = prev_positions[i]
		
		# Calculate velocity and apply damping
		if (curr_state >= State.Boomer1 && i == 0) || (curr_state >= State.Boomer2 && i == 0): 
			positions[i] = current_pos
			continue
		var velocity = (current_pos - old_pos) * damping
		
		# Store current position as previous for next frame
		prev_positions[i] = current_pos
		
		# Update predicted position (v = v + a*dt; x = x + v*dt)
		var new_pos = current_pos + velocity
		positions[i] = new_pos


func _resolve_distance_constraints():
	# Loop over all segments (constraints)
	for i in range(num_segments):
		var p1_index = i
		var p2_index = i + 1
		
		var p1 = positions[p1_index]
		var p2 = positions[p2_index]
		
		var delta_p = p2 - p1
		var current_distance = delta_p.length()
		
		# Calculate the constraint error (how much it needs to move)
		var correction_factor = (current_distance - segment_length) / current_distance
		
		# Calculate the vector correction (PBD core step)
		var correction = delta_p * correction_factor * stiffness
		
		# Apply to p1 (unless it's the fixed start point)
		if(p1_index!= 0):
			positions[p1_index] += correction * 0.5
		if(p2_index != total_points-1):
			positions[p2_index] -= correction * 0.5


func _apply_attachment_constraints():
	# Fix the start and end points to the RigidBody3D objects
	# This overwrites any movement from the integration or constraint steps
	positions[0] = start_body.global_position
	positions[total_points - 1] = end_body.global_position


func _update_visuals():
	# Move the visual nodes to the calculated particle positions
	for i in range(total_points):
		visuals[i].global_position = positions[i]
		
		
		
func next_state() -> bool:
	if(curr_state == State.Inactive):
		curr_state = State.Boomer1
		return false
	elif(curr_state == State.Boomer1):
		curr_state = State.Boomer2
		return false
	elif(curr_state == State.Boomer2):
		curr_state = State.Active
		return false
	else: 
		return true


func on_shoot(position: Vector3) -> bool:
	if curr_state == State.Inactive:
		positions[0] = position
		start_body_velocity = Vector3(0,20,0)
		next_state()
		return false
	elif curr_state == State.Boomer1:
		positions[total_points-1] = position
		end_body_velocity = Vector3(0,20,0)
		next_state()
		return true
	return true
		
