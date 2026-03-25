extends Area2D

# Handles player interactions with interactable objects in the world.
#
# Responsibilities:
#   - Detect when the player enters or exits an interactable's trigger area.
#   - Display a contextual prompt (e.g. "Press E to interact") near the object.
#   - Fire the interaction when the player presses the interact input action.
#   - Hide the prompt when the player moves away.
#
# Usage:
#   Add as a child of the player CharacterBody2D node.
#   Interactable objects in the scene should belong to an "interactable" group
#   and expose an interact() method that this script can call.
#
# Dependencies to set up:
#   - An input action named "player_interact" in the Input Map.
#   - Interactable scene nodes added to the "interactable" group.
#   - A UI prompt node (Label or custom Control) for the interaction hint.
