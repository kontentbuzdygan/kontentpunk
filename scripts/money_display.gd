extends VBoxContainer

@onready
var money: PlayerResource = PlayerState.get_instance().get_resource(PlayerResource.Type.MONEY)


func _ready() -> void:
	money.current_changed.connect(update.unbind(1))
	update()


func update() -> void:
	$Label.text = str(money.current)
