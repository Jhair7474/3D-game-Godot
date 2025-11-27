extends Area3D

# 0 = Doble Salto, 1 = Invencibilidad
enum PowerType { DOUBLE_JUMP = 0, INVINCIBILITY = 1 }

var current_type

func _ready():
	var types = [PowerType.DOUBLE_JUMP, PowerType.INVINCIBILITY]
	current_type = types[randi() % types.size()]
	
	var material = StandardMaterial3D.new()
	match current_type:
		PowerType.DOUBLE_JUMP:
			material.albedo_color = Color.GREEN
		PowerType.INVINCIBILITY:
			material.albedo_color = Color.GOLD
			
	if has_node("MeshInstance3D"):
		$MeshInstance3D.material_override = material

func _on_body_entered(body):
	if body.name == "Player":
		body.activar_poder(current_type, 5.0)
		queue_free()
