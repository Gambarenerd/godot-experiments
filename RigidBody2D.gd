extends RigidBody2D

var player_class = preload("res://Player.gd")
var player2_class = preload("res://Player2.gd")
var netNode
var winLabelNode
var restartable = false
var reset = false
var originalTransform
	
func _ready():
	netNode = get_node("../Map/Net")
	winLabelNode = get_node("../WinLabel")
	originalTransform = get_transform()

func _integrate_forces(state):
	var contactIdx = is_on_floor(state)
	if  contactIdx != -1:
		var collider = state.get_contact_collider_object(contactIdx)
		if not (collider is player_class) and not (collider is player2_class):
			if position.x > netNode.position.x + 30:
				winLabelNode.text = "Good Iro WINS!"
				winLabelNode.visible = true
				sleeping = true
				restartable = true
			elif position.x < netNode.position.x - 30:
				winLabelNode.text = "Evil Iro WINS!"
				winLabelNode.visible = true
				sleeping = true
				restartable = true
	if reset:
		print("yess")
		state.set_transform(originalTransform)
		sleeping = false
		reset = false

func _process(delta):
	if restartable:
		if Input.is_action_pressed("ui_reset"):
			restartable = false
			get_node("../Player").reset = true
			get_node("../Player2").reset = true
			reset = true
			winLabelNode.visible = false
			sleeping = false
	
func is_on_floor(state):
	for x in range(state.get_contact_count()):
		var ci = state.get_contact_local_normal(x)
		if ci.dot(Vector2(0, -1)) > 0.6:
			return x
	return -1