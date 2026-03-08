class_name Utils


static func manhattan_distance(a: Vector2i, b: Vector2i) -> int:
	return abs(a.x - b.x) + abs(a.y - b.y)



static func is_valid_axis_aligned_move(a: Vector2i, b: Vector2i) -> int:
	return a.x == b.x and a.y != b.y or a.x != b.x and a.y == b.y
