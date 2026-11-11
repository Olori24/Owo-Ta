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
	var playable_world := load("res://scenes/world/first_district.tscn") as PackedScene
	_assert(playable_world != null, "Playable first district scene loads")
	if playable_world != null:
		var world := playable_world.instantiate()
		root.add_child(world)
		await process_frame
		_assert(world.get_node_or_null("Player") is CharacterBody3D, "Playable first district retains its selected-character player")
		_assert(world.get_node_or_null("StreetRoadSurface") is MeshInstance3D, "Playable first district contains the detailed road surface")
		_assert(world.get_node_or_null("StreetLaneDash01") is MeshInstance3D, "Playable first district contains road lane markings")
		_assert(world.get_node_or_null("LeftPavement") is MeshInstance3D and world.get_node_or_null("RightPavement") is MeshInstance3D, "Playable first district contains both pavements")
		_assert(world.get_node_or_null("IkejaStorefront") != null, "Playable first district contains the Ikeja storefront")
		_assert(world.get_node_or_null("IkejaBusStop") != null, "Playable first district contains the bus stop")
		_assert(world.get_node_or_null("PharmacySign") is Label3D, "Playable first district includes the pharmacy frontage and sign")
		_assert(world.get_node_or_null("MamaTKitchenFrontage/Sign") is Label3D, "Playable first district includes a named food storefront")
		_assert(world.get_node_or_null("AdeTailoringFrontage/Sign") is Label3D, "Playable first district includes a second named business frontage")
		_assert(world.get_node_or_null("SnackKioskCounter") is MeshInstance3D and world.get_node_or_null("SnackKioskSign") is Label3D, "Playable first district includes a roadside kiosk")
		_assert(world.get_node_or_null("SecondStreetLamp") != null, "Playable first district includes a second street lamp")
		world.queue_free()
		await process_frame
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
