extends Node2D

##################################################
const SLIME_SCENE: PackedScene = preload("res://scenes/slime/slime.tscn")
# 슬라임을 생성할 때 사용할 씬을 미리 로드
const SCREEN_SIZE: Vector2 = Vector2(1920.0, 1080.0)
# 게임 화면의 크기를 정의하는 상수

##################################################
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_left_mouse"):
	# 사용자가 왼쪽 마우스 버튼을 눌렀을 때
		var slime_instance = SLIME_SCENE.instantiate()
		# 미리 로드된 SLIME_SCENE을 인스턴스화하여 새로운 슬라임 객체를 생성
		slime_instance.position = get_global_mouse_position()
		# 생성된 슬라임의 위치를 현재 마우스 커서 위치로 설정
		add_child(slime_instance)
		# 생성된 슬라임 객체를 현재 노드의 자식으로 추가
