class_name DialogueUI
extends Control

# Signal to emit when the dialogue is finished
signal dialogue_finished

# UI Node References
@onready var balloon: MarginContainer = $Balloon
@onready var text_label: Label = $Balloon/TextContainer/Text
@onready var typewriter_timer: Timer = $Balloon/BalloonImage/TypewriterTimer
@onready var advance_timer: Timer = $Balloon/BalloonImage/AdvanceTimer

# --- Dialogue State ---
var dialogue_queue: Array[String] = []
var is_displaying: bool = false # Tracks if the system is busy showing any dialogue
var is_typing: bool = false

# --- EXPORT VARIABLES ---
@export var typing_delay: float = 3.0
# This is the new variable for the delay between lines
@export var time_between_lines: float = 1.5 # In seconds

func _ready() -> void:
	# Hide balloon at the start
	balloon.hide()

	# Configure the typewriter timer (for characters)
	typewriter_timer.wait_time = typing_delay / 100
	typewriter_timer.one_shot = false
	typewriter_timer.connect("timeout", _on_typewriter_timer_timeout)

	# Configure the advance timer (for lines)
	advance_timer.wait_time = time_between_lines
	advance_timer.one_shot = true # We only want it to fire once per line
	advance_timer.connect("timeout", _show_next_dialogue_in_queue)


# --- PUBLIC API ---
# Call this function from other scripts to add a line of dialogue.
func push_dialogue(line: String, push_in_front : bool = false) -> void:

	if dialogue_queue.size() >= 2:
		return

	if push_in_front:
		dialogue_queue.push_front(line)
	else:
		dialogue_queue.append(line)
	
	# If the system isn't already running, kick it off.
	if not is_displaying:
		is_displaying = true
		_show_next_dialogue_in_queue()


# --- INTERNAL LOGIC ---
func _show_next_dialogue_in_queue() -> void:
	# If there's nothing left to show, end the dialogue.
	if dialogue_queue.is_empty():
		end_dialogue()
		return

	# Show the balloon if it's hidden
	if !balloon.visible:
		balloon.show()

	# Get the next line from the front of the queue
	var next_line = dialogue_queue.pop_front()
	text_label.text = next_line
	text_label.visible_characters = 0

	# Start the typewriter effect
	is_typing = true
	typewriter_timer.start()


func _on_typewriter_timer_timeout() -> void:
	if text_label.visible_characters < len(text_label.text):
		text_label.visible_characters += 1
	else:
		# Finished typing this line
		is_typing = false
		typewriter_timer.stop()
		# Now, start the timer to wait before showing the next line
		advance_timer.start()


func end_dialogue() -> void:
	is_displaying = false
	balloon.hide()
	emit_signal("dialogue_finished")


# We can keep a simplified input handler to let the player skip the typing effect
func _unhandled_input(event: InputEvent) -> void:
	if not is_displaying or not event.is_action_pressed("ui_accept"):
		return

	if is_typing:
		# If we're typing, skip to the end of the line instantly
		typewriter_timer.stop()
		text_label.visible_characters = len(text_label.text)
		is_typing = false
		# And immediately start the timer for the next line
		advance_timer.start()
