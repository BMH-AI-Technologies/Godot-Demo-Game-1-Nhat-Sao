extends Area2D

signal nhat_duoc(diem: int)
signal trung_bong_toi

@export var toc_do: float = 150.0
@export var diem: int = 1
@export var nguy_hiem: bool = false
@export var toc_do_quay: float = 1.0
var da_xu_ly: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	position.y += toc_do * delta
	$Hinh.rotation += toc_do_quay * delta
	if position.y > get_viewport_rect().size.y + 30:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if da_xu_ly or not body.is_in_group("nguoi_choi"):
		return
	da_xu_ly = true
	if nguy_hiem:
		trung_bong_toi.emit()
	else:
		nhat_duoc.emit(diem)
	queue_free()
