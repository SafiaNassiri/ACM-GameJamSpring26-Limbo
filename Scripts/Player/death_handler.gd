extends Node
class_name DeathHandler

# Handles player death logic.
#
# Responsibilities:
#   - Play the dying animation when the player dies.
#   - Disable other player systems (movement, interaction, etc.) during death.
#   - Show a death UI / screen with optional flavour text.
#   - Reload or transition the scene after a delay.
#
# Usage:
#   Add as a child of the player CharacterBody2D node.
#   Call die() from any script that can deal lethal damage to the player
#   (e.g. enemy contact, hazard areas, health reaching zero).
#
# Dependencies to set up:
#   - AnimatedSprite2D on the parent with a "dying" animation.
#   - A death UI Control node somewhere in the scene tree.
#   - Any lore / flavour text array you want displayed on death.
