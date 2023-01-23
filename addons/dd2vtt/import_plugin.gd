@tool
extends EditorImportPlugin

enum Presets { DEFAULT }

const utils_ref = preload("util.gd")

func _get_importer_name():
	return "dd2vtt.importer"

func _get_visible_name():
	return "dd2vtt Map"

func _get_recognized_extensions():
	return ["dd2vtt"]

func _get_save_extension():
	return "scn"

func _get_resource_type():
	return "PackedScene"

func _get_preset_count():
	return Presets.size()

func _get_import_order():
	return 0

func _get_preset_name(preset):
	match preset:
		Presets.DEFAULT:
			return "Default"
		_:
			return "Unknown"

var lights 

func _get_priority():
	return 1

func _get_import_options(path: String, preset_index: int):
	match preset_index:
		Presets.DEFAULT:
			return [{'name':'Walls as Occluders','default_value':true},
					{'name':'Walls as Lines','default_value':true},
					{'name':'Load Lights','default_value':true},
					{'name':"Light Texture",'default_value':load('res://addons/dd2vtt/light_textures/soft_texture.tres'),'property_hint':PROPERTY_HINT_RESOURCE_TYPE,'hint_string':'StreamTexture'},
					{'name':"Occluder Objects",'default_value':true}]
		_:
			return []

func _get_option_visibility(path: String, option_name: StringName, options: Dictionary):
	return true


func _import(source_file, save_path, options, platform_variants, gen_files):
	var utils = utils_ref.new()
	var data = utils.read_json(source_file)
	
	var scene = utils.parse_dd2vtt(data,options)
	
	var packed_scene = PackedScene.new()
	packed_scene.pack(scene)
	return ResourceSaver.save(packed_scene, "%s.%s" % [save_path, _get_save_extension()])

