extends SpringArm

onready var car = $".."

var starting_length = 0.5
var compress = 0
var spring:float = 15000.0
var bump:float = 1000
var rebound:float = 1000

export(float, 0, 2, 0.05) var peak = 0.5          # 1
export(float, 1, 2.5, 0.05) var x_shape = 0.05    # 1.35
export(float, 1, 2.5, 0.05) var z_shape = 2.5    # 1.65
export(float, 0, 20, 0.1) var stiff = 50          # 10
export(float, -10, 0, 0.05) var curve = 0         # 0
export(float, 0, 500, 1) var wheel_mass = 10

var x_force:float
var y_force:float
var z_force:float
var prev_compress:float = compress
var prev_pos:Vector3
var z_vel:float
var spin:float
var radius:float = 0.4
var wheel_moment:float

const TORQUE_POWER:float = 1000.0
const BRAKE_POWER:float = 2000.0
var net_torque:float


func _ready():
	spring_length = starting_length
#	add_excluded_object(car)
#	$RayCast.add_exception(car)
#	$RayCast.add_exception(self)


func _process(delta: float) -> void:
	$mesh.rotate_x(-spin * delta)

	do_debug_stuff()


func pacejka(slip, tire_shape):
	return y_force * peak * sin(tire_shape * atan(stiff * slip - curve * (stiff * slip - atan(stiff * slip))))


func simulate_suspensions(delta):
	compress = 1 - (get_hit_length() / spring_length)  # 1 is fully compressed
	y_force = spring * (compress * spring_length)

	var compression_diff = compress - prev_compress
	if compression_diff >= 0: y_force += bump * compression_diff / delta
	else:                     y_force += rebound * compression_diff / delta

	var local_vel = global_transform.basis.xform_inv((global_transform.origin - prev_pos) / delta)
	z_vel = -local_vel.y
	var planar_vect = Vector2(local_vel.x, local_vel.y).normalized()
	prev_pos = global_transform.origin

	var x_slip = asin(clamp(-planar_vect.x, -1, 1))
	var z_slip = 0
	if z_vel != 0:
		z_slip = (spin * radius - z_vel) / abs(z_vel)

	x_force = pacejka(x_slip, x_shape)
	z_force = pacejka(z_slip, z_shape)

	var contact = $RayCast.get_collision_point() - car.global_transform.origin
	var normal = $RayCast.get_collision_normal()

	if $RayCast.is_colliding():
		car.add_force(global_transform.basis.x * x_force, contact)
		car.add_force(normal * y_force, contact)
		car.add_force(global_transform.basis.y * z_force, contact)

	prev_compress = compress


func add_torques(delta, throttle, braking):
	var drive_torque = TORQUE_POWER * throttle

	net_torque = z_force * radius
	net_torque += drive_torque

	wheel_moment = 0.5 * wheel_mass * radius * radius

	var brake_torque = BRAKE_POWER * braking
	if spin < 5 and brake_torque > abs(net_torque):
		spin = 0
	else:
		net_torque -= brake_torque * sign(spin)
		spin += delta * net_torque / wheel_moment


func steer_ackerman(input, max_steer, ackermann):
	rotation.y = max_steer * (input + (1 - cos(input * 0.5 * PI)) * ackermann)

func steer(steer_angle):
	rotation.y = steer_angle


func do_debug_stuff():
	debug.monitor(
		"%s\n" % [name]
		+ "    yforce:  %s\n" % [y_force]
#		+ "    t: %s\n" % [throttle]
		+ "    spin:  %s\n" % [spin]
		+ "    net_torque:  %s\n" % [net_torque]
		+ "    wheel_moment:  %s\n" % [wheel_moment]
		+ "    rot_y:  %s\n" % [rotation.y]
#		+ "    b: %s\n" % [bump]
#		+ "    r: %s\n" % [rebound]
#		+ "    c: %s\n" % [compress]
#		+ "    pc: %s" % [prev_compress]
	)

	debug.draw_line_3d(
		[
			global_transform.origin, global_transform.origin - global_transform.basis.y],
			Color.red
		)
