extends SceneTree

const SCENE_PATH := "res://scenes/benchmarks/ikeja_street_corner.tscn"

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed := load(SCENE_PATH) as PackedScene
	_assert(packed != null, "Street-corner benchmark scene loads")
	if packed == null:
		quit(1)
		return
	var scene := packed.instantiate()
	_assert(scene != null, "Street-corner benchmark scene instantiates")
	if scene == null:
		quit(1)
		return
	root.add_child(scene)
	await process_frame
	_assert(scene.is_in_group("benchmark_scene"), "Benchmark is isolated and tagged")
	_assert(scene.get_node_or_null("Player") is CharacterBody3D, "Existing CharacterBody3D player controller is present")
	_assert(scene.get_node_or_null("Player/CollisionShape3D") is CollisionShape3D, "Player collision contract is preserved")
	_assert(scene.get_node_or_null("Ground/Collision") is CollisionShape3D, "Walkable ground has collision")
	_assert(scene.get_node_or_null("Storefront/StoreCollision/CollisionShape3D") is CollisionShape3D, "Storefront collision exists")
	_assert(scene.get_node_or_null("StoryPoint") is Area3D, "Story point interaction volume exists")
	_assert(scene.get_node_or_null("BusStop") != null, "Street-life bus stop landmark exists")
	_assert(scene.get_node_or_null("StreetLamp") != null, "Street lighting prop exists")
	_assert(scene.get_node_or_null("MobileControls/TouchOverlay") != null, "Existing mobile touch controls are present")
	scene.queue_free()
	await process_frame
	print("IKEJA_STREET_CORNER_BENCHMARK: " + ("PASS" if failures.is_empty() else "FAIL"))
	quit(0 if failures.is_empty() else 1)

var failures: Array[String] = []

func _assert(condition: bool, message: String) -> void:
	if condition:
		print("PASS: " + message)
	else:
		failures.append(message)
		push_error("FAIL: " + message)
