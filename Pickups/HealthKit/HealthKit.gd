extends InteractableItem

func interaction_interact(interactionComponentParent : Node) -> void:
	print("Heal up bb")
	interactionComponentParent.get_node(interactionComponentParent.interact_parent).health.current_health = 100
	queue_free()
