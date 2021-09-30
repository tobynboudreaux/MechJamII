extends InteractableItem

func interaction_interact(interactionComponentParent : Node) -> void:
	print("Heal up bb")
	interactionComponentParent.get_node(interactionComponentParent.interact_parent).health.heal(50)
	queue_free()
