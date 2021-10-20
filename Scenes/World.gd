extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
var counter = 0
func _physics_process(delta):
	counter = counter + 1
	if (counter < 10):
		return
	else:
		counter = 0
	$Panel/VBoxContainer/HBoxContainer/Torque_Right.text = String(Global.torque_r)
	$Panel/VBoxContainer/HBoxContainer_2/Torque_Left.text = String(Global.torque_l)
	$Panel/VBoxContainer/HBoxContainer_4/Speed_r.text = String(Global.titad_r)
	$Panel/VBoxContainer/HBoxContainer_6/Speed_l.text = String(Global.titad_l)
	$Panel/VBoxContainer/HBoxContainer_5/Acceleration_r.text = String(Global.titadd_r)
	$Panel/VBoxContainer/HBoxContainer_7/Acceleration_l.text = String(Global.titadd_l)
	$Panel/VBoxContainer/HBoxContainer_3/Torque_Shovel.text = String(Global.shovel_torque)
