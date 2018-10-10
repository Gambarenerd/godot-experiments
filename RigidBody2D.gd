extends RigidBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var player_class = preload("res://Player.gd")
var player2_class = preload("res://Player2.gd")
var netNode
func _ready():
	netNode = get_node("../Map/Net")

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func _integrate_forces(state):
	var contactIdx = is_on_floor(state)
	if  contactIdx != -1:
		var collider = state.get_contact_collider_object(contactIdx)
		if not (collider is player_class) and not (collider is player2_class):
			if position.x > netNode.position.x + 20:
				print("Ball touched the ground on the right.")
			elif position.x < netNode.position.x - 20:
				print("Ball touched the ground on the left.")

func is_on_floor(state):
	for x in range(state.get_contact_count()):
		var ci = state.get_contact_local_normal(x)
		if ci.dot(Vector2(0, -1)) > 0.6:
			return x
	return -1