extends RigidBody

# TODO: steering input currently presumes keyboard is used

onready var wheels := [
	$lf_wheel,
	$rf_wheel,
	$lr_wheel,
	$rr_wheel,
]

onready var lf_wheel := $lf_wheel
onready var rf_wheel := $rf_wheel
onready var lr_wheel := $lr_wheel
onready var rr_wheel := $rr_wheel


var throttle:float = 0.0
var braking:float = 0.0
var steering:float = 0.0

var ackermann:float = 0.15
var def_max_steer:float = 30.0
var max_steer:float = 30.0

var steer_value:float = 0.0
var steer_speed:float = 0.5
var steer_dir:int = 0


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_page_up"): max_steer = clamp(max_steer+1, 0, def_max_steer)
	if event.is_action_pressed("ui_page_down"): max_steer = clamp(max_steer-1, 0, def_max_steer)

func _physics_process(delta) -> void:
	throttle = Input.get_action_strength("accelerate")
	braking = Input.get_action_strength("brake")

	for w in wheels:
		w.simulate_suspensions(delta)
		w.add_torques(delta, throttle, braking)

	do_steering_ackerman()
#	do_steering(delta)


func do_steering_ackerman():
	steering = Input.get_action_strength("turn_right")-Input.get_action_strength("turn_left")

	# ease the steering for keyboard input
	if steering != 0 and (steer_dir == steering or steer_dir == 0):
		if steer_dir == steering:
			steer_value = clamp(steer_value+steer_speed, 0, max_steer)
		steer_dir = sign(steering)
	elif steer_value != 0:
		steer_value = clamp(steer_value-steer_speed, 0, max_steer)
		if steer_value < 1: # TODO: this is from old code, and is not entirely needed
			steer_value = 0
			steer_dir = 0

	var steer_value_rads := deg2rad(abs(steer_value))
	lf_wheel.steer_ackerman(-steer_dir, steer_value_rads, ackermann*steer_dir)
	rf_wheel.steer_ackerman(-steer_dir, steer_value_rads, ackermann*steer_dir)


func do_steering(delta):
	var turn_input = Input.get_action_strength("turn_right") - Input.get_action_strength("turn_left")

	if   turn_input != 0: steer_value = clamp(steer_value + steer_speed * sign(turn_input), -max_steer, max_steer)
	elif steer_value > 0: steer_value = clamp(steer_value - steer_speed, 0, max_steer)
	else:                 steer_value = clamp(steer_value + steer_speed, -max_steer, 0)

	var steer_value_rads := deg2rad(steer_value)
	lf_wheel.steer(-steer_value_rads)
	rf_wheel.steer(-steer_value_rads)


func _process(_delta:float) -> void:
	debug.monitor(
		"%s\n" % [name]
		+ "    throttle: %s\n" % [throttle]
		+ "    brakes: %s\n" % [braking]
		+ "    steering: %s\n" % [steering]
		+ "    steer_value: %s\n" % [steer_value]
		+ "    steer_dir: %s\n" % [steer_dir]
		+ "    max_steer: %s\n" % [max_steer]
	)

	debug.draw_line_3d(
		[global_transform.origin, global_transform.origin - transform.basis.z],
		Color.white
		)


