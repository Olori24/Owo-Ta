extends SceneTree

const CHARACTER_IDS := ["kemi_adebayo", "tunde_balogun", "amara_okonkwo"]
const VIEW_NAMES := [
	"front_idle", "threequarter_idle", "side_idle", "rear_idle", "gameplay_idle",
	"face_closeup", "front_walk", "front_run", "front_jump", "front_landing"
]
const BACKGROUND := Color(0.055, 0.07, 0.085, 1.0)

var failures: Array[String] = []
var output_dir := ""

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	output_dir = OS.get_environment("OWO_CHARACTER_BENCHMARK_OUTPUT")
	if output_dir.is_empty():
		output_dir = "build/verification/character-roster"
	for character_id in CHARACTER_IDS:
		_compose_contact_sheet(character_id)
	if failures.is_empty():
		print("CONTACT_SHEET_BUILDER: PASS — all three sheets contain rendered image data.")
	else:
		for failure in failures:
			push_error("CONTACT_SHEET_BUILDER: " + failure)
		print("CONTACT_SHEET_BUILDER: FAIL — " + str(failures.size()) + " check(s) failed.")
	quit(0 if failures.is_empty() else 1)

func _compose_contact_sheet(character_id: String) -> void:
	var sheet := Image.create(1600, 360, false, Image.FORMAT_RGB8)
	sheet.fill(BACKGROUND)
	for index in range(VIEW_NAMES.size()):
		var image_path := output_dir.path_join(character_id + "-" + VIEW_NAMES[index] + ".png")
		var thumbnail := Image.load_from_file(image_path)
		_check(thumbnail != null and not thumbnail.is_empty(), "Source render exists: " + image_path)
		if thumbnail == null or thumbnail.is_empty():
			continue
		thumbnail.convert(Image.FORMAT_RGB8)
		thumbnail.resize(320, 180, Image.INTERPOLATE_LANCZOS)
		var destination := Vector2i((index % 5) * 320, int(index / 5) * 180)
		sheet.blit_rect(thumbnail, Rect2i(Vector2i.ZERO, thumbnail.get_size()), destination)
		# If the engine blit leaves the destination unchanged, copy pixels directly.
		var samples := [Vector2i(120, 60), Vector2i(160, 90), Vector2i(200, 120), Vector2i(240, 80)]
		var mismatch_count := 0
		for sample in samples:
			if sheet.get_pixel(destination.x + sample.x, destination.y + sample.y) != thumbnail.get_pixel(sample.x, sample.y):
				mismatch_count += 1
		if mismatch_count > 0:
			for y in range(180):
				for x in range(320):
					sheet.set_pixel(destination.x + x, destination.y + y, thumbnail.get_pixel(x, y))
	var sheet_path := output_dir.path_join(character_id + "-contact-sheet.png")
	_check(sheet.save_png(sheet_path) == OK, "Contact sheet saved: " + character_id)
	var sampled_colors: Dictionary = {}
	for y in range(0, 360, 12):
		for x in range(0, 1600, 12):
			var pixel := sheet.get_pixel(x, y)
			var key := "%d,%d,%d" % [int(pixel.r * 255.0), int(pixel.g * 255.0), int(pixel.b * 255.0)]
			sampled_colors[key] = true
	_check(sampled_colors.size() > 10, "Contact sheet contains varied rendered pixels: " + character_id)
	print("CONTACT_SHEET: " + character_id + " sampled_colors=" + str(sampled_colors.size()))

func _check(condition: bool, description: String) -> void:
	if not condition:
		failures.append(description)
