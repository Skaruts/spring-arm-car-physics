extends RigidBody

onready var wheels:Array = [
	$lf_wheel,
	$rf_wheel,
	$lr_wheel,
	$rr_wheel,
]

# onready var RF_Wheel = $RF_Wheel
# onready var LF_Wheel = $LF_Wheel
# onready var RR_Wheel = $RR_Wheel
# onready var LR_Wheel = $LF_Wheel


# Engine power (multiplies angular motor TARGET VELOCITY): max speed
# Wheel Force Limit (multiplies angular motor FORCE LIMIT): acceleration



func _ready():
	pass


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("recover"):
		print("recovering")

#		$VehicleRigidBody.translation.y = 5
#		$VehicleRigidBody.rotation = original_rot# Vector3(0,$VehicleRigidBody.rotation.y,0)


var throttle:float = 0.0
func _physics_process(delta):
	throttle = Input.get_action_strength("accelerate")-Input.get_action_strength("brake")
	for w in wheels:
		w.simulate_suspensions(delta)

		w.add_torques(delta, throttle)






func _process(_delta:float) -> void:
	debug.monitor(
		"%s\n" % [name]
		+ "    throttle: %s\n" % [throttle]
	)

	debug.draw_line_3d(
		[global_transform.origin, global_transform.origin - transform.basis.z],
		Color.white
		)

	pass

