extends Node2D

##################################################
const POINT_SCENE: PackedScene = \
	preload("res://scenes/slime/slime_point/slime_point.tscn")
const EYE_TEXTURE: Texture = preload("res://sprites/googly-d.png")
const POINT_COUNT: int = 32
const RADIUS: float = 120.0
const SPRING_CONSTANT = 50.0
const DAMPING = 0.95
const MOVING_SPEED: float = 5000.0
# 슬라임의 물리적 특성과 구조를 정의하는 상수들

var polygon_node: Polygon2D
var collision_polygon_node: CollisionPolygon2D
var line_node: Line2D
var core_point: RigidBody2D
var outside_points: Array = []
var springs: Array = []
var eyes: Array = []
# 슬라임의 그래픽 및 물리 노드들


##################################################
func _ready():
	polygon_node = $Polygon2D
	collision_polygon_node = $Polygon2D/CollisionPolygon2D
	line_node = $Line2D
	# 노드 참조 가져오기
	
	init_points()
	connect_points()
	init_eyes()
	# 슬라임 점 및 눈 초기화

##################################################
func _physics_process(delta: float) -> void:
	update_springs()
	update_polygon()
	update_eyes()
	# 스프링 물리 연산 및 시각적 업데이트
	
	var input_force = Vector2()
	if Input.is_action_pressed("ui_left"):
		input_force.x -= 1
	if Input.is_action_pressed("ui_right"):
		input_force.x += 1
	
	if input_force.length() > 0:
		input_force = input_force.normalized() * MOVING_SPEED
		core_point.apply_central_force(input_force)
	# 플레이어 입력 감지 및 이동 처리
	# 나머지는 물리 연산에 의해 따라오므로 중심 리지드바디만 이동 시킴

##################################################
func init_points():
	var core_point_instance = POINT_SCENE.instantiate()
	add_child(core_point_instance)
	core_point = core_point_instance
	# 슬라임 중심점 생성 및 추가
	
	for i in range(POINT_COUNT):
		var outside_point = POINT_SCENE.instantiate()
		var point_angle = TAU / POINT_COUNT * i
		var point_position = \
			Vector2(cos(point_angle), sin(point_angle)) * RADIUS
		outside_point.position = point_position
		add_child(outside_point)
		outside_points.append(outside_point)
	# 슬라임 외곽 점 생성 및 배치

##################################################
func connect_points() -> void:
	for i in range(POINT_COUNT):
		var current_point = outside_points[i]
		var next_point = outside_points[(i + 1) % POINT_COUNT]
		var distance = current_point.position.distance_to(next_point.position)
		springs.append({\
				"start": current_point, \
				"end": next_point, \
				"distance": distance})
	# 외곽 점들을 연결하여 스프링 시스템 구성
		
		var second_point = outside_points[(i + 2) % POINT_COUNT]
		var second_distance = current_point.position.distance_to(second_point.position)
		springs.append({\
			"start": current_point, \
			"end": second_point, \
			"distance": second_distance})
		
		var third_point = outside_points[(i + 3) % POINT_COUNT]
		var third_distance = current_point.position.distance_to(third_point.position)
		springs.append({\
			"start": current_point, \
			"end": third_point, \
			"distance": third_distance})
		
		var forth_point = outside_points[(i + 4) % POINT_COUNT]
		var forth_distance = current_point.position.distance_to(forth_point.position)
		springs.append({\
			"start": current_point, \
			"end": forth_point, \
			"distance": forth_distance})
		# 추가 연결 (2~4번째 점까지 연결하여 탄성을 부드럽게 만듦)

		
	for point in outside_points:
		springs.append({\
			"start": core_point, \
			"end": point, \
			"distance": RADIUS})
	# 중심점과 외곽 점들을 연결하는 스프링 추가

##################################################
func init_eyes() -> void:
	var left_eye_instance = Sprite2D.new()
	left_eye_instance.texture = EYE_TEXTURE
	add_child(left_eye_instance)
	eyes.append(left_eye_instance)
	# 왼쪽 눈 생성 및 추가
	
	var right_eye_instance = Sprite2D.new()
	right_eye_instance.texture = EYE_TEXTURE
	add_child(right_eye_instance)
	eyes.append(right_eye_instance)
	# 오른쪽 눈 생성 및 추가

##################################################
func update_springs() -> void:
	for spring in springs:
		var start_point: RigidBody2D = spring["start"]
		var end_point: RigidBody2D = spring["end"]
		var distance = spring["distance"]
		
		var distance_offset = \
			start_point.position.distance_to(end_point.position) - distance
		
		var force_magnitude = -SPRING_CONSTANT * distance_offset
		var direction = \
			(end_point.position - start_point.position).normalized()
		var force = force_magnitude * direction
	# 각 스프링을 따라 힘을 적용하여 물리적 탄성 구현
		
		start_point.linear_velocity *= DAMPING
		end_point.linear_velocity *= DAMPING
		# 감쇠 계수 적용 (진동을 점진적으로 줄임)
		
		start_point.apply_central_force(-force)
		end_point.apply_central_force(force)
		# 힘 적용

##################################################
func update_polygon() -> void:
	var points: PackedVector2Array = PackedVector2Array()
	for i in range(POINT_COUNT):
		points.append(outside_points[i].position)
	# 외곽 점을 기반으로 다각형 업데이트
	
	polygon_node.polygon = points
	collision_polygon_node.polygon = points
	# Polygon2D 및 CollisionPolygon2D 업데이트
	
	points.append(outside_points.front().position)
	line_node.points = points
	line_node.default_color = Color(0, 0.25, 1, 0.75)
	# Line2D를 사용하여 외곽선 그리기
	
	polygon_node.color = Color(0, 1, 0.25, 0.75)
	# 슬라임 색상 설정

##################################################
func update_eyes() -> void:
	eyes[0].position = core_point.position - Vector2(75, 10)
	eyes[1].position = core_point.position - Vector2(5, 10)
	# 눈의 위치를 중심점 기준으로 조정
