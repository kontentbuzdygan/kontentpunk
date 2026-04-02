class_name Utils


class OrthoTilesIterator:
	var current: Vector2i
	var end: Vector2i

	func _init(start: Vector2i, end_: Vector2i) -> void:
		assert(current.x == end.x || current.y == end.y, "not ortholinear")

		current = start
		end = end_

		next()

	func has_next() -> bool:
		return current != end

	func next() -> void:
		current += Vector2i(
			sign(end.x - current.x),
			sign(end.y - current.y),
		)

	func _iter_init(iter: Array) -> bool:
		iter[0] = current
		return true

	func _iter_next(iter: Array) -> bool:
		next()
		iter[0] = current
		return has_next()

	func _iter_get(_iter: Variant) -> Vector2i:
		return current


static func manhattan_length(v: Vector2i) -> int:
	return abs(v.x) + abs(v.y)


## Returns the length of an ortholinear vector along either axis, or `-1` if the
## given vector is not ortholinear
static func ortho_length(v: Vector2i) -> int:
	if v.x == 0:
		return abs(v.y)
	elif v.y == 0:
		return abs(v.x)
	else:
		return -1


## Returns an iterator that yields each tile in a straight line from `start` to
## `end`, where both `start` and `end` are exclusive
static func walk_ortho_tiles(start: Vector2i, end: Vector2i) -> OrthoTilesIterator:
	return OrthoTilesIterator.new(start, end)
