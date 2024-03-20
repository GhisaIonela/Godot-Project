extends Control

@onready var presets : Dictionary = {}
var FILEPATH : String = "res://Data/Presets/tiles.txt"
var ICON_FILEPATH : String = "res://Assets/Icons/Tiles/"
@onready var presetsContainer : FlowContainer = $MarginContainer/VBoxContainer/Panel/HBoxContainer/Presets
@onready var propContainer : VBoxContainer = $MarginContainer/VBoxContainer/Panel/HBoxContainer/RightContainer/ScrollContainer/PropContainer
@onready var preview : SubViewport = $MarginContainer/VBoxContainer/Panel/HBoxContainer/RightContainer/MarginContainer/SubViewportContainer/Preview
@onready var modelContainer : HBoxContainer = $MarginContainer/VBoxContainer/Panel/HBoxContainer/RightContainer/ScrollContainer/PropContainer/model
@onready var deleteButton : Button = $MarginContainer/VBoxContainer/Panel/HBoxContainer/RightContainer/HBoxContainer/DeletePresetButton

func _ready():
	load_presets()

func load_presets():
	presets = FileHandler.load_data(FILEPATH)
	for key in presets.keys():
		var button : Button = Button.new()
		button.text = key
		button.icon = load(presets[key]["icon"])
		button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		button.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		button.custom_minimum_size = Vector2(128, 64)
		
		button.set_meta("tid", key)
		button.set_meta("name", presets[key]["name"])
		button.set_meta("category", presets[key]["category"])
		button.set_meta("model", presets[key]["model"])
		button.set_meta("icon", presets[key]["icon"])
		button.set_meta("rotatable", presets[key]["rotatable"])
		if presets[key].has("size"):
			button.set_meta("size", presets[key]["size"])
		else:
			button.set_meta("size", Vector3(1,1,1))
		button.connect("pressed", _on_preset_button_pressed.bind(button))
		
		presetsContainer.add_child(button)
		
func _on_preset_button_pressed(button : Button):
	propContainer.get_node("tid").get_child(1).text = button.get_meta("tid")
	_on_line_edit_text_changed(button.get_meta("tid"))
	propContainer.get_node("name").get_child(1).text = button.get_meta("name")
	propContainer.get_node("category").get_child(1).text = button.get_meta("category")
	propContainer.get_node("model").get_child(1).text = button.get_meta("model")
	var rotatable : Vector3 = button.get_meta("rotatable")
	propContainer.get_node("rotatable").get_child(2).button_pressed = bool(rotatable.x)
	propContainer.get_node("rotatable").get_child(4).button_pressed = bool(rotatable.y)
	propContainer.get_node("rotatable").get_child(6).button_pressed = bool(rotatable.z)
	if !button.get_meta("model").is_empty():
		load_glb(true)

func load_glb(reload : bool = false) -> void:
	var path = propContainer.get_node("model").get_child(1).text
	var oldObject = preview.get_node("model")
	if oldObject != null:
		preview.remove_child(oldObject)
		oldObject.queue_free()
	
	var state := GLTFState.new()
	var document := GLTFDocument.new()
	document.append_from_file(path, state)
	var scene : Node = document.generate_scene(state)
	scene.name = "model"
	var meshInstance : MeshInstance3D = scene.get_child(0)
	
	var meshSize : Vector3 = meshInstance.mesh.get_aabb().size
	
	meshSize = Vector3(int(snapped(meshSize.x, 1)), int(snapped(meshSize.y, 1)), int(snapped(meshSize.z, 1)))
	propContainer.get_node("size").get_child(2).value = meshSize.x
	propContainer.get_node("size").get_child(4).value = meshSize.y
	propContainer.get_node("size").get_child(6).value = meshSize.z
	preview.get_child(2).position = Vector3(-1.5, 1.15, -1.5) + meshSize * Vector3(-1, 0.3, -1) + Vector3(1, -0.3, 1)
	
	var tid = propContainer.get_node("tid").get_child(1).text
	if reload:
		if tid.is_empty():
			if presets[tid].has("texture"):
				presets[tid]["texture"] = {}
			if presets[tid].has("color"):
				presets[tid]["color"] = {}
				
		for control in get_tree().get_nodes_in_group("model_property"):
			propContainer.remove_child(control)
			control.queue_free()
		
		for index in range(0, meshInstance.mesh.get_surface_count()):
			# -------------------------
			#Color
			var colorContainer = HBoxContainer.new()
			colorContainer.add_to_group("model_property")
			
			var colorLabel = Label.new()
			colorLabel.text = "Color surface " + str(index)
			
			var colorRect = ColorRect.new()
			colorRect.set_meta("surface", index)
			colorRect.set_meta("show_picker", false)
			colorRect.add_to_group("color")
			colorRect.connect("gui_input", _on_color_rect_clicked.bind(colorRect))
			colorRect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			
			var colorPicker = ColorPicker.new()
			colorPicker.visible = false
			colorPicker.connect("color_changed", _on_color_picker_color_changed.bind(colorRect))
			
			colorContainer.add_child(colorLabel)
			colorContainer.add_child(colorRect)
			colorContainer.add_child(colorPicker)
			propContainer.add_child(colorContainer)
			
			# -------------------------
			#Texture
			var textureContainer = HBoxContainer.new()
			textureContainer.add_to_group("model_property")
			
			var textureLabel = Label.new()
			textureLabel.text = "Texture surface " + str(index)
			
			var texturePathInput = LineEdit.new()			
			texturePathInput.set_meta("surface", index)
			texturePathInput.add_to_group("texture")
			texturePathInput.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			var browseTextureButton = Button.new()
			browseTextureButton.text = "Browse"
			browseTextureButton.connect("pressed", _on_browse_texture.bind(texturePathInput))
			
			textureContainer.add_child(textureLabel)
			textureContainer.add_child(texturePathInput)
			textureContainer.add_child(browseTextureButton)
			propContainer.add_child(textureContainer)
			
			if !tid.is_empty():
				if presets[tid].has("color"):
					if presets[tid]["color"].has(index):
						var color = presets[tid]["color"][index]
						colorRect.color = Color(color)
						colorPicker.color = Color(color)
						meshInstance.mesh.surface_get_material(index).albedo_color = color
					else:
						presets[tid]["color"][colorRect.get_meta("surface")] = colorRect.color
						meshInstance.mesh.surface_get_material(index).albedo_color = colorRect.color
						
				if presets[tid].has("texture"):
					if presets[tid]["texture"].has(index):
						var texture_path = presets[tid]["texture"][index]
						texturePathInput.text = texture_path
						if texture_path.is_empty():
							meshInstance.mesh.surface_get_material(index).albedo_texture = null
						else:
							meshInstance.mesh.surface_get_material(index).albedo_texture = load(texture_path)
					else:
						if !texturePathInput.text.is_empty():
							presets[tid]["texture"][index] = texturePathInput.text
				else:
					texturePathInput.text = meshInstance.mesh.surface_get_material(index).resource_path
	
	# Setting colors
	var colorRects = get_tree().get_nodes_in_group("color")
	for colorRect in colorRects:
		var color : Color = colorRect.color
		var index : int = colorRect.get_meta("surface")
		meshInstance.mesh.surface_get_material(index).albedo_color = color
		
	# Setting textures
	var texturePathInputs = get_tree().get_nodes_in_group("texture")
	for texturePath in texturePathInputs:
		var tpath : String = texturePath.text
		var index : int = texturePath.get_meta("surface")
		if tpath.is_empty():
			meshInstance.mesh.surface_get_material(index).albedo_texture = null
		else:
			meshInstance.mesh.surface_get_material(index).albedo_texture = load(tpath)
	
	preview.add_child(scene)

# -------------------------
# Color signals
func _on_color_rect_clicked(event : InputEvent, colorRect : ColorRect) -> void:
	if event.is_action_pressed("action_left_click"):
		var show_picker : bool = !colorRect.get_meta("show_picker")
		colorRect.get_parent().get_child(2).visible = show_picker
		colorRect.set_meta("show_picker", show_picker)

func _on_color_picker_color_changed(color : Color, colorRect : ColorRect) -> void:
	colorRect.color = color
	load_glb()
# -------------------------
# Texture signals
func _on_browse_texture(texturePathInput : LineEdit) -> void:
	var fileDialog : FileDialog = FileDialog.new()
	if texturePathInput.text.is_empty():
		fileDialog.current_path = "res://Assets/Objects/Tiles/"
	else:
		fileDialog.current_path = texturePathInput.text
	fileDialog.set_filters(PackedStringArray(["*.png"]))
	add_child(fileDialog)
	fileDialog.connect("file_selected", _on_texture_selected.bind(texturePathInput))
	fileDialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	fileDialog.popup_centered(Vector2(700, 500))
	
func _on_texture_selected(path : String,  texturePathInput : LineEdit) -> void:
	texturePathInput.text = path
	load_glb()
# -------------------------
# Model
func _on_model_button_pressed():
	var fileDialog : FileDialog = FileDialog.new()
	var modelInputFiled : LineEdit = propContainer.get_node("model").get_child(1)
	if modelInputFiled.text.is_empty():
		fileDialog.current_path = "res://Assets/Objects/Tiles/"
	else:
		fileDialog.current_path = modelInputFiled.text
	fileDialog.set_filters(PackedStringArray(["*.glb"]))
	add_child(fileDialog)
	fileDialog.connect("file_selected", _on_model_selected.bind(modelInputFiled))
	fileDialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	fileDialog.popup_centered(Vector2(700, 500))

func _on_model_selected(path : String,  modelInputFiled : LineEdit) -> void:
	modelInputFiled.text = path
	load_glb(true)

func _on_new_preset_button_pressed():
	var tid : String = propContainer.get_node("tid").get_child(1).text
	if !tid.is_empty():
		var icon : Image = preview.get_texture().get_image()
		var icon_path : String = ICON_FILEPATH + tid + ".png"
		icon.save_png(icon_path)
		
		var rotatable_x : int = int(propContainer.get_node("rotatable").get_child(2).button_pressed)
		var rotatable_y : int = int(propContainer.get_node("rotatable").get_child(4).button_pressed)
		var rotatable_z : int = int(propContainer.get_node("rotatable").get_child(6).button_pressed)
		
		var size_x : int = propContainer.get_node("size").get_child(2).value
		var size_y : int = propContainer.get_node("size").get_child(4).value
		var size_z : int = propContainer.get_node("size").get_child(6).value
		
		var tile_properties : Dictionary = {
			"name" : propContainer.get_node("name").get_child(1).text,
			"category" : propContainer.get_node("category").get_child(1).text,
			"model" : propContainer.get_node("model").get_child(1).text,
			"icon" :  icon_path,
			"rotatable" : Vector3(rotatable_x, rotatable_y, rotatable_z),
			"size" : Vector3(size_x, size_y, size_z)
		}
		
		var textures = get_tree().get_nodes_in_group("texture")
		if textures.size() > 0:
			tile_properties["texture"] = {}
			for texture in textures:
				var path : String = texture.text
				if !path.is_empty():
					var index : int  = texture.get_meta("surface")
					tile_properties["texture"][index] = path
			if tile_properties["texture"].is_empty():
				tile_properties.erase("texture")
		
		var color_swatches = get_tree().get_nodes_in_group("color")
		if color_swatches.size() > 0 :
			tile_properties["color"] = {}
			for color_swatch in color_swatches:
				var color : String = color_swatch.color.to_html()
				var index : int = color_swatch.get_meta("surface")
				tile_properties["color"][index] = color
		
		presets[tid] = tile_properties
		
		var sorted_presets : Dictionary = {}
		var presets_keys = presets.keys()
		presets_keys.sort()
		for key in presets_keys:
			sorted_presets[key] = presets[key]
		
		FileHandler.save_data(FILEPATH, sorted_presets)
		
		for preset in presetsContainer.get_children():
			presetsContainer.remove_child(preset)
			preset.queue_free()
		load_presets()

func _on_delete_preset_button_pressed():
	var tid : String = propContainer.get_node("tid").get_child(1).text
	_on_line_edit_text_changed(tid)
	var dir = DirAccess.open(presets[tid]["icon"].get_base_dir())
	dir.remove(presets[tid]["icon"])
	dir.remove(presets[tid]["icon"] + ".import")
	presets.erase(tid)
	
	var sorted_presets : Dictionary = {}
	var presets_keys = presets.keys()
	presets_keys.sort()
	for key in presets_keys:
		sorted_presets[key] = presets[key]
	
	FileHandler.save_data(FILEPATH, presets)
	
	for preset in presetsContainer.get_children():
		presetsContainer.remove_child(preset)
		preset.queue_free()
		
	deleteButton.disabled = true
	load_presets()

func _on_line_edit_text_changed(tid : String) -> void:
	if presets.has(tid):
		deleteButton.disabled = false
		modelContainer.get_child(1).editable = true
		modelContainer.get_child(2).disabled = false
	else:
		deleteButton.disabled = true
		modelContainer.get_child(1).editable = false
		modelContainer.get_child(2).disabled = true
