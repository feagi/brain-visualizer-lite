extends Node3D

const camera_snap_offset: Vector3 = Vector3(0.0, 15.0, -25.0)

signal voxel_selected_to_list(area: AbstractCorticalArea, local_coord: Vector3i, added: bool)

var shader_material # Wait for shader 
var global_name_list = {}
var limit_neuron_selection_to_cortical_area: AbstractCorticalArea = null

var _prefab_single_preview: PackedScene = preload("res://BrainVisualizer/UI/BrainMonitor/Previews/BrainMonitorSinglePreview.tscn")

func _ready():
	FeagiCore.feagi_local_cache.cortical_areas.cortical_area_added.connect(on_cortical_area_added)
#	shader_material = $cortical_area_box.mesh.material # EXPERIMENT
	FeagiCore.network.websocket_API.feagi_return_neuron_activation_data.connect(test)
	FeagiCore.feagi_local_cache.cortical_areas.cortical_area_about_to_be_removed.connect(delete_single_cortical)
	FeagiCore.feagi_local_cache.cortical_areas.cortical_area_mass_updated.connect(move_when_changed)
	FeagiCore.about_to_reload_genome.connect(clear_all_selections)
	pass

## Stupid
func move_when_changed(changed: AbstractCorticalArea):
	check_cortical(changed) # This is dum

func clear_all_selections() -> void:
	for key in Godot_list.godot_list["data"]["direct_stimulation"]:
		Godot_list.godot_list["data"]["direct_stimulation"][key] = []
	for node in get_children(): # cancer
		if node.name.contains("*"):
			node.clear()


#TODO TEMP
## Generates and parents a preview and returns the object 
func generate_single_preview(initial_dimensions: Vector3, initial_position: Vector3, initial_color: Color = BrainMonitorSinglePreview.DEFAULT_COLOR, is_rendering: bool = true) -> BrainMonitorSinglePreview:
	var preview: BrainMonitorSinglePreview = _prefab_single_preview.instantiate()
	add_child(preview)
	preview.setup(initial_dimensions, initial_position, initial_color, is_rendering)
	return preview

## Snaps the camera to a cortical area
func snap_camera_to_cortical_area(cortical_area: AbstractCorticalArea) -> void:
	var camera: BVCam = $BVCam
	var bv_location: Vector3 = cortical_area.BV_position()
	camera.teleport_to_look_at_without_changing_angle(bv_location)

func on_cortical_area_added(cortical_area: AbstractCorticalArea) -> void:
	generate_cortical_area(cortical_area)


func generate_cortical_area(cortical_area_data : AbstractCorticalArea):
	var textbox = $blank_textbox.duplicate()
	var viewport = textbox.get_node("SubViewport")
	textbox.scale = Vector3(1,1,1)
	textbox.transform.origin = Vector3(cortical_area_data.coordinates_3D.x + (cortical_area_data.dimensions_3D.x/1.5), cortical_area_data.coordinates_3D.y +1 + cortical_area_data.dimensions_3D.y, -1 * cortical_area_data.dimensions_3D.z - cortical_area_data.coordinates_3D.z)
	textbox.get_node("SubViewport/Label").set_text(str(cortical_area_data.friendly_name.left(15)))
	
	if cortical_area_data.cortical_ID in UIManager.KNOWN_ICON_PATHS:
		textbox.get_node("SubViewport/TextureRect").texture = load(UIManager.KNOWN_ICON_PATHS[cortical_area_data.cortical_ID])
	else:
		textbox.get_node("SubViewport/TextureRect").queue_free()
	textbox.set_texture(viewport.get_texture())
	textbox.set_name(cortical_area_data.cortical_ID + str("_textbox"))
	if not textbox.get_name() in global_name_list:
		global_name_list[textbox.get_name()] = []
	global_name_list[textbox.get_name()].append([textbox])
	if int(cortical_area_data.dimensions_3D.x) * int(cortical_area_data.dimensions_3D.y) * int(cortical_area_data.dimensions_3D.z) < 999: # Prevent massive cortical area
		generate_model(cortical_area_data.cortical_ID, cortical_area_data.coordinates_3D.x,cortical_area_data.coordinates_3D.y,cortical_area_data.coordinates_3D.z,cortical_area_data.dimensions_3D.x, cortical_area_data.dimensions_3D.z, cortical_area_data.dimensions_3D.y)
	else:
		generate_one_model(cortical_area_data.cortical_ID, cortical_area_data.coordinates_3D.x,cortical_area_data.coordinates_3D.y,cortical_area_data.coordinates_3D.z,cortical_area_data.dimensions_3D.x, cortical_area_data.dimensions_3D.z, cortical_area_data.dimensions_3D.y)
# Uncomment below for the new approach to reduce the CPU usuage
#	var new_node = $cortical_area_box.duplicate() # Duplicate node
#	new_node.visible = true
#	new_node.set_name(cortical_area_data.cortical_ID)
#	new_node.scale = cortical_area_data.dimensions_3D
#	new_node.transform.origin = Vector3((cortical_area_data.dimensions_3D.x/2 + cortical_area_data.coordinates_3D.x),(cortical_area_data.dimensions_3D.y/2 + cortical_area_data.coordinates_3D.y), -1 * (cortical_area_data.dimensions_3D.z/2 + cortical_area_data.coordinates_3D.z))
#	add_child(new_node)
	add_child(textbox)

func generate_one_model(name_input, x_input, y_input, z_input, width_input, depth_input, height_input):
	var new = $cortical_area_box.duplicate() # Duplicate node
	new.visible = true
	new.set_name(name_input)
	add_child(new)
	new.visible = true
	new.scale = Vector3(width_input, height_input, depth_input)
	name_input = name_input.replace(" ", "")
	if not name_input in global_name_list:
		global_name_list[name_input] = []
	global_name_list[name_input].append([new, x_input, y_input, z_input, width_input, depth_input, height_input])
	new.transform.origin = Vector3(width_input/2 + int(x_input), height_input/2+ int(y_input), -1 * (depth_input/2 + int(z_input)))

func generate_model(name_input, x_input, y_input, z_input, width_input, depth_input, height_input):
	var counter = 0
	for x_gain in width_input:
		for y_gain in height_input:
			for z_gain in depth_input:
				if x_gain == 0 or x_gain == (int(width_input)-1) or y_gain == 0 or y_gain == (int(height_input) - 1) or z_gain == 0 or z_gain == (int(depth_input) - 1):
					var new = $cortical_area_box.duplicate() # Duplicate node
					new.visible = true
					new.set_name(name_input+ "*" + str(counter))
					add_child(new)
					new.visible = true
					if not name_input in global_name_list:
						global_name_list[name_input] = []
					global_name_list[name_input].append([new, x_input, y_input, z_input, width_input, depth_input, height_input])
					new.transform.origin = Vector3(x_gain+int(x_input), y_gain+int(y_input), -1 * (z_gain+int(z_input)))
					counter += 1

func test(retrieved_data: PackedByteArray):
	
		# This array processing is slow. However to resolve this, we need to PR godot to create a proper method to handle this
	var stored_value: Array[Array] = []
	var offset: int = 2 # skip header
	var max_offset: int = len(retrieved_data)
	while offset < max_offset:
		stored_value.append([retrieved_data.decode_s16(offset), retrieved_data.decode_s16(offset + 2), retrieved_data.decode_s16(offset + 4)])
		offset += 6
	
	
	if stored_value == null: # Checks if it's null. When it is, it clear red voxels
		$red_voxel.multimesh.instance_count = 0
		$red_voxel.multimesh.visible_instance_count = 0
		return # skip the function
	var total = stored_value.size() # Fetch the full length of array
	$red_voxel.multimesh.instance_count = total
	$red_voxel.multimesh.visible_instance_count = total
	for flag in range(total): # Not sure if this helps? It helped in some ways but meh.Is there better one?
		var voxel_data = stored_value[flag]
		var new_position = Transform3D().translated(Vector3(voxel_data[0], voxel_data[1], -voxel_data[2]))
		$red_voxel.multimesh.set_instance_transform(flag, new_position)

func notate_highlighted_neuron(cortical_area: AbstractCorticalArea, local_neuron_coordinate: Vector3i) -> void:
	var coordLabel: Label = $coordlabel
	var text: String = cortical_area.friendly_name + " " + str(local_neuron_coordinate) + " "
	if cortical_area is IPUCorticalArea:
		var device_index: int = floori((local_neuron_coordinate.x) / cortical_area.cortical_dimensions_per_device.x)
		var appending_definitions: Array[StringName] = cortical_area.get_custom_names(FeagiCore.feagi_local_cache.configuration_jsons, device_index)
		for appending in appending_definitions:
			text += "| " + appending
	elif cortical_area is OPUCorticalArea:
		var device_index: int = floori((local_neuron_coordinate.x) / cortical_area.cortical_dimensions_per_device.x)
		var appending_definitions: Array[StringName] = cortical_area.get_custom_names(FeagiCore.feagi_local_cache.configuration_jsons, device_index)
		for appending in appending_definitions:
			text += "| " + appending
	
	if cortical_area.cortical_ID == "o_mctl":
		var device_local_coordinate: Vector3i = Vector3i(local_neuron_coordinate.x % 4, local_neuron_coordinate.y % 3, 0)
		var direction: String
		match(device_local_coordinate):
			Vector3i(0,0,0): direction = " - Move Left"
			Vector3i(1,0,0): direction = " - Move Up"
			Vector3i(2,0,0): direction = " - Move Down"
			Vector3i(3,0,0): direction = " - Move Right"
			
			Vector3i(0,1,0): direction = " - Yaw Left"
			Vector3i(1,1,0): direction = " - Move Forward"
			Vector3i(2,1,0): direction = " - Move Backward"
			Vector3i(3,1,0): direction = " - Yaw Right"
			
			Vector3i(0,2,0): direction = " - Roll Left"
			Vector3i(1,2,0): direction = " - Pitch Forward"
			Vector3i(2,2,0): direction = " - Pitch Backward"
			Vector3i(3,2,0): direction = " - Roll Right"
		text += direction
	coordLabel.text = text
	
func _clear_node_name_list(node_name):
	"""
	clear all cortical area along with the library list/dict
	"""
##	for key in Godot_list.godot_list["data"]["direct_stimulation"]:
##		Godot_list.godot_list["data"]["direct_stimulation"][key] = []
	var list = node_name
	if list.is_empty() != true:
		var list_size = global_name_list.size()
		for i in list_size:
			for iteration_name in global_name_list[i]:
				global_name_list[i][iteration_name][0].queue_free()
		global_name_list = {}

func update_all_node_from_cortical(name_input, material):
	for i in global_name_list:
		if name_input in i:
			for x in len(global_name_list[i]):
				global_name_list[i][x][0].set_surface_override_material(0, material)

func delete_single_cortical(cortical_area_data : AbstractCorticalArea):
	var name_list : Array = [] # To get cortical name
	var cortical_text = cortical_area_data.cortical_ID + "_textbox"
	for i in global_name_list:
		if cortical_area_data.cortical_ID in i or cortical_text in i:
			for x in len(global_name_list[i]):
				remove_child(global_name_list[i][x][0])
				global_name_list[i][x][0].queue_free()
			name_list.append(i)
	for i in name_list:
		global_name_list.erase(i)
	
func demo_new_cortical():
	"""
	This is for add new cortical area so the name will be updated when you move it around. This is designed to use
	the duplicated node called "example", so if it has no name, it will display as "example" but if
	it has a letter or name, it will display as the user typed.
	"""
	for i in global_name_list:
		if "example" in i:
			for x in len(global_name_list[i]):
				if global_name_list[i][x][0].get_child(0).get_class() == "Viewport":
					global_name_list[i][x][0].get_child(0).get_child(0).text = "example"

func delete_example():
	"""For the cortical named "example" only"""
	var name_list : Array = [] # To get cortical name
	for i in global_name_list:
		if "example" in i or "example_textbox" in i:
			for x in len(global_name_list[i]):
				remove_child(global_name_list[i][x][0])
				global_name_list[i][x][0].queue_free()
			name_list.append(i)
	for i in name_list:
		global_name_list.erase(i)


#why
func check_cortical(cortical_area_data : AbstractCorticalArea):
	# TODO: This is dumb
	var label: Label = get_node(cortical_area_data.cortical_ID + "_textbox/SubViewport/Label") # WHY ARE WE USING SUB VIEW PORTS!?
	label.text = cortical_area_data.friendly_name.left(15) # What is this even doing here? 
	if global_name_list: # Pretty sure this is already exist in cache. We need to replace this with current list.
		var coordinate_3D = global_name_list[cortical_area_data.cortical_ID][0].slice(1, 4)
		var dimension = global_name_list[cortical_area_data.cortical_ID][0].slice(4, 8)
		var dimension_updated = Vector3i(dimension[0], dimension[2], dimension[1]) # Okay.
		var coordinate_3D_updated = Vector3i(coordinate_3D[0], coordinate_3D[1], coordinate_3D[2])  #Cool. We are doing vector3i instead. all right
		if (coordinate_3D_updated != cortical_area_data.coordinates_3D) or (dimension_updated != cortical_area_data.dimensions_3D):
			delete_single_cortical(cortical_area_data) # Not going to bother to try and improve this. 
			for i in global_name_list:
				if cortical_area_data.cortical_ID in i:
					print(global_name_list[i])
			generate_cortical_area(cortical_area_data)
			# Actual fix here
			Godot_list.godot_list["data"]["direct_stimulation"][cortical_area_data.cortical_ID] = [] # Now this is something I wrote. 
			
