extends Node

@export var mob_scene: PackedScene
@export var powerup_scene: PackedScene # <--- ESTA LINEA ES LA QUE HACE QUE APAREZCA LA CASILLA

# Variable para llevar la cuenta de vidas
var lives = 3

func _ready():
	$UserInterface/Retry.hide()
	# Inicializamos el texto de las vidas al arrancar
	update_lives_ui()
	
	# Conectamos la señal del jugador para ver el texto del poder
	# (Verifica que tu Player.gd ya tenga el script nuevo)
	if $Player.has_signal("power_changed"):
		$Player.power_changed.connect(_on_player_power_changed)

func _on_mob_timer_timeout():
	var mob = mob_scene.instantiate()
	var mob_spawn_location = get_node("SpawnPath/SpawnLocation")
	mob_spawn_location.progress_ratio = randf()

	var player_position = $Player.position
	mob.initialize(mob_spawn_location.position, player_position)

	add_child(mob)
	
	# Conectamos la señal de que el monstruo fue aplastado (Score)
	if mob.has_signal("squashed"):
		mob.squashed.connect($UserInterface/ScoreLabel._on_mob_squashed.bind())

func _on_player_hit():
	# 1. Restamos una vida
	lives -= 1
	
	# 2. Actualizamos el texto en pantalla
	update_lives_ui()
	
	# 3. Verificamos si quedan vidas
	if lives > 0:
		print("¡Auch! Vidas restantes: ", lives)
	else:
		# GAME OVER
		$MobTimer.stop()
		
		# Detenemos también los poderes
		if has_node("PowerUpTimer"):
			$PowerUpTimer.stop()
			
		$UserInterface/Retry.show()
		$Player.queue_free()

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept") and $UserInterface/Retry.visible:
		get_tree().reload_current_scene()

func update_lives_ui():
	# Si tienes los corazones en un contenedor llamado LivesContainer
	if $UserInterface.has_node("LivesContainer"):
		var hearts = $UserInterface/LivesContainer.get_children()
		for i in range(hearts.size()):
			hearts[i].visible = (i < lives)

# --- NUEVO: SISTEMA DE PODERES ---

func _on_player_power_changed(texto):
	# Busca el Label llamado "PowerLabel"
	if $UserInterface.has_node("PowerLabel"):
		$UserInterface/PowerLabel.text = texto

func _on_power_up_timer_timeout():
	print("1. El Timer ha llegado a cero") # <--- Si no ves esto, el Timer no está funcionando
	
	if powerup_scene == null:
		print("2. ERROR: La variable powerup_scene está vacía/null") # <--- Si ves esto, el arrastre falló
		return

	print("3. Creando PowerUp...")
	var powerup = powerup_scene.instantiate()
	
	# Resto del código...
	var rand_x = randf_range(-15, 15)
	var rand_z = randf_range(-15, 15)
	powerup.position = Vector3(rand_x, 1, rand_z)
	add_child(powerup)
	print("4. PowerUp añadido en: ", powerup.position)
