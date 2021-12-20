extends RigidBody

onready var wheels := [
	$lf_wheel,
	$rf_wheel,
	$lr_wheel,
	$rr_wheel,
]

#onready var lf_wheel := $lf_wheel
#onready var rf_wheel := $rf_wheel
#onready var lr_wheel := $lr_wheel
#onready var rr_wheel := $rr_wheel


var throttle:float = 0.0
var braking:float = 0.0


func _physics_process(delta) -> void:
	throttle = Input.get_action_strength("accelerate")
	braking = Input.get_action_strength("brake")

	for w in wheels:
		w.simulate_suspensions(delta)
		w.add_torques(delta, throttle, braking)




func _process(_delta:float) -> void:
	debug.monitor(
		"%s\n" % [name]
		+ "    throttle: %s\n" % [throttle]
	)

	debug.draw_line_3d(
		[global_transform.origin, global_transform.origin - transform.basis.z],
		Color.white
		)


