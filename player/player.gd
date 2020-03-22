extends KinematicBody2D

const SPEED=30
var GRAVITY=3
const JUMP_POWER=-75
const FLOOR=Vector2(0,-1)

var vel=Vector2()

var stance="Right"

var onGround=false
var onLadder=false
var hitting=false
var canHit=false

onready var sprite=$AnimatedSprite
onready var collisionBox=$CollisionShape2D

func _physics_process(_delta):
	if not hitting and not onLadder: movement_loop()
	if onLadder: ladder_loop()
	if is_on_floor():
		canHit=true
		onGround=true
	else: if not hitting:
		animate("air")
		onGround=false
	
	vel=move_and_slide(vel, FLOOR)

func ladder_loop():
	var left=Input.is_action_pressed("ui_left")
	var right=Input.is_action_pressed("ui_right")
	var up=Input.is_action_pressed("ui_up")
	var down=Input.is_action_pressed("ui_down")
	var jump=Input.is_action_just_pressed("z")
	var hit=Input.is_action_just_pressed("x")
	
	GRAVITY=0
	if up and not down: vel.y=-SPEED/2
	elif down and not up: vel.y=SPEED/2
	elif right and not left: vel.x=SPEED/2
	elif left and not right: vel.x=-SPEED/2

func movement_loop():
	var left=Input.is_action_pressed("ui_left")
	var right=Input.is_action_pressed("ui_right")
	var up=Input.is_action_pressed("ui_up")
	var down=Input.is_action_pressed("ui_down")
	var jump=Input.is_action_just_pressed("z")
	var hit=Input.is_action_just_pressed("x")
	
	if stance=="Right":
		collisionBox.position.x=-0.5
		sprite.flip_h=false
	elif stance=="Left":
		collisionBox.position.x=0.5
		sprite.flip_h=true
	
	if right and not left:
		stance="Right"
		vel.x=SPEED
		animate("walk")
	elif left and not right:
		stance="Left"
		vel.x=-SPEED
		animate("walk")
	elif up:
		vel.x=0
		animate("up")
		if hit and canHit: hit("hitUp", stance)
	elif down:
		vel.x=0
		animate("down")
		if hit and canHit: hit("hitDown", stance)
	else:
		vel.x=0
		if onGround: animate("idle")
	
	if jump and onGround:
		vel.y+=JUMP_POWER
		onGround=false
	if hit and canHit:
		hit("hitSide", stance)
	vel.y+=GRAVITY

func animate(animation):
	sprite.play(animation)

func hit(_mode, _stance):
	vel=Vector2(0,0)
	canHit=false
	hitting=true
	var anim=str(_mode)+str(_stance)
	$AnimationPlayer.play(anim)

func _on_AnimationPlayer_animation_finished(_anim_name):
	hitting=false

func _on_pickaxeArea_body_entered(body):
	if body.name=="TileMap":
		var offSet=Vector2()
		var animName=$AnimationPlayer.get_current_animation()
		if "Up" in animName: offSet=Vector2(0,-1)
		elif "Down" in animName: offSet=Vector2(0,1)
		elif "SideRight" in animName: offSet=Vector2(1,0)
		elif "SideLeft" in animName: offSet=Vector2(-1,0)
		var tilePos=(body.world_to_map(position)+offSet)
		var _tile=body.get_cellv(tilePos)
		body.set_cellv(tilePos, 2)
