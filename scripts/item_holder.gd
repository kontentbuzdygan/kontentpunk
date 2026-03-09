class_name ItemHolder
extends CenterContainer

@export var item_type: ItemResource.ITEM_TYPE
@onready var item_slot: TextureRect = $ItemSlot
signal item_equipped(item: ItemResource)

var _item: ItemResource


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return (data as Item).get_item_resource().item_type == item_type


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	print("dropped")
	var item = data as Item
	_item = item.get_item_resource()
	item_slot.texture = _item.icon
	item_equipped.emit(_item)
