class_name Laccio extends Shootable

enum State {Inactive, Boomer1, Boomer2, Active}

var curr_state : State = State.Inactive

@export var laccio_projectiles : Array[PackedScene]

var bind1: Shootable 
var bind2: Shootable 

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
	print("Laccio")
	if(curr_state == State.Inactive):
		print("Bind 1 shoot")
		bind1 = laccio_projectiles.pick_random().instantiate()
		bind1.on_shoot(pos)
		get_tree().root.add_child(bind1) 
		bind1.top_level = true
		#joint.node_a = bind1.get_path()
		next_state()
		return false
	elif(curr_state == State.Boomer1):
		print("Bind 2 shoot")
		bind2 = laccio_projectiles.pick_random().instantiate()
		bind2.on_shoot(pos)
		get_tree().root.add_child(bind2)
		bind2.top_level = true
		 #joint.node_b = bind2.get_path()
		next_state()
		return true
	return false

func _process(delta : float) -> void:
	if(curr_state == State.Active):
		return
		get_node(joint.node_a).apply_central_impulse(Vector3(0,1,0))
		get_node(joint.node_b).apply_central_impulse(Vector3(0,-1,0))
		
