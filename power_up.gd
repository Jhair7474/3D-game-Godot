extends Area3D

# Estos números deben coincidir con los que pusimos en player.gd
# 0 = Tiempo, 1 = Doble Salto, 2 = Invencibilidad
enum PowerType { TIME_STOP = 0, DOUBLE_JUMP = 1, INVINCIBILITY = 2 }

var current_type

func _ready():
	# Elegir un tipo de poder al azar
	var types = [PowerType.TIME_STOP, PowerType.DOUBLE_JUMP, PowerType.INVINCIBILITY]
	current_type = types[randi() % types.size()]
	
	# CAMBIAR COLOR SEGÚN EL PODER (Visual)
	# Creamos un material nuevo al vuelo
	var material = StandardMaterial3D.new()
	
	match current_type:
		PowerType.TIME_STOP:
			material.albedo_color = Color.CYAN # Azul claro
		PowerType.DOUBLE_JUMP:
			material.albedo_color = Color.GREEN # Verde
		PowerType.INVINCIBILITY:
			material.albedo_color = Color.GOLD # Dorado/Amarillo
			
	# Asignamos el material a la esfera (MeshInstance3D)
	# Asegúrate de que tu nodo se llame "MeshInstance3D"
	if has_node("MeshInstance3D"):
		$MeshInstance3D.material_override = material

func _on_body_entered(body):
	# Verificamos si lo que tocó el poder es el Jugador
	if body.name == "Player":
		# Le damos el poder por 5 segundos
		body.activar_poder(current_type, 5.0)
		# Desaparecemos el objeto PowerUp
		queue_free()
