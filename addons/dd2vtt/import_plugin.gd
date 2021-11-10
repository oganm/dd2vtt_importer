tool
extends EditorImportPlugin

enum Presets { DEFAULT }

const utils_ref = preload("util.gd")

func get_importer_name():
	return "dd2vtt.importer"

func get_visible_name():
	return "dd2vtt Map"

func get_recognized_extensions():
	return ["dd2vtt"]

func get_save_extension():
	return "scn"

func get_resource_type():
	return "PackedScene"


func get_preset_count():
	return Presets.size()

func get_preset_name(preset):
	match preset:
		Presets.DEFAULT:
			return "Default"
		_:
			return "Unknown"

func get_import_options(preset):
	match preset:
		Presets.DEFAULT:
			return [{'name':'Import Walls','default_value':true}]
		_:
			return []

func get_option_visibility(option, options):
	return true


func import(source_file, save_path, options, platform_variants, gen_files):
	print(options)
	var utils = utils_ref.new()
	var data = utils.read_json(source_file)
	
	var scene = utils.parse_dd2vtt(data,options['Import Walls'])
	
	var packed_scene = PackedScene.new()
	packed_scene.pack(scene)
	return ResourceSaver.save("%s.%s" % [save_path, get_save_extension()], packed_scene)
