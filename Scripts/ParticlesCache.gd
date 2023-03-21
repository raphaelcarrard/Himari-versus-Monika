extends Node2D

var materials = [
	preload("res://Particles/Drop.tres"),
	preload("res://Particles/PowerFaucet.tres"),
	preload("res://Particles/Bullet.tres"),
	preload("res://Particles/ButtonParticles.tres"),
]

func _ready():
	for material in materials:
		var particles_instance = Particles2D.new()
		particles_instance.position = Vector2(0, 0)
		particles_instance.set_process_material(material)
		particles_instance.set_one_shot(true)
		particles_instance.set_emitting(true)
		self.add_child(particles_instance)
