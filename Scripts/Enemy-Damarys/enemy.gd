extends CharacterBody2D  # Clase base para personajes con física en 2D

# ------------------ CONSTANTES ------------------
const SPEED = 50        # Velocidad horizontal del enemigo
const GRAVITY = 900     # Fuerza de gravedad aplicada al enemigo

# ------------------ VARIABLES ------------------
var direction = -1      # Dirección inicial: -1 es izquierda, 1 sería derecha
var attacking = false   # Estado de ataque
var dead = false        # Estado de muerte
var life = 3            # Vida del enemigo

# ------------------ NODOS ------------------
@onready var attack_area = $Area2D               # Área de ataque que detecta al jugador
@onready var sprite = $AnimatedSprite2D          # Sprite animado del enemigo

# ------------------ INICIALIZACIÓN ------------------
func _ready():
	# Conecta la señal 'body_entered' del Area2D a la función _on_area_2d_body_entered
	attack_area.body_entered.connect(_on_area_2d_body_entered)
	# Inicia la animación de caminar
	sprite.play("walk")

# ------------------ MOVIMIENTO Y FÍSICA ------------------
func _physics_process(delta):
	if dead:
		return  # Si el enemigo está muerto, no hace nada

	# Aplicar gravedad si no está en el suelo
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Movimiento horizontal
	velocity.x = direction * SPEED

	# Voltear el sprite según la dirección
	sprite.flip_h = direction > 0

	# Mover el personaje considerando colisiones
	move_and_slide()

	# Cambiar dirección si choca con una pared
	if is_on_wall():
		direction *= -1

# ------------------ DETECCIÓN DEL JUGADOR ------------------
func _on_area_2d_body_entered(body):
	# Si el objeto que entra en el área es el jugador y no está atacando ni muerto, ataca
	if body.name == "Player" and not attacking and not dead:
		attack()

# ------------------ ATAQUE ------------------
func attack():
	attacking = true                 # Marcar que está atacando
	sprite.play("attack")            # Reproducir animación de ataque
	await sprite.animation_finished  # Esperar a que termine la animación
	attacking = false                # Termina el ataque
	sprite.play("walk")              # Volver a animación de caminar

# ------------------ RECIBIR DAÑO ------------------
func take_damage():
	if dead:
		return  # Si ya está muerto, no hacer nada

	# Reducimos la vida
	life -= 1
	attacking = false       # Interrumpir ataque si estaba atacando
	sprite.play("Hurt")     # Reproducir animación de daño

	if life <= 0:
		die()               # Si la vida llega a 0, morir
	else:
		await sprite.animation_finished  # Esperar a que termine animación de daño
		sprite.play("walk")             # Volver a caminar

# ------------------ MUERTE ------------------
func die():
	dead = true             # Marcar que está muerto
	velocity = Vector2.ZERO # Detener todo movimiento
	sprite.play("Death")    # Reproducir animación de muerte
	await sprite.animation_finished  # Esperar a que termine la animación
	queue_free()            # Eliminar el nodo del enemigo del juego
