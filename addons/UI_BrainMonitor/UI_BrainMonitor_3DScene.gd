extends SubViewportContainer
class_name UI_BrainMonitor_3DScene
## Handles running the scene of Brain monitor, which shows a single instance of a brain region
const SCENE_BRAIN_MOINITOR_PATH: StringName = "res://addons/UI_BrainMonitor/BrainMonitor.tscn"

@export var multi_select_key: Key = KEY_SHIFT

signal clicked_cortical_area(area: AbstractCorticalArea) ## Clicked cortical area (regardless of context)
signal cortical_area_selected_neurons_changed(area: AbstractCorticalArea, selected_neuron_coordinates: Array[Vector3i])
signal cortical_area_selected_neurons_changed_delta(area: AbstractCorticalArea, selected_neuron_coordinate: Vector3i, is_added: bool)
signal requesting_to_fire_selected_neurons(area_IDs_and_neuron_coordinates: Dictionary[StringName, Array]) # NOTE: Array is of type Array[Vector3i]
signal requesting_to_clear_all_selected_neurons()

var representing_region: BrainRegion:
	get: return _representing_region

var _node_3D_root: Node3D
var _pancake_cam: UI_BrainMonitor_PancakeCamera
var _UI_layer_for_BM: UI_BrainMonitor_Overlay = null


var _representing_region: BrainRegion
var _world_3D: World3D # used for physics stuff
var _cortical_visualizations_by_ID: Dictionary[StringName, UI_BrainMonitor_CorticalArea]
var _active_previews: Array[UI_BrainMonitor_InteractivePreview] = []
var _restrict_neuron_selection_to: AbstractCorticalArea = null

var _previously_moused_over_volumes: Array[UI_BrainMonitor_CorticalArea] = []
var _previously_moused_over_cortical_area_neurons: Dictionary[UI_BrainMonitor_CorticalArea, Array] = {} # where Array is an Array of Vector3i representing Neuron Coordinates



## Spawns an non-setup Brain Visualizer Scene. # WARNING be sure to add it to the scene tree before running setup on it!
static func create_uninitialized_brain_monitor() -> UI_BrainMonitor_3DScene:
	return load(SCENE_BRAIN_MOINITOR_PATH).instantiate()

func _ready() -> void:
	_node_3D_root = $SubViewport/Center
	_UI_layer_for_BM = $SubViewport/BM_UI
	
	# TODO check mode (PC)
	_pancake_cam = $SubViewport/Center/PancakeCam
	if _pancake_cam:
		_pancake_cam.BM_input_events.connect(_process_user_input)
		_world_3D = _pancake_cam.get_world_3d()
	

func setup(region: BrainRegion) -> void:
	_representing_region = region
	name = "BM_" + region.region_ID

	
	
	# WARNING for the time being, we will have BM be global instead of region specific
	# for area: AbstractCorticalArea in _representing_region.contained_cortical_areas:
	# 	var rendering_area: UI_BrainMonitor_CorticalArea = _add_cortical_area(area)
	# region.cortical_area_added_to_region.connect(_add_cortical_area)
	# TEMP
	for area: AbstractCorticalArea in FeagiCore.feagi_local_cache.cortical_areas.available_cortical_areas.values():
		var rendering_area: UI_BrainMonitor_CorticalArea = _add_cortical_area(area)
	


func _process_user_input(bm_input_events: Array[UI_BrainMonitor_InputEvent_Abstract]) -> void:
	var current_space: PhysicsDirectSpaceState3D = _world_3D.direct_space_state
	var currently_moused_over_volumes: Array[UI_BrainMonitor_CorticalArea] = []
	var currently_mousing_over_neurons: Dictionary[UI_BrainMonitor_CorticalArea, Array] = {} # where Array is an Array of Vector3i representing Neuron Coordinates
	
	for bm_input_event in bm_input_events: # multiple events can happen at once
		
		if bm_input_event is UI_BrainMonitor_InputEvent_Hover:
			var hit: Dictionary = current_space.intersect_ray(bm_input_event.get_ray_query())
			if hit.is_empty():
				# Mousing over nothing right now
				
				_UI_layer_for_BM.clear() # temp!
				
				continue
				
			var hit_body: StaticBody3D = hit[&"collider"]
			if hit_body.get_parent() is not UI_BrainMonitor_AbstractCorticalAreaRenderer:
				return
			var hit_parent: UI_BrainMonitor_AbstractCorticalAreaRenderer = hit_body.get_parent()
			if not hit_parent:
				continue # this shouldn't be possible
			var hit_world_location: Vector3 = hit["position"]
			var hit_parent_parent: UI_BrainMonitor_CorticalArea = hit_parent.get_parent_BM_abstraction()
			var neuron_coordinate_mousing_over: Vector3i = hit_parent.world_godot_position_to_neuron_coordinate(hit_world_location)
			if not hit_parent_parent:
				continue # this shouldnt be possible
			
			currently_moused_over_volumes.append(hit_parent_parent)
			if hit_parent_parent in currently_mousing_over_neurons:
				if neuron_coordinate_mousing_over not in currently_mousing_over_neurons[hit_parent_parent]:
					currently_mousing_over_neurons[hit_parent_parent].append(neuron_coordinate_mousing_over)
			else:
				var typed_arr: Array[Vector3i] = [neuron_coordinate_mousing_over]
				currently_mousing_over_neurons[hit_parent_parent] = typed_arr
			
			_UI_layer_for_BM.mouse_over_single_cortical_area(hit_parent_parent.cortical_area, neuron_coordinate_mousing_over)# temp!
			
		elif bm_input_event is UI_BrainMonitor_InputEvent_Click:
			
			# special cases for actions
			if bm_input_event.button == UI_BrainMonitor_InputEvent_Abstract.CLICK_BUTTON.FIRE_SELECTED_NEURONS && bm_input_event.button_pressed: # special case when firing neurons
				var dict: Dictionary[StringName, Array] = {}
				for BM_cortical_area in _cortical_visualizations_by_ID.values():
					var selected_neurons: Array[Vector3i] = BM_cortical_area.get_neuron_selection_states()
					if !selected_neurons.is_empty():
						dict[BM_cortical_area.cortical_area.cortical_ID] = selected_neurons
				requesting_to_fire_selected_neurons.emit(dict)
				return
			if bm_input_event.button == UI_BrainMonitor_InputEvent_Abstract.CLICK_BUTTON.CLEAR_ALL_SELECTED_NEURONS && bm_input_event.button_pressed: # special case when clearing all neurons
				for bm_cortical_area in _cortical_visualizations_by_ID.values():
					bm_cortical_area.clear_all_neuron_selection_states() # slow but I dont care right now
			
			
			
			var hit: Dictionary = current_space.intersect_ray(bm_input_event.get_ray_query())
			if hit.is_empty():
				# Clicking over nothing
				continue
				
			var hit_body: StaticBody3D = hit[&"collider"]
			if hit_body.get_parent() is not UI_BrainMonitor_AbstractCorticalAreaRenderer:
				return
			var hit_parent: UI_BrainMonitor_AbstractCorticalAreaRenderer = hit_body.get_parent()
			if not hit_parent:
				continue # this shouldn't be possible
			var hit_world_location: Vector3 = hit["position"]
			var hit_parent_parent: UI_BrainMonitor_CorticalArea = hit_parent.get_parent_BM_abstraction()
			var neuron_coordinate_clicked: Vector3i = hit_parent.world_godot_position_to_neuron_coordinate(hit_world_location)
			if hit_parent_parent:
				currently_moused_over_volumes.append(hit_parent_parent)
				var arr_test: Array[GenomeObject] = [hit_parent_parent.cortical_area]
				if bm_input_event.button_pressed:
					if UI_BrainMonitor_InputEvent_Abstract.CLICK_BUTTON.HOLD_TO_SELECT_NEURONS in bm_input_event.all_buttons_being_held:
						var is_neuron_selected: bool = hit_parent_parent.toggle_neuron_selection_state(neuron_coordinate_clicked)
						cortical_area_selected_neurons_changed.emit(hit_parent_parent.cortical_area, hit_parent_parent.get_neuron_selection_states())
						cortical_area_selected_neurons_changed_delta.emit(hit_parent_parent.cortical_area, neuron_coordinate_clicked, is_neuron_selected)
					else:
						if bm_input_event.button == UI_BrainMonitor_InputEvent_Abstract.CLICK_BUTTON.MAIN:
							
							BV.UI.selection_system.select_objects(SelectionSystem.SOURCE_CONTEXT.UNKNOWN, arr_test)
							BV.UI.selection_system.cortical_area_voxel_clicked(hit_parent_parent.cortical_area, neuron_coordinate_clicked)
							#BV.UI.window_manager.spawn_quick_cortical_menu(arr_test)
							#clicked_cortical_area.emit(hit_parent_parent.cortical_area)
			
	
	# Higlight what has been moused over (and unhighlight what hasnt) (this is slow but not really a problem right now)
	for previously_moused_over_volume in _previously_moused_over_volumes:
		if previously_moused_over_volume not in currently_moused_over_volumes:
			previously_moused_over_volume.set_hover_over_volume_state(false)
	for currently_moused_over_volume in currently_moused_over_volumes:
		if currently_moused_over_volume not in _previously_moused_over_volumes:
			currently_moused_over_volume.set_hover_over_volume_state(true)
	_previously_moused_over_volumes = currently_moused_over_volumes
	
	# highlight neurons that are moused over (and unhighlight what wasnt)
	currently_mousing_over_neurons.merge(_previously_moused_over_cortical_area_neurons, false)
	for cortical_area in currently_mousing_over_neurons.keys():
		var typed_arr: Array[UI_BrainMonitor_CorticalArea] = []
		if len(currently_mousing_over_neurons[cortical_area]) == 0:
			# Cortical area has nothing hovering over it, tell the renderer to clear it
			cortical_area.clear_hover_state_for_all_neurons()
			currently_mousing_over_neurons.erase(cortical_area)
		else:
			# cortical area has things hovering over it, tell renderer to show it
			cortical_area.set_highlighted_neurons(currently_mousing_over_neurons[cortical_area])
		currently_mousing_over_neurons[cortical_area] = typed_arr
	_previously_moused_over_cortical_area_neurons = currently_mousing_over_neurons

#region Interaction

func clear_all_selected_cortical_area_neurons() -> void:
	for area: UI_BrainMonitor_CorticalArea in _cortical_visualizations_by_ID.values():
		area.clear_all_neuron_selection_states()

func set_further_neuron_selection_restriction_to_cortical_area(restrict_to: AbstractCorticalArea) -> void:
	if restrict_to.cortical_ID in _cortical_visualizations_by_ID:
		_restrict_neuron_selection_to = restrict_to

func remove_neuron_cortical_are_selection_restrictions() -> void:
	_restrict_neuron_selection_to = null

## Allows any external element to create a 3D preview in this BM that it can edit and free as needed
func create_preview(initial_FEAGI_soace_position: Vector3i, initial_dimensions: Vector3i, show_voxels: bool) -> UI_BrainMonitor_InteractivePreview:
	var preview: UI_BrainMonitor_InteractivePreview = UI_BrainMonitor_InteractivePreview.new()
	add_child(preview)
	preview.setup(initial_FEAGI_soace_position, initial_dimensions, show_voxels)
	_active_previews.append(preview)
	preview.tree_exiting.connect(_preview_closing)
	return preview

## Closes all currently active previews
func clear_all_open_previews() -> void:
	var previews_duplicated: Array[UI_BrainMonitor_InteractivePreview] = _active_previews.duplicate()
	for active_preview in previews_duplicated:
		if active_preview:
			active_preview.queue_free()
	_active_previews = []

## Called when the preview is about to be free'd for any reason
func _preview_closing(preview: UI_BrainMonitor_InteractivePreview):
	_active_previews.erase(preview)


#endregion


#region Cache Responses

# NOTE: Cortical area movements, resizes, and renames are handled by the [UI_BrainMonitor_CorticalArea]s themselves!

func _add_cortical_area(area: AbstractCorticalArea) -> UI_BrainMonitor_CorticalArea:
	if area.cortical_ID in _cortical_visualizations_by_ID:
		push_warning("Unable to add to BM already existing cortical area of ID %s!" % area.cortical_ID)
		return
	var rendering_area: UI_BrainMonitor_CorticalArea = UI_BrainMonitor_CorticalArea.new()
	_node_3D_root.add_child(rendering_area)
	rendering_area.setup(area)
	_cortical_visualizations_by_ID[area.cortical_ID] = rendering_area
	area.about_to_be_deleted.connect(_remove_cortical_area.bind(area))
	area.coordinates_3D_updated.connect(rendering_area.set_new_position)
	return rendering_area

func _remove_cortical_area(area: AbstractCorticalArea) -> void:
	if area.cortical_ID not in _cortical_visualizations_by_ID:
		push_warning("Unable to remove from BM nonexistant cortical area of ID %s!" % area.cortical_ID)
		return
	var rendering_area: UI_BrainMonitor_CorticalArea = _cortical_visualizations_by_ID[area.cortical_ID]
	_previously_moused_over_volumes.erase(rendering_area)
	_previously_moused_over_cortical_area_neurons.erase(rendering_area)
	rendering_area.queue_free()
	_cortical_visualizations_by_ID.erase(area.cortical_ID)

#endregion
