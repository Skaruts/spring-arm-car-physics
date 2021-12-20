extends Node2D
# autoloaded script


onready var label := Label.new()
onready var ig := ImmediateGeometry.new()

var text := ""
var text_scale := 1.0
var draw_bg := false
var bg_color := Color(0,0,0,0.75)

# TODO: sort this out based on amount of lines and screen size
var _rect_size := Rect2(0, 0, 300, 1000)

var curr_line_color = Color.white
var ig_verts = []
var ig_colors = []


func _ready() -> void:
	add_child(label)
	label.name = "debug_label"
	label.rect_scale = Vector2.ONE * text_scale

	add_child(ig)
	ig.name = "debug_ig"
	ig.cast_shadow = GeometryInstance.SHADOW_CASTING_SETTING_OFF

	var mat = SpatialMaterial.new()
	ig.material_override = mat

	mat.vertex_color_use_as_albedo = true
	mat.params_line_width   = 5		# not working in GLES2
	mat.flags_unshaded      = true
	mat.flags_no_depth_test = true
	mat.flags_transparent = true


func _process(_delta: float) -> void:
	label.text = text
	text = ""

	ig.clear()
	if ig_verts.size() > 0:
		ig.begin(Mesh.PRIMITIVE_LINES)

		for i in ig_verts.size():
			ig.set_color(ig_colors[i])
			ig.add_vertex(ig_verts[i])

		ig.end()

		ig_verts.clear()
		ig_colors.clear()



func _draw() -> void:
	if draw_bg: draw_rect(_rect_size, bg_color, true)


func monitor(key, val=null, float_precision=2) -> void:
	if val != null:
		var str_val = ""
		if typeof(val) == TYPE_REAL:
			str_val = "%." + str(int(float_precision)) + "f"
			str_val = str_val % [val]
		else:
			str_val = str(val)

		text += key + str_val + "\n"
	else:
		text += key + "\n"	# no 'val' given, assume key is 'val'




#func clear(full=false):
#	ig.clear()
#	if full:
#		ig_verts.clear()
#		ig_colors.clear()


func set_color(color:Color):
	curr_line_color = color


func draw_line_3d(verts:Array, color):
	var colors:Array = _check_colors(verts.size(), color)

	ig_verts += verts
	ig_colors += colors


func _set_colors(size, color) -> Array:
	var colors := []
	for i in size:
		colors.append(color)
	return colors


func _check_colors(size, color) -> Array:
	if not color:      return _set_colors(size, curr_line_color)
	if color is Color: return _set_colors(size, color)
	return color





