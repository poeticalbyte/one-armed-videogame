#BINVENIDOS A MI HUMILDE CODIGO AJAJA.

extends CharacterBody2D



const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@onready var animetionPlayer=$AnimationPlayer#  A una variable le asigno la clase animacion.
@onready var sprite2D=$Sprite2D
var atacar:bool = false # Desde proyecto, configuracion, mapa se puede asignar a una variable una tacla. en este caso click izq.
var counter_enemi:int = 0 #Los golper que da el player al enemigo.

var counter_player:int=0 # Solo para que no de error, creo que hay que traerlo de la script del enemy

func ready():
	$Area2D/CollisionShape2D.disabled = true # desabilita el area de ataque al inicio, creo(no puedo ver el area)

func _physics_process(delta: float) -> void:
	if not atacar: # Si ataca no se puede mover
	# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta

	# Handle jump.
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
		var direction := Input.get_axis("ui_left", "ui_right")
		if direction:
			velocity.x = direction * SPEED
			$Area2D.position.x= 106 # Para que cambie el area de ataque, HAY QUE PROBARLO, NO SE SI FUNCIONE
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			$Area2D.position.x= 73 # Para que cambie el area de ataque, HAY QUE PROBARLO, NO SE SI FUNCIONE
		if Input.is_action_just_pressed("atacar"): #Al presionar click
			atacar = true
			$Area2D/CollisionShape2D.disabled = false # Habilita el area de ataque
		move_and_slide()
	
		if direction==1:
			sprite2D.flip_h= false
		elif direction==-1:
			sprite2D.flip_h = true
		animacion(direction)
	else:
		animetionPlayer.play("Attack")# Si no esta atacando, ataca :v
		await $AnimationPlayer.animation_finished #await con animation_finished espera a que la animacion se reproduzca para que sigan las otras lineas
		$Area2D/CollisionShape2D.disabled = true# deshabilita el area de ataque
		atacar=false
		
func animacion(direction):
	if is_on_floor():
		if direction==0: #Si el 0 no se mueve
			animetionPlayer.play("Idle")
		else: # Si no esta quieto es porque esta caminando.
			animetionPlayer.play("walk")

#ESTO LO HICE MIRANDO UN VIDEO Y INTENTANDOLO ADAPTAR A LO QUE QUEREMOS, NO SE SI JALE :v.
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemie"): #se debe poner en un grupo el enemigo para que asi no se borren objetos o el mapa
		counter_enemi = counter_enemi+1 # cuentas los golpes que le da al enemigo 
	if counter_enemi== 3:#Cuando se den 3 golpes se elimina al enemigo
		body.queue_free() # Se debe añadir una funcion como la de abajo en el enemigo, pues si funciona
		
func dead_player(): 
	if counter_player < 9: #Si es menor que 9 es porque aun no se muere, esto toca enlazar con lo de enemy
		animetionPlayer.play("hurt")
	if counter_player==9: # Si se quita toda la vida que:
		set_physics_process(false) # Deshabilita esta funcion, porque es un bucle, y cuando se muere debe dejar de moverse.
		#Es para quitar posibles bugs en la animacion.
		animetionPlayer.play("Death")# Se reproduce la animacion
		await (animetionPlayer.animation_finished)
		queue_free() # Creo que borra al player.
		
#NO TENGO EL ENEMIGO PARA PROBAR SI MI TEORIA CONSPIRATORIA ES VERDADERA, pero segun yo tiene logica jaja
		
		
		
		
		
		
