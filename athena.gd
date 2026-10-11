extends CharacterBody2D

@export var toc_do: float = 300.0
var dang_choi: bool = false

func _ready() -> void:
	var kich_thuoc: Vector2 = $Sprite2D.texture.get_size()
	$Sprite2D.scale = Vector2.ONE * (46.0 / maxf(kich_thuoc.x, kich_thuoc.y))

func _physics_process(_delta: float) -> void:
	if not dang_choi:
		velocity = Vector2.ZERO
		return
	var huong := Input.get_vector("di_trai", "di_phai", "di_len", "di_xuong")
	var he_so := 2.0 if Input.is_action_pressed("chay") else 1.0
	velocity = huong * toc_do * he_so
	move_and_slide()
	var kich_thuoc := get_viewport_rect().size
	position = position.clamp(Vector2(23, 46), kich_thuoc - Vector2(23, 23))

func phan_hoi() -> void:
	$AnimationPlayer.stop()
	$AnimationPlayer.play("nhat")

func dat_lai() -> void:
	position = Vector2(320, 300)
	velocity = Vector2.ZERO
	$AnimationPlayer.stop()
	$Sprite2D.modulate = Color.WHITE
