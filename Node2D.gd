extends Node2D

# current Line2D object
var active_line

# materials used for pen and eraser
var draw_material
var erase_material

enum mode {
	draw,
	erase,
	undo,
	count = 3,
}

var current_mode = mode.draw

func _ready():
	draw_material = CanvasItemMaterial.new()
	draw_material.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
	erase_material = CanvasItemMaterial.new()
	erase_material.blend_mode = CanvasItemMaterial.BLEND_MODE_SUB
	pass

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_LEFT:
				if current_mode == mode.undo:
					undo_last()
					return
				active_line = Line2D.new()
				# alternating between draw/erase mode
				if current_mode == mode.draw:
					print("Draw mode")
					active_line.default_color = Color(randf(), randf(), randf(), 1)
					active_line.material = draw_material
				elif current_mode == mode.erase:
					print("Eraser mode")
					active_line.default_color = Color(0, 0, 0, 1)
					active_line.material = erase_material
				active_line.position = event.position
				active_line.width = 15
				active_line.points = [Vector2(0, 0)]
				$ViewportContainer/Viewport.add_child(active_line)
		else:
			# button up
			if event.button_index == BUTTON_RIGHT:
				switch_mode()
	elif event is InputEventScreenDrag:
		if current_mode == mode.draw or current_mode == mode.erase:
			var points = active_line.points
			points.append(event.position - active_line.position)
			active_line.points = points
	pass

func undo_last():
	var count = $ViewportContainer/Viewport.get_child_count()
	if count > 0:
		print("Undo: current stroke count:", count)
		$ViewportContainer/Viewport.get_child(count - 1).queue_free()
	pass

func switch_mode():
	current_mode = (current_mode+1) % mode.count
	print("Switching mode to:", current_mode)
	match(current_mode):
		mode.draw:
			$Label.text = "Draw Mode. Right click to switch"
		mode.erase:
			$Label.text = "Eraser Mode. Right click to switch"
		mode.undo:
			$Label.text = "Undo Mode. Left click to Undo, Right click to switch"