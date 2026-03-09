class_name ItemHolder
extends CenterContainer

@export var item_type: ItemResource.ITEM_TYPE
@onready var item_slot: TextureRect = $ItemSlot
signal item_equipped(item: ItemResource)

var _item: ItemResource


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data.is_class("ItemResource") and (data as ItemResource).item_type == item_type


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var item = data as ItemResource
	_item = item
	item_slot.texture = item.icon
	item_equipped.emit(_item)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
