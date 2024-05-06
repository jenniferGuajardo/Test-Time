extends MeshInstance3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Rotate around the object's local X axis by 0.05 radians.
	rotate_object_local(Vector3(1, 0, 0), 0.05)
	pass
