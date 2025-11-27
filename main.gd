extends Node

@export var mob_scene: PackedScene

# Variable para llevar la cuenta de vidas
var lives = 3

func _ready():
	$UserInterface/Retry.hide()
	# Inicializamos el texto de las vidas al arrancar
	update_lives_ui()

func _on_mob_timer_timeout():
	var mob = mob_scene.instantiate()
	var mob_spawn_location = get_node("SpawnPath/SpawnLocation")
	mob_spawn_location.progress_ratio = randf()

	var player_position = $Player.position
	mob.initialize(mob_spawn_location.position, player_position)

	add_child(mob)
	
	mob.squashed.connect($UserInterface/ScoreLabel._on_mob_squashed.bind())

func _on_player_hit():
	# 1. Restamos una vida
	lives -= 1
	
	# 2. Actualizamos el texto en pantalla
	update_lives_ui()
	
	# 3. Verificamos si quedan vidas
	if lives > 0:
		# Si aún quedan vidas, solo imprimimos un mensaje (opcional)
		# y el juego continúa porque el enemigo ya fue eliminado en Player.gd
		print("¡Auch! Vidas restantes: ", lives)
	else:
		# Si las vidas llegan a 0, ejecutamos la lógica de Game Over
		$MobTimer.stop()
		$UserInterface/Retry.show()
		# Opcional: Ahora sí eliminamos al jugador visualmente si quieres
		$Player.queue_free() 

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept") and $UserInterface/Retry.visible:
		get_tree().reload_current_scene()

# Función auxiliar para actualizar el texto
func update_lives_ui():
# Obtenemos una lista de los 3 nodos TextureRect (los corazones)
	# que están dentro del contenedor.
	var hearts = $UserInterface/LivesContainer.get_children()
	
	# Recorremos la lista de corazones usando un bucle "for".
	# 'i' es el índice actual (0, 1, y 2).
	for i in range(hearts.size()):
		# La magia ocurre aquí:
		# Si el índice 'i' es menor que la cantidad de vidas actuales,
		# la condición es 'true' y el corazón se hace visible.
		# Si el índice es igual o mayor (ej: índice 2 cuando solo quedan 2 vidas),
		# la condición es 'false' y el corazón se oculta.
		hearts[i].visible = (i < lives)
