extends CharacterBody3D

# Señales
signal hit
signal power_changed(text_info)

# Configuración
@export var speed = 14
@export var fall_acceleration = 75
@export var jump_impulse = 20
@export var bounce_impulse = 16

var target_velocity = Vector3.ZERO

# --- VARIABLES DE PODERES ---
var jump_count = 0
var active_power = -1 # 0: Doble Salto, 1: Invencible
var power_time_left = 0.0
var is_invincible = false

func _physics_process(delta):
	var direction = Vector3.ZERO
	if Input.is_action_pressed("move_right"): direction.x += 1
	if Input.is_action_pressed("move_left"): direction.x -= 1
	if Input.is_action_pressed("move_back"): direction.z += 1
	if Input.is_action_pressed("move_forward"): direction.z -= 1

	if direction != Vector3.ZERO:
		direction = direction.normalized()
		$Pivot.basis = Basis.looking_at(direction)
		$AnimationPlayer.speed_scale = 4
	else:
		$AnimationPlayer.speed_scale = 1

	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed

	if not is_on_floor():
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)
	else:
		jump_count = 0

	# --- SALTO Y DOBLE SALTO ---
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			target_velocity.y = jump_impulse
			jump_count = 1
		elif active_power == 0 and jump_count == 1: 
			target_velocity.y = jump_impulse
			jump_count = 2

	# --- COLISIONES ---
	for index in range(get_slide_collision_count()):
		var collision = get_slide_collision(index)
		if collision.get_collider() == null: continue
		if collision.get_collider().is_in_group("mob"):
			var mob = collision.get_collider()
			if Vector3.UP.dot(collision.get_normal()) > 0.1:
				mob.squash()
				target_velocity.y = bounce_impulse
				break

	velocity = target_velocity
	move_and_slide()
	$Pivot.rotation.x = PI / 6 * velocity.y / jump_impulse
	
	# --- TEMPORIZADOR Y DESCRIPCIÓN ---
	if active_power != -1:
		power_time_left -= delta
		# AQUÍ ESTÁ EL CAMBIO: Usamos la descripción detallada
		var info = active_power_description() + "\nQuedan: " + str(snapped(power_time_left, 0.1)) + "s"
		power_changed.emit(info)
		
		if power_time_left <= 0:
			desactivar_poder()

func activar_poder(tipo, duracion):
	desactivar_poder()
	active_power = tipo
	power_time_left = duracion
	
	match active_power:
		0: pass # Doble salto
		1: # Invencibilidad
			is_invincible = true
			$Pivot/Character.scale = Vector3(1.3, 1.3, 1.3)

func desactivar_poder():
	if active_power == 1:
		is_invincible = false
		$Pivot/Character.scale = Vector3(1, 1, 1)
	
	active_power = -1
	power_changed.emit("")

# NUEVA FUNCIÓN CON LAS DESCRIPCIONES
func active_power_description():
	match active_power:
		0: return "¡DOBLE SALTO!"
		1: return "¡INVENCIBILIDAD!"
		_: return ""

func die():
	hit.emit()
	queue_free()

func _on_mob_detector_body_entered(body):
	if is_invincible:
		body.queue_free()
	else:
		hit.emit()
		body.queue_free()
