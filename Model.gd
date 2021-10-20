extends Node

class_name Model

const width = 0.5
const radius = 0.05

func get_angular_speed(rotation_speed: float, lineal_speed: float, STATE: int) -> Dictionary:
	var tita_r = 0
	var tita_l = 0
	if (STATE == 4):
		tita_r = (rotation_speed * width) / radius
		tita_l = 0
	elif (STATE == 3):
		tita_l = (rotation_speed * width) / radius
		tita_r = 0
	else:
		tita_r = lineal_speed / radius
		tita_l = lineal_speed / radius
	return {"tita_r": tita_r, "tita_l": tita_l}
	
func get_angular_acceleration(rotation_acceleration: float, lineal_acceleration: float, STATE: int) -> Dictionary:
	var tita_r = 0
	var tita_l = 0
	if (STATE == 4):
		tita_r = (rotation_acceleration * width) / radius
		tita_l = 0
	elif (STATE == 3):
		tita_l = (rotation_acceleration * width) / radius
		tita_r = 0
	else:
		tita_r = lineal_acceleration / radius
		tita_l = lineal_acceleration / radius
	return {"tita_r": tita_r, "tita_l": tita_l}

func get_torque(ang_accelerations: Dictionary, STATE: int) -> Dictionary:
	var L = 0.5 		#ancho del robot
	var M_T = 400 		#masa total
	var r_r = 0.05 		#radio de la rueda
	var r_t = r_r		#radio del tensor
	var m_r = 4		    #masa rueda
	var m_t = 1.5		#masa tensor
	var I_r = 1/2*m_r*pow(r_r,2) #momento de inercia de la rueda
	var I_t = 1/2*m_t*pow(r_t,2) #momento de inercia del tensor
	var R = 0
	var I_T = 0
	var M = []
	
	# 4 == LEFT
	# 3 == RIGHT
	
	#-------------CURVAS----------------
	if (STATE == 3 or STATE == 4):
		R = L/2			#radio de giro
		I_T = M_T*pow(R,2)	#momento de inercia de robot
	else:
		#-------------RECTAS----------------	
		R = pow(10,20)  	#radio de giro
		I_T = 0		#momento de inercia de robot
		var torque = ang_accelerations["tita_r"] * r_r * M_T / 10
		return {"tita_l": torque, "tita_r": torque}



	#-------------MATRIZ DE INERCIA, VECTOR DE ACELERACIONES ANGULARES Y TORQUE-------------
	M = [[1/4*M_T*pow(r_r,2)+I_T*pow(r_r,2)/pow(L,2)+I_r+2*I_t , 1/4*M_T*pow(r_r,2)-I_T*pow(r_r,2)/pow(L,2)] , [1/4*M_T*pow(r_r,2)-I_T*pow(r_r,2)/pow(L,2) , 1/4*M_T*pow(r_r,2)+I_T*pow(r_r,2)/pow(L,2)+I_r+2*I_t]]
	var ddtheta = [ang_accelerations["tita_l"], ang_accelerations["tita_r"]]
	var tau = {
		"tita_l": M[0][0] * ddtheta[0] + M[0][1] * ddtheta[1], 
		"tita_r": M[1][0] * ddtheta[0] + M[1][1] * ddtheta[1]
	}
	if STATE == 3:
		tau["tita_r"] = 0
	if STATE == 4:
		tau["tita_l"] = 0
	return tau

func get_shovel_torque(theta: float, ddtheta: float) -> float:
	var M= 7	#masa eslabon
	var L= 0.2	#longitud hasta el centro del eslabon
	var g= 9.81	#aceleracion de la gravedad

	var tau = M*pow(L,2)*ddtheta+M*g*L*cos(theta)
	if (ddtheta == 0):
		tau = 0
	return tau
