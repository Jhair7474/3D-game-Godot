extends Control

func _ready():
	# Al inicio, el menú debe estar oculto
	hide()

func _unhandled_input(event):
	# Si se presiona la tecla "pause" (Escape)
	if event.is_action_pressed("pause"):
		# Cambiamos la visibilidad
		visible = !visible
		# Pausamos o despausamos el juego
		get_tree().paused = visible
		
		# Gestión del ratón (opcional según tu juego)
		if visible:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		# else:
			# Si tu juego es FPS o usa captura de ratón, descomenta la siguiente línea:
			# Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# Esta función debe conectarse al botón "Reanudar"
func _on_reanudar_pressed():
	hide()
	get_tree().paused = false

# Esta función debe conectarse al botón "Reiniciar"
func _on_reiniciar_pressed():
	get_tree().paused = false # Importante despausar antes de recargar
	get_tree().reload_current_scene()

# Esta función debe conectarse al botón "Salir" (si lo tienes)
func _on_salir_pressed():
	get_tree().quit()
