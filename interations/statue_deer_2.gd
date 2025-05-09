extends StaticBody2D

@onready var interaction_area: InteractionArea = $InteractionArea

const lines: Array[String] = [
	"Welcome, brave mage. These lands suffer under the tyranny of the Crystal King.",
	"Your destiny is to break his reign, and restore the true throne of the kingdom.",
	"Your journey begins here, to uncover lost secrets and liberate these lands."
]

func _ready():
	interaction_area.interact = Callable(self, "_on_interact")
	

func _on_interact():
	DialogueManager.start_dialog(global_position, lines)
	await DialogueManager.dialog_finished
