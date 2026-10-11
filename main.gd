extends Node2D

enum TrangThai { SAN_SANG, CHOI, KET_THUC }
const MAU_SAO = preload("res://ngoi_sao.tscn")
const MAU_BONG = preload("res://bong_toi.tscn")
const LUU = "user://athena-ky-luc.cfg"

var trang_thai: TrangThai = TrangThai.SAN_SANG
var diem: int = 0
var con_lai: int = 30
var ky_luc: int = 0

@onready var athena = $Athena
@onready var diem_label: Label = $HUD/GiaoDien/Le/ThongSo/Diem
@onready var gio_label: Label = $HUD/GiaoDien/Le/ThongSo/ThoiGian
@onready var ky_luc_label: Label = $HUD/GiaoDien/Le/ThongSo/KyLuc
@onready var menu: CenterContainer = $HUD/GiaoDien/Menu
@onready var tieu_de: Label = $HUD/GiaoDien/Menu/Cot/TieuDe
@onready var nut_choi: Button = $HUD/GiaoDien/Menu/Cot/Choi

func _ready() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(LUU) == OK:
		ky_luc = int(cfg.get_value("diem", "ky_luc", 0))
	$SinhSao.timeout.connect(_sinh_sao)
	$SinhBong.timeout.connect(_sinh_bong)
	$DongHo.timeout.connect(_dem_gio)
	nut_choi.pressed.connect(bat_dau)
	nut_choi.grab_focus()
	cap_nhat_hud()

func bat_dau() -> void:
	# Clear the previous round before enabling input and timers again.
	for vat in $VatThe.get_children():
		$VatThe.remove_child(vat)
		vat.queue_free()
	diem = 0
	con_lai = 30
	trang_thai = TrangThai.CHOI
	athena.dat_lai()
	athena.dang_choi = true
	menu.hide()
	cap_nhat_hud()
	$SinhSao.start()
	$SinhBong.start()
	$DongHo.start()

func _tao_vat(mau: PackedScene) -> void:
	if trang_thai != TrangThai.CHOI:
		return
	var vat = mau.instantiate()
	# Configure local state before add_child triggers _ready.
	vat.position = Vector2(randf_range(24, 616), -24)
	vat.toc_do = randf_range(100, 210)
	vat.toc_do_quay = randf_range(-2, 2)
	vat.nhat_duoc.connect(_nhat_sao)
	vat.trung_bong_toi.connect(ket_thuc.bind("Chạm bóng tối"))
	$VatThe.add_child(vat)

func _sinh_sao() -> void:
	_tao_vat(MAU_SAO)

func _sinh_bong() -> void:
	_tao_vat(MAU_BONG)

func _nhat_sao(gia_tri: int) -> void:
	if trang_thai != TrangThai.CHOI:
		return
	diem += gia_tri
	athena.phan_hoi()
	$AmNhat.pitch_scale = randf_range(0.95, 1.05)
	$AmNhat.play()
	cap_nhat_hud()

func _dem_gio() -> void:
	if trang_thai != TrangThai.CHOI:
		return
	con_lai -= 1
	cap_nhat_hud()
	if con_lai <= 0:
		ket_thuc("Hết giờ")

func ket_thuc(ly_do: String) -> void:
	if trang_thai != TrangThai.CHOI:
		return
	trang_thai = TrangThai.KET_THUC
	athena.dang_choi = false
	$SinhSao.stop()
	$SinhBong.stop()
	$DongHo.stop()
	for vat in $VatThe.get_children():
		vat.set_physics_process(false)
		vat.set_deferred("monitoring", false)
	if diem > ky_luc:
		ky_luc = diem
		var cfg := ConfigFile.new()
		cfg.set_value("diem", "ky_luc", ky_luc)
		var loi := cfg.save(LUU)
		if loi != OK:
			push_warning("Không lưu được kỷ lục: %s" % loi)
	cap_nhat_hud()
	tieu_de.text = "%s · %d điểm" % [ly_do, diem]
	nut_choi.text = "Chơi lại"
	menu.show()
	nut_choi.grab_focus()

func cap_nhat_hud() -> void:
	diem_label.text = "Điểm: %d" % diem
	gio_label.text = "Còn: %ds" % con_lai
	ky_luc_label.text = "Kỷ lục: %d" % ky_luc
