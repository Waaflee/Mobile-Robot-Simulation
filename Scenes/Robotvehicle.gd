extends VehicleBody

var model = Model.new()
############################################################
# behaviour values
export var STATE = 0

export var MAX_ENGINE_FORCE = 200.0
export var MAX_BRAKE_FORCE = 5.0
export var MAX_STEER_ANGLE = 0.5

export var steer_speed = 5.0

var steer_target = 0.0
var steer_angle = 0.0

############################################################
var previous_rotation: Vector3 = Vector3()
var previous_traslation: Vector3 = Vector3()
var previous_translation_speed = 0.0
var previous_rotation_speed = 0.0

var shovel_previous_rotation = 0.0
var shovel_previous_speed = 0.0
var shovel_previous_acceleration = 0.0
############################################################

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	Engine.time_scale = 1
	previous_rotation = rotation
	previous_traslation = translation
	shovel_previous_rotation = $RobotShovel.rotation.z
	pass


func _physics_process(delta):
	var throttle_val = 0.0
	var brake_val = 0.0
	var steer_val = 0.0
	# overrules for keyboard
	if Input.is_action_pressed("ui_up"):
		throttle_val = forward()
	if Input.is_action_pressed("ui_down"):
		throttle_val = backwards()
	if Input.is_action_pressed("ui_left"):
		throttle_val = left()
	elif Input.is_action_pressed("ui_right"):
		throttle_val = right()
	
	if STATE == 0:
		throttle_val = 0.0
	elif STATE == 1:
		throttle_val = forward()
	elif STATE == 2:
		throttle_val = backwards()
	elif STATE == 4:
		throttle_val = left()
	elif STATE == 3:
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

	var rotation_speed = ((rotation.y - previous_rotation.y) / delta)
	var translation_speed = abs(previous_traslation.distance_to(translation) / delta) / 10
	
	var angular_acceleration = (rotation_speed - previous_rotation_speed) / delta
	var acceleration = (translation_speed - previous_translation_speed) / delta
	
	var ang_speed = model.get_angular_speed(rotation_speed, translation_speed, STATE)
	var ang_acceleration = model.get_angular_acceleration(angular_acceleration, acceleration, STATE)
	var torque = model.get_torque(ang_acceleration, STATE)
	
	var shovel_rotation = $RobotShovel.rotation.z
	var shovel_speed = (shovel_rotation - shovel_previous_rotation) / delta
	var shovel_acceleration = (shovel_speed - shovel_previous_speed) / delta
	
	var shovel_torque = model.get_shovel_torque(shovel_rotation, shovel_acceleration)
	
	Global.titad_r = abs(ang_speed["tita_r"])
	Global.titad_l = abs(ang_speed["tita_l"])
	Global.titadd_r = abs(ang_acceleration["tita_r"])
	Global.titadd_l = abs(ang_acceleration["tita_l"])
	Global.torque_l = clamp(abs(torque["tita_l"]), 0, 5.565)
	Global.torque_r = clamp(abs(torque["tita_r"]), 0, 5.565)
	
	Global.shovel_torque = shovel_torque
	
	
	previous_traslation = translation
	previous_rotation = rotation
	previous_rotation_speed = rotation_speed
	previous_translation_speed = translation_speed
	shovel_previous_rotation = $RobotShovel.rotation.z
	shovel_previous_speed = shovel_speed

func forward() -> float:
	$VehicleWheel_Left.use_as_traction = true
	$VehicleWheel_Right.use_as_traction = true
	return 1.0

func backwards() -> float:
	$VehicleWheel_Left.use_as_traction = true
	$VehicleWheel_Right.use_as_traction = true
	return -1.0

func right() -> float:
	$VehicleWheel_Left.use_as_traction = true
	$VehicleWheel_Right.use_as_traction = false
	return 1.2

func left() -> float:
	$VehicleWheel_Left.use_as_traction = false
	$VehicleWheel_Right.use_as_traction = true
	return 1.2

func elevate_shovel(delta: float) -> void:
	if $RobotShovel.rotation.z > -PI/6:
		$RobotShovel.rotate_z(-delta)
		
func descend_shovel(delta: float) -> void:
		if $RobotShovel.rotation.z < 0:
			$RobotShovel.rotate_z(delta)
