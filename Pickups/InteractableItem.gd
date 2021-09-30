extends Node
class_name InteractableItem

func interaction_can_interact(interactionComponentParent : Node) -> bool:
	return interactionComponentParent is Pilot
