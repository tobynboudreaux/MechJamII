extends InteractableItem

func interaction_interact(interactionComponentParent : Node) -> void:
	print("U GOT GATORADE")
	interactionComponentParent.get_node(interactionComponentParent.interact_parent).has_energy = true
	queue_free()
