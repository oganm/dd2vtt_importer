extends Reference

# returns the scene after reading the dd2vtt output
func parse_dd2vtt(data:Dictionary, options: Dictionary, root_name:String = 'Map')->Node2D:
	print('parsing')
	print(data.resolution)
	var root = Node2D.new()
	root.name = root_name
	
	# read the image texture
	var image_raw = Marshalls.base64_to_raw(data.image)
	var image = Image.new()
	image.load_png_from_buffer(image_raw)
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	
	# add tecture as a sprite
	var sprite = Sprite.new()
	sprite.name = 'Map'
	sprite.texture = texture
	root.add_child(sprite)
	sprite.owner = root
	
	# read line of sight blockers
	if options['Walls as Lines'] or options['Walls as Occluders']:
		for blocker in data.line_of_sight:
			var offset = Vector2(-data.resolution.map_size.x*data.resolution.pixels_per_grid/2,
								 -data.resolution.map_size.y*data.resolution.pixels_per_grid/2)
			var points = dict2vector2array(blocker, data.resolution.pixels_per_grid,offset)
			if options['Walls as Lines']:
				var line:= Line2D.new()
				line.points = points
				root.add_child(line)
				line.owner = root
			if options['Walls as Occluders']:
				var occluder := LightOccluder2D.new()
				occluder.occluder = OccluderPolygon2D.new()
				var occluder_points: PoolVector2Array
				occluder_points.append_array(points)
				points.invert()
				occluder_points.append_array(points)
				occluder.occluder.polygon = occluder_points
				root.add_child(occluder)
				occluder.owner = root
	return root

# reads dd2vtt file to return a json
func read_json(file_path:String)->Dictionary:
	var file = File.new()
	var err = file.open(file_path, File.READ)
	var data = file.get_as_text()
	file.close()
	
	var data_parse: JSONParseResult = JSON.parse(data)
	if typeof(data_parse.result) != TYPE_DICTIONARY:
		push_error('Could not parse json')
		
	return data_parse.result


func dict2vector2array(dict_array:Array,multiplier:float, offset:Vector2):
	var array: PoolVector2Array
	for x in dict_array:
		array.append(Vector2(x.x*multiplier+offset.x,x.y*multiplier+offset.y))
	return array
