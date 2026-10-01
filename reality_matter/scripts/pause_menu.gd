extends Control

@onready var resume_button: Button = %ResumeButton
@onready var exit_button: Button = %ExitButton

func get_resume_button() -> Button:
	return resume_button

func get_exit_button() -> Button:
	return exit_button
