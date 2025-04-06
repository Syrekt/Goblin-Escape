extends EnemyState

func enter(previous_state_path: String, data := {}) -> void:
	enemy.visible = false

func exit() -> void:
	enemy.visible = true;

func update(delta: float) -> void:
	Debugger.printui("Enemy visible: "+str(enemy.visible))
