extends RigidBody2D


var WALK_ACCEL = 2000.0
var WALK_DEACCEL = 1200.0
var WALK_MAX_VELOCITY = 350.0
var AIR_ACCEL = 600.0
var AIR_DEACCEL = 600.0
var JUMP_VELOCITY = 600
var STOP_JUMP_FORCE = 900.0
var MAX_FLOOR_AIRBORNE_TIME = 0.15

var GOING_UP_ON_JUMP_TIME = 0.1

var airborne_time = 0
var jump_time = 0

func _ready():
	$AnimatedSprite.play();

func _integrate_forces(state):
	
	var linear_velocity = state.get_linear_velocity()
	var step = state.get_step()
	
	# Get the controls
	var move_left_key = Input.is_action_pressed("ui_left")
	var move_right_key = Input.is_action_pressed("ui_right")
	var jump_key = Input.is_action_just_pressed("ui_select")
	var on_floor = is_on_floor(state)
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	if on_floor and jump_time > GOING_UP_ON_JUMP_TIME:
		jump_time = 0
	if on_floor and jump_key:
		jump_time += step
	
	
	# Check jump
	if jump_time > GOING_UP_ON_JUMP_TIME:
		if linear_velocity.y < 0:
			linear_velocity.y += STOP_JUMP_FORCE * step
		jump_time += step
	elif jump_time > 0:
		linear_velocity.y = -JUMP_VELOCITY	
		jump_time += step
	
	#print("is_on_left_wall: ", is_on_left_wall(state), " is_on_right_wall: ", is_on_right_wall(state))
		

	if on_floor:
		if move_left_key and not move_right_key and not is_on_left_wall(state):
			if linear_velocity.x > -WALK_MAX_VELOCITY:
				linear_velocity.x -= WALK_ACCEL * step
		elif move_right_key and not move_left_key  and not is_on_right_wall(state):
			if linear_velocity.x < WALK_MAX_VELOCITY:
				linear_velocity.x += WALK_ACCEL * step
		else:
			var xv = abs(linear_velocity.x)
			xv -= WALK_DEACCEL * step
			if xv < 0:
				xv = 0
			linear_velocity.x = sign(linear_velocity.x) * xv
	else:
		
		if move_left_key and not move_right_key and not is_on_left_wall(state):
			if linear_velocity.x > -WALK_MAX_VELOCITY:
				linear_velocity.x -= AIR_ACCEL * step
		elif move_right_key and not move_left_key and not is_on_right_wall(state):
			if linear_velocity.x < WALK_MAX_VELOCITY:
				linear_velocity.x += AIR_ACCEL * step
		else:
			var xv = abs(linear_velocity.x)
			xv -= AIR_DEACCEL * step
			if xv < 0:
				xv = 0
			linear_velocity.x = sign(linear_velocity.x) * xv
	
	if(move_left_key):
		$AnimatedSprite.flip_h = true
	elif(move_right_key):
		$AnimatedSprite.flip_h = false
		
	# Finally, apply gravity and set back the linear velocity
	linear_velocity += state.get_total_gravity() * step
	state.set_linear_velocity(linear_velocity)



func is_on_floor(state):
	for x in range(state.get_contact_count()):
		var ci = state.get_contact_local_normal(x)
		if ci.dot(Vector2(0, -1)) > 0.6:
			return true
	return false
	
func is_on_right_wall(state):
	for x in range(state.get_contact_count()):
		var ci = state.get_contact_local_normal(x)
		if ci.dot(Vector2(-1, 0)) > 0.6:
			return true
	return false
	
func is_on_left_wall(state):
	for x in range(state.get_contact_count()):
		var ci = state.get_contact_local_normal(x)
		if ci.dot(Vector2(1, 0)) > 0.6:
			return true
	return false
