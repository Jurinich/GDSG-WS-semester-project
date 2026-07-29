extends Resource

class_name ItemData

enum ItemCategory {
	PADDLE_MOD, BALL_MOD, OTHER
}

const CATEGORY_NAMES: Dictionary = {
	ItemCategory.PADDLE_MOD: "Fish Food",
	ItemCategory.BALL_MOD: "Ball Modifier",
	ItemCategory.OTHER: "Other"
}

@export var name: String
@export var category: ItemCategory
@export var sprite: Texture2D
@export var power_up_effect: String
@export var is_paddle_powerup: bool = false
