extends VehicleBody

############################################################
# behaviour values

export var MAX_ENGINE_FORCE = 200.0
export var MAX_BRAKE_FORCE = 5.0
export var MAX_STEER_ANGLE = 0.5

export var steer_speed = 5.0

var steer_target = 0.0
var steer_angle = 0.0

############################################################
# Input

export var joy_steering = JOY_ANALOG_LX
export var steering_mult = -1.0
export var joy_throttle = JOY_ANALOG_R2
export var throttle_mult = 1.0
export var joy_brake = JOY_ANALOG_L2
export var brake_mult = 1.0

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _physics_process(delta):
	var steer_val = steering_mult * Input.get_joy_axis(0, joy_steering)
	var throttle_val = throttle_mult * Input.get_joy_axis(0, joy_throttle)
	var brake_val = brake_mult * Input.get_joy_axis(0, joy_brake)
	
	# overrules for keyboard
	if Input.is_action_pressed("ui_up"):
		throttle_val = forward()
	if Input.is_action_pressed("ui_down"):
		throttle_val = backwards()
	if Input.is_action_pressed("ui_left"):
		throttle_val = left()
	elif Input.is_action_pressed("ui_right"):
		throttle_val = right()
	
	engine_force = throttle_val * MAX_ENGINE_FORCE
	brake = brake_val * MAX_BRAKE_FORCE
	
	steer_target = steer_val * MAX_STEER_ANGLE
	if (steer_target < steer_angle):
		steer_angle -= steer_speed * delta
		if (steer_target > steer_angle):
			steer_angle = steer_target
	elif (steer_target > steer_angle):
		steer_angle += steer_speed * delta
		if (steer_target < steer_angle):
			steer_angle = steer_target
	
	steering = steer_angle
	
	if Input.is_action_pressed("ui_accept"):
		elevate_shovel(delta)
	elif Input.is_action_pressed("ui_decline"):
		descend_shovel(delta)

func forward() -> float:
	$VehicleWheel_Left.use_as_traction = true
	$VehicleWheel_Right.use_as_traction = true
	return 1.0

func backwards() -> float:
	$VehicleWheel_Left.use_as_traction = true
	$VehicleWheel_Right.use_as_traction = true
	return -1.0

func left() -> float:
	$VehicleWheel_Left.use_as_traction = true
	$VehicleWheel_Right.use_as_traction = false
	return 1.2

func right() -> float:
	$VehicleWheel_Left.use_as_traction = false
	$VehicleWheel_Right.use_as_traction = true
	return 1.2

func elevate_shovel(delta: float) -> void:
	if $RobotShovel.rotation.z > -PI/6:
		$RobotShovel.rotate_z(-delta)
		
func descend_shovel(delta: float) -> void:
		if $RobotShovel.rotation.z < 0:
			$RobotShovel.rotate_z(delta)
