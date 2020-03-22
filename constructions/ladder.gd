extends Area2D

func _on_ladder_body_entered(body):
	if body.name=="player": body.onladder=true

func _on_ladder_body_exited(body):
	if body.name=="player": body.onladder=false
