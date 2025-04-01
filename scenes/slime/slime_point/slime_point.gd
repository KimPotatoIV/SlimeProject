extends RigidBody2D

##################################################
var collision_node: CollisionShape2D
# 충돌 감지를 위한 CollisionShape2D 노드를 저장할 변수

##################################################
func _ready() -> void:
	collision_node = $CollisionShape2D
	# 현재 노드의 자식 노드인 CollisionShape2D를 가져와 변수에 저장
	var circle_chape = CircleShape2D.new()
	# 원형 충돌 모양(CircleShape2D)을 생성
	circle_chape.radius = 0.5
	 # 원의 반지름을 0.5로 설정
	collision_node.shape = circle_chape
	# CollisionShape2D 노드의 충돌 모양을 새로 생성한 원형으로 설정
	
	mass = 0.1
	# 질량을 0.1로 설정하여 가볍게 만듦
	gravity_scale = 5.0
	# 중력 스케일을 5.0으로 설정하여 중력의 영향을 5배로 증가
	continuous_cd = RigidBody2D.CCD_MODE_CAST_RAY
	# 연속 충돌 감지 모드를 활성화
	# 작은 오브젝트가 빠르게 움직일 때 충돌을 놓치는 문제를 줄임
