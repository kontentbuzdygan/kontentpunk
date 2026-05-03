extends TextureRect

@onready var head: ItemHolder = $Head
@onready var heart: ItemHolder = $Heart
@onready var left_arm: ItemHolder = $LArm
@onready var right_arm: ItemHolder = $RArm
@onready var spine: ItemHolder = $Spine
@onready var left_leg: ItemHolder = $LLeg
@onready var right_leg: ItemHolder = $RLeg

func _ready() -> void:
	for item in PlayerState.get_items():
		## TODO: assigning an item to item holder will add the same item to the player state,
		## so remove it now, and it will be added again
		PlayerState.remove_item(item)
		## TODO: left and right holders will sometimes swap items
		match item.type:
			Item.Type.HEAD when head.item == null:
				head.item = item
			Item.Type.HEART when heart.item == null:
				heart.item = item
			Item.Type.ARM when left_arm.item == null:
				left_arm.item = item
			Item.Type.ARM when right_arm.item == null:
				right_arm.item = item
			Item.Type.SPINE when spine.item == null:
				spine.item = item
			Item.Type.LEG when left_leg == null:
				left_leg.item = item
			Item.Type.LEG when right_leg == null:
				right_leg.item = item
			_:
				assert(false, "invalid item")
