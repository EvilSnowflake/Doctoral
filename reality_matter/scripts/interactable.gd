extends Area2D

#This script should be attached to any entity that need to interact with the
#player. It contains signals that the player can emit and which can be connected
#to items/npcs that should be notified when the user collides, leaves or
#interacts.


@warning_ignore("unused_signal")
## This signal should be called when the player pumps into the interactable
## entity while attepting to walk
signal player_collided
@warning_ignore("unused_signal")
## This signal should be called by the player when they try to move away from
## the entity
signal player_left
@warning_ignore("unused_signal")
## This signal should be called when the player starts to interact with this
signal interacted(player: CharacterBody2D)
