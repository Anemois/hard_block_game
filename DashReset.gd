extends Area2D

func _on_body_entered(body):
	if(visible):
		body.DASHCNT = 0
		visible = false
