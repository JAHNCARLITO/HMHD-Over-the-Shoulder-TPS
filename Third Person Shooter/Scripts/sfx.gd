class_name Sfx

static func play(stream: AudioStream, tree: SceneTree, volume_db := 0.0) -> void:
	var p := AudioStreamPlayer.new()
	p.stream = stream
	p.volume_db = volume_db
	p.finished.connect(p.queue_free)
	tree.current_scene.add_child(p)
	p.play()


static func play_loop(stream: AudioStream, tree: SceneTree, volume_db := 0.0) -> void:
	stream.loop = true
	var p := AudioStreamPlayer.new()
	p.stream = stream
	p.volume_db = volume_db
	p.autoplay = true
	tree.current_scene.add_child.call_deferred(p)
