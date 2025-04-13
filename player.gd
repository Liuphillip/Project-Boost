extends RigidBody3D

## How much vertical force to apply when moving
@export_range(750.0,3000) var thrust: float = 1000.0
## How much torque to apply when moving
@export_range(100, 300) var torque: float = 100
# Audio
@onready var explosion_audio: AudioStreamPlayer = $ExplosionAudio
@onready var success_audio: AudioStreamPlayer = $SuccessAudio
@onready var thrust_audio: AudioStreamPlayer = $ThrustAudio
# Particles
@onready var booster_particles: GPUParticles3D = $BoosterParticles
@onready var right_booster_particles: GPUParticles3D = $RightBoosterParticles
@onready var left_booster_particles: GPUParticles3D = $LeftBoosterParticles
@onready var success_particles: GPUParticles3D = $SuccessParticles
@onready var explosion_particles: GPUParticles3D = $ExplosionParticles


var is_transitioning: bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("boost"):
		apply_central_force(basis.y * delta * thrust)
		booster_particles.emitting = true
		if thrust_audio.playing == false:
			thrust_audio.play()
	else:
		thrust_audio.stop()
		booster_particles.emitting = false
	if Input.is_action_pressed("right"):
		left_booster_particles.emitting = true
		apply_torque(Vector3(0.0, 0.0, -torque * delta))
	else:
		left_booster_particles.emitting = false
	if Input.is_action_pressed("left"):
		right_booster_particles.emitting = true
		apply_torque(Vector3(0.0, 0.0, torque * delta))
	else:
		right_booster_particles.emitting = false
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()

# THIS FUNCTION GETS CALLED WHEN a collision happens
func _on_body_entered(body: Node) -> void:
	if is_transitioning == false:
		if "Goal" in body.get_groups():
			print("You Win")
			complete_level(body.file_path)
		if "Floor" in body.get_groups():
			crash_sequence()

func crash_sequence() -> void:
	print("FUK")
	explosion_audio.play()
	explosion_particles.emitting = true
	set_process(false)
	is_transitioning = true
	var tween = create_tween()
	tween.tween_interval(2.5)
	tween.tween_callback(get_tree().reload_current_scene)
	
	
func complete_level(next_level_file: String) -> void:
	print("Level Complete")
	success_audio.play()
	success_particles.emitting = true
	set_process(false)
	is_transitioning = true
	var tween = create_tween()
	tween.tween_interval(2.5)
	tween.tween_callback(get_tree().change_scene_to_file.bind(next_level_file))
	
