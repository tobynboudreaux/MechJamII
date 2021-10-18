extends TextureProgress

func update_bar(amount):
	self.value -= amount;
	
func set_max_health(value):
	self.max_value = value
	self.value = value
