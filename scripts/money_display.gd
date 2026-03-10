extends VBoxContainer

@onready var money: PlayerResource = PlayerState.get_instance().money


func _ready() -> void:
	money.current_changed.connect(update.unbind(1))
	update()


func update() -> void:
	$Label.text = str(money.current)
