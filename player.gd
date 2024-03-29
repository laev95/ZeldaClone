extends CharacterBody2D

var speed = 100 # Movement speed of the player
var last_direction = Vector2.RIGHT # Default direction the player is facing (right)
var animated_sprite # Reference to the animated sprite node
var enemy_in_range = false # Flag to track if an enemy is within range
var health = 100
var last_health = 100
var is_dead = false # Flag to track if the player is dead
var is_attacking = false
var attack_timer = 0.0
var attack_duration = 0.33 # Time in seconds
var healthbar: ProgressBar

func _ready():
	animated_sprite = $AnimatedSprite2D # Reference to the AnimatedSprite2D node
	healthbar = $healthbar
	healthbar.visible = false
	add_to_group("Player") 
	
func _physics_process(delta):
	update_animation()
	move_and_slide()
	
	if is_attacking:
		attack_timer += delta
		if attack_timer >= attack_duration:
			is_attacking = false
			attack_timer = 0.0
	
	if last_health > health:
		update_health()
		last_health = health

func _input(event):
	if event.is_action_pressed("ui_select"): # Assuming "ui_select" is mapped to the space bar
		is_attacking = true
		attack_timer = 0.0

func update_health():
	healthbar.value = health
	healthbar.visible = true
	die()

func die():
	if health <= 0 and not is_dead:
		is_dead = true
		get_tree().call_deferred("change_scene_to_file","res://gameover.tscn")

func update_animation():
	if is_dead:
		return
	
	if is_attacking:
		if last_direction.y < 0:
			animated_sprite.play("attack_up")
		elif last_direction.y > 0:
			animated_sprite.play("attack_down")
		elif last_direction.x != 0:
			animated_sprite.play("attack_right")
		return
		
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * speed
	
	# Update the last direction if the player is moving
	if direction != Vector2.ZERO:
		last_direction = direction.normalized()
		
	# Animation handling based on movement direction
	if direction.x != 0:
		animated_sprite.play("walk_right") # Play walking right animation
	elif direction.y < 0:
		animated_sprite.play("walk_up") # Play walking up animation
	elif direction.y > 0:
		animated_sprite.play("walk_down") # Play walking down animation
	elif direction == Vector2.ZERO:
		# Play idle animations based on the last direction the player was facing
		if last_direction.x != 0:
			animated_sprite.play("idle_right")
		elif last_direction.y < 0:
			animated_sprite.play("idle_up")
		elif last_direction.y > 0:
			animated_sprite.play("idle_down")

	animated_sprite.flip_h = last_direction.x < 0

func _on_hitbox_body_entered(body):
	if body.is_in_group("Enemy"):
		enemy_in_range = true # Set enemy detection flag to true
		
func _on_hitbox_body_exited(body):
	if body.is_in_group("Enemy"):
		enemy_in_range = false # Set enemy detection flag to false
