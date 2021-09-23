extends Area

export var muzzle_velocity = 200
export var g = Vector3.DOWN * 20

var velocity = Vector3.ZERO
onready var projectile_body = get_node("ProjectileMesh")

const meshMaterials : Array = [
	preload("res://Assets/DefaultMesh.tres"),
	preload("res://Assets/DefaultMesh.tres"),
	preload("res://Assets/DefaultMesh.tres")
	]
	
func _physics_process(delta):
	velocity += g * delta
	look_at(transform.origin + velocity.normalized(), Vector3.UP)
	transform.origin += velocity * delta
	
func set_vars(vel, g_val):
	muzzle_velocity = vel
	g = g_val
	
func change_mesh(newMesh):
	projectile_body.mesh = meshMaterials[newMesh]
	
export (PackedScene) var Projectile
