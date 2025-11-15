class_name Laccio extends Shootable

enum State {Inactive, Boomer1, Boomer2, Active}

var curr_state : State = State.Inactive

@export var projectiles_scenes : Array[PackedScene]

@onready var bind1: Shootable = $Bind1
@onready var bind2: Shootable = $Bind2

@onready var joint: Generic6DOFJoint3D = $Joint

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

func on_shoot(pos: Vector3) -> bool:
	global_position = pos
	if(curr_state == State.Inactive):
		bind1 = projectiles_scenes.pick_random().instantiate()
		bind1.on_shoot(global_position)
		return false
	if(curr_state == State.Boomer1):
		bind2 = projectiles_scenes.pick_random().instantiate()
		bind2.on_shoot(global_position)
		return true
	return true
	
# return false if state is active, true otherwise and bind boomer encountered (or any body)
func process(body: Node) -> bool:
	if(curr_state == State.Boomer1):
		joint.node_a = body.get_path()
		movement_speed = 0.
		return true
	elif(curr_state == State.Boomer2):
		joint.node_b = body.get_path()
		movement_speed = 0.
		return true
	else: 
		return false
	
func _on_body_entered(body: Node) -> void:
	if process(body):
		next_state()
	else:
		pass

func _process(delta : float) -> void:
	if(curr_state != State.Active):
		position.y += movement_speed*delta;
	else:
		get_node(joint.node_a).apply_central_impulse(Vector3(0,1,0))
		get_node(joint.node_b).apply_central_impulse(Vector3(0,-1,0))
		
