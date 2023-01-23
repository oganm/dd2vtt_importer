extends RefCounted

# returns the scene after reading the dd2vtt output
func parse_dd2vtt(data:Dictionary, options: Dictionary, root_name:String = 'Map')->Node2D:
	var root = Node2D.new()
	root.name = root_name
	
	# read the image texture
	var image_raw = Marshalls.base64_to_raw(data.image)
	var image = Image.new()
	image.load_png_from_buffer(image_raw)

	var texture := ImageTexture.new()
	texture.set_image(image)
	
	# add tecture as a sprite
	var sprite = Sprite2D.new()
	sprite.name = 'Map'
	sprite.texture = texture
	root.add_child(sprite)
	sprite.owner = root
	
	# read line of sight blockers
	if options['Walls as Lines'] or options['Walls as Occluders']:
		var LineWalls = Node2D.new()
		var OccluderWalls = Node2D.new()
		if options['Walls as Lines']:
			root.add_child(LineWalls)
			LineWalls.name = 'LineWalls'
			LineWalls.owner = root
		if options['Walls as Occluders']:
			OccluderWalls.name = "OccluderWalls"
			root.add_child(OccluderWalls)
			OccluderWalls.owner = root
		
		for blocker in data.line_of_sight:
			var points := dict2vector2array(blocker, data.resolution)
			if options['Walls as Lines']:
				var line:= Line2D.new()
				line.points = points
				LineWalls.add_child(line)
				line.owner = root
			if options['Walls as Occluders']:
				var occluder := LightOccluder2D.new()
				occluder.occluder = OccluderPolygon2D.new()
				var occluder_points: Array
				occluder_points.append_array(points)
				points.reverse()
				occluder_points.append_array(points)
				occluder.occluder.polygon = points
				occluder.occluder.closed = false
				OccluderWalls.add_child(occluder)
				occluder.owner = root
				
	if options['Load Lights']:
		var Lights = Node2D.new()
		root.add_child(Lights)
		Lights.owner = root
		Lights.name = 'Lights'
		for light in data.lights:
			var light2d := Light2D.new()
			light2d.position = convert_coords(Vector2(light.position.x,light.position.y),data.resolution)
			light2d.texture = Texture2D.new()
			light2d.set_texture(options['Light Texture'])
			light2d.shadow_enabled = true
			light2d.color = light.color
			light2d.energy = light.intensity
			var texture_size = light2d.texture.get_size().x
			light2d.texture_scale = light.range*data.resolution.pixels_per_grid/texture_size*2
			Lights.add_child(light2d)
			light2d.owner = root
			
	if options['Occluder Objects']:
		var Objects = Node2D.new()
		root.add_child(Objects)
		Objects.show_behind_parent = true
		Objects.owner = root
		Objects.name = 'Objects'
		for object in data.objects_line_of_sight:
			var points = dict2vector2array(object,data.resolution)
			var occluder := LightOccluder2D.new()
			occluder.occluder = OccluderPolygon2D.new()
			occluder.occluder.polygon = points
			Objects.add_child(occluder)
			occluder.owner = root
	return root

# reads dd2vtt file to return a json
func read_json(file_path:String)->Dictionary:
	var json = FileAccess.get_file_as_string(file_path)
	var data = JSON.parse_string(json)
	return data

func convert_coords(vect: Vector2, resolution: Dictionary)->Vector2:
	return Vector2(vect.x*resolution.pixels_per_grid -resolution.map_size.x*resolution.pixels_per_grid/2,
		vect.y*resolution.pixels_per_grid -resolution.map_size.y*resolution.pixels_per_grid/2)
	

func dict2vector2array(dict_array:Array,resolution:Dictionary) -> Array:
	var array: Array
	for x in dict_array:
		array.append(convert_coords(Vector2(x.x,x.y),resolution))
	return array
