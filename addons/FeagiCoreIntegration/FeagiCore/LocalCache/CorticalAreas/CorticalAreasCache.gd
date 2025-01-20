extends RefCounted
class_name CorticalAreasCache
## Stores all cortical areas available in the genome

## We need some generic signals since dropdown popups (and some others) cannot do individual reference processing
signal cortical_area_added(cortical_area: AbstractCorticalArea)
signal cortical_area_about_to_be_removed(cortical_area: AbstractCorticalArea)
signal cortical_area_mass_updated(cortical_area: AbstractCorticalArea)

## All stored cortical areas, key'd by ID string
var available_cortical_areas: Dictionary:
	get: return _available_cortical_areas

var _available_cortical_areas: Dictionary = {}

#region Add, Remove, and Edit Single Cortical Areas
## Adds a cortical area of type core by ID and emits a signal that this was done. Should only be called from FEAGI!
func FEAGI_add_core_cortical_area(cortical_ID: StringName, cortical_name: StringName, coordinates_3D: Vector3i, dimensions: Vector3i, is_coordinate_2D_defined: bool, coordinates_2D: Vector2i, brain_region: BrainRegion, FEAGI_details: Dictionary = {}, is_visible: bool = true) -> void:
	var new_area: CoreCorticalArea = CoreCorticalArea.new(cortical_ID, cortical_name, dimensions, brain_region,  is_visible)
	new_area.FEAGI_change_coordinates_3D(coordinates_3D)
	if is_coordinate_2D_defined:
		new_area.FEAGI_change_coordinates_2D(coordinates_2D)
	new_area.FEAGI_apply_detail_dictionary(FEAGI_details)
	_available_cortical_areas[cortical_ID] = new_area
	print("FEAGI CACHE: Added core cortical area %s" % cortical_ID)
	cortical_area_added.emit(new_area)

## Adds a cortical area of type custom by ID and emits a signal that this was done. Should only be called from FEAGI!
func FEAGI_add_custom_cortical_area(cortical_ID: StringName, cortical_name: StringName, coordinates_3D: Vector3i, dimensions: Vector3i, is_coordinate_2D_defined: bool, coordinates_2D: Vector2i, brain_region: BrainRegion, FEAGI_details: Dictionary = {}, is_visible: bool = true) -> void:
	var new_area: CustomCorticalArea = CustomCorticalArea.new(cortical_ID, cortical_name, dimensions, brain_region, is_visible)
	new_area.FEAGI_change_coordinates_3D(coordinates_3D)
	if is_coordinate_2D_defined:
		new_area.FEAGI_change_coordinates_2D(coordinates_2D)
	new_area.FEAGI_apply_detail_dictionary(FEAGI_details)
	_available_cortical_areas[cortical_ID] = new_area
	print("FEAGI CACHE: Added custom cortical area %s" % cortical_ID)
	cortical_area_added.emit(new_area)

## Adds a cortical area of type IPU by ID and emits a signal that this was done. Should only be called from FEAGI!
func FEAGI_add_input_cortical_area(cortical_ID: StringName, template: CorticalTemplate, device_count: int, coordinates_3D: Vector3i, is_coordinate_2D_defined: bool, coordinates_2D: Vector2i, FEAGI_details: Dictionary = {}, is_visible: bool = true) -> void:
	var new_area: IPUCorticalArea = IPUCorticalArea.create_from_template(cortical_ID, template, device_count, is_visible)
	new_area.FEAGI_change_coordinates_3D(coordinates_3D)
	if is_coordinate_2D_defined:
		new_area.FEAGI_change_coordinates_2D(coordinates_2D)
	new_area.FEAGI_apply_detail_dictionary(FEAGI_details)
	_available_cortical_areas[cortical_ID] = new_area
	print("FEAGI CACHE: Added input cortical area %s" % cortical_ID)
	cortical_area_added.emit(new_area)

## Adds a cortical area of type IPU (without a template) by ID and emits a signal that this was done. Should only be called from FEAGI!
func FEAGI_add_input_cortical_area_without_template(cortical_ID: StringName, cortical_name: StringName, coordinates_3D: Vector3i, dimensions: Vector3i, is_coordinate_2D_defined: bool, coordinates_2D: Vector2i, FEAGI_details: Dictionary = {}, is_visible: bool = true) -> void:
	var new_area: IPUCorticalArea = IPUCorticalArea.new(cortical_ID, cortical_name, dimensions, is_visible)
	new_area.FEAGI_change_coordinates_3D(coordinates_3D)
	if is_coordinate_2D_defined:
		new_area.FEAGI_change_coordinates_2D(coordinates_2D)
	new_area.FEAGI_apply_detail_dictionary(FEAGI_details)
	_available_cortical_areas[cortical_ID] = new_area
	print("FEAGI CACHE: Added input cortical area %s" % cortical_ID)
	cortical_area_added.emit(new_area)

## Adds a cortical area of type OPU by ID and emits a signal that this was done. Should only be called from FEAGI!
func FEAGI_add_output_cortical_area(cortical_ID: StringName, template: CorticalTemplate, device_count: int, coordinates_3D: Vector3i, is_coordinate_2D_defined: bool, coordinates_2D: Vector2i, FEAGI_details: Dictionary = {}, is_visible: bool = true) -> void:
	var new_area: OPUCorticalArea = OPUCorticalArea.create_from_template(cortical_ID, template, device_count, is_visible)
	new_area.FEAGI_change_coordinates_3D(coordinates_3D)
	if is_coordinate_2D_defined:
		new_area.FEAGI_change_coordinates_2D(coordinates_2D)
	new_area.FEAGI_apply_detail_dictionary(FEAGI_details)
	_available_cortical_areas[cortical_ID] = new_area
	print("FEAGI CACHE: Added output cortical area %s" % cortical_ID)
	cortical_area_added.emit(new_area)

## Adds a cortical area of type OPU (without a template) by ID and emits a signal that this was done. Should only be called from FEAGI!
func FEAGI_add_output_cortical_area_without_template(cortical_ID: StringName, cortical_name: StringName, coordinates_3D: Vector3i, dimensions: Vector3i, is_coordinate_2D_defined: bool, coordinates_2D: Vector2i, FEAGI_details: Dictionary = {}, is_visible: bool = true) -> void:
	var new_area: OPUCorticalArea = OPUCorticalArea.new(cortical_ID, cortical_name, dimensions, is_visible)
	new_area.FEAGI_change_coordinates_3D(coordinates_3D)
	if is_coordinate_2D_defined:
		new_area.FEAGI_change_coordinates_2D(coordinates_2D)
	new_area.FEAGI_apply_detail_dictionary(FEAGI_details)
	_available_cortical_areas[cortical_ID] = new_area
	print("FEAGI CACHE: Added output cortical area %s" % cortical_ID)
	cortical_area_added.emit(new_area)

## Adds a cortical area of type memory by ID and emits a signal that this was done. Should only be called from FEAGI!
func FEAGI_add_memory_cortical_area(cortical_ID: StringName, cortical_name: StringName, coordinates_3D: Vector3i, dimensions: Vector3i, is_coordinate_2D_defined: bool, coordinates_2D: Vector2i, brain_region: BrainRegion, FEAGI_details: Dictionary = {}, is_visible: bool = true) -> void:
	var new_area: MemoryCorticalArea = MemoryCorticalArea.new(cortical_ID, cortical_name, dimensions, brain_region, is_visible)
	new_area.FEAGI_change_coordinates_3D(coordinates_3D)
	if is_coordinate_2D_defined:
		new_area.FEAGI_change_coordinates_2D(coordinates_2D)
	new_area.FEAGI_apply_detail_dictionary(FEAGI_details)
	_available_cortical_areas[cortical_ID] = new_area
	print("FEAGI CACHE: Added memory cortical area %s" % cortical_ID)
	cortical_area_added.emit(new_area)

## Adds a cortical area as per the FEAGI dictionary. Skips over any templates for IPU and OPU and directly creates the object
func FEAGI_add_cortical_area_from_dict(feagi_dictionary: Dictionary, brain_region: BrainRegion, override_cortical_ID: StringName = "") -> void:
	if override_cortical_ID != &"":
		# Some dictionary responses do not include the ID. This allows adding it if that is the case
		feagi_dictionary["cortical_id"] = override_cortical_ID
	var type: AbstractCorticalArea.CORTICAL_AREA_TYPE = AbstractCorticalArea.cortical_type_str_to_type(feagi_dictionary["cortical_group"])
	var subtype: StringName = feagi_dictionary["cortical_sub_group"]
	if type == AbstractCorticalArea.CORTICAL_AREA_TYPE.CUSTOM and subtype == "MEMORY":
		type = AbstractCorticalArea.CORTICAL_AREA_TYPE.MEMORY
	var cortical_ID: StringName = feagi_dictionary["cortical_id"]
	var name: StringName = feagi_dictionary["cortical_name"]
	var visibility: bool = true
	if "visible" in feagi_dictionary.keys():
		visibility = feagi_dictionary["visible"]
	var dimensions: Vector3i = FEAGIUtils.array_to_vector3i(feagi_dictionary["cortical_dimensions"])
	var position_3D: Vector3i = FEAGIUtils.array_to_vector3i(feagi_dictionary["coordinates_3d"])
	var position_2D: Vector2i = Vector2i(0,0)
	var position_2D_defined: bool = false
	if "coordinates_2d" in feagi_dictionary.keys():
		position_2D_defined = feagi_dictionary["coordinates_2d"][0] != null
		if position_2D_defined:
			position_2D =  FEAGIUtils.array_to_vector2i(feagi_dictionary["coordinates_2d"])

	match type:
		AbstractCorticalArea.CORTICAL_AREA_TYPE.CORE:
			FEAGI_add_core_cortical_area(cortical_ID, name, position_3D, dimensions, position_2D_defined, position_2D, brain_region, feagi_dictionary, visibility)
		AbstractCorticalArea.CORTICAL_AREA_TYPE.CUSTOM:
			FEAGI_add_custom_cortical_area(cortical_ID, name, position_3D, dimensions, position_2D_defined, position_2D, brain_region, feagi_dictionary, visibility)
		AbstractCorticalArea.CORTICAL_AREA_TYPE.IPU:
			if !brain_region.is_root_region():
				push_warning("FEAGI CACHE: Cannot create an IPU in a non root region! This will be ignored and location be set as the root region!")
			FEAGI_add_input_cortical_area_without_template(cortical_ID, name, position_3D, dimensions, position_2D_defined, position_2D, feagi_dictionary, visibility)
		AbstractCorticalArea.CORTICAL_AREA_TYPE.OPU:
			if !brain_region.is_root_region():
				push_warning("FEAGI CACHE: Cannot create an OPU in a non root region! This will be ignored and location be set as the root region!")
			FEAGI_add_output_cortical_area_without_template(cortical_ID, name, position_3D, dimensions, position_2D_defined, position_2D, feagi_dictionary, visibility)
		AbstractCorticalArea.CORTICAL_AREA_TYPE.MEMORY:
			FEAGI_add_memory_cortical_area(cortical_ID, name, position_3D, dimensions, position_2D_defined, position_2D, brain_region, feagi_dictionary, visibility)
		_:
			push_error("FEAGI CACHE: Unable to spawn cortical area of unknown type! Skipping!")

## Updates a cortical area by ID and emits a signal that this was done. Should only be called from FEAGI!
func FEAGI_update_cortical_area_from_dict(all_cortical_area_properties: Dictionary) -> void:
	if "cortical_id" not in all_cortical_area_properties.keys():
		push_error("No Cortical Area ID defined in input Dict to update! Skipping!")
		return
	
	if all_cortical_area_properties["cortical_id"] not in _available_cortical_areas.keys():
		push_error("No Cortical Area by ID of %s to update! Skipping!" % all_cortical_area_properties["cortical_id"])
		return
	
	var changing_ID: StringName = all_cortical_area_properties["cortical_id"]
	print("FEAGI CACHE: Updating cortical area %s" % changing_ID)
	
	_available_cortical_areas[changing_ID].FEAGI_apply_full_dictionary(all_cortical_area_properties)
	cortical_area_mass_updated.emit(_available_cortical_areas[changing_ID])

## Removes a cortical area by ID and emits a signal that this was done. Should only be called from FEAGI!
func remove_cortical_area(removed_cortical_ID: StringName) -> void:
	if removed_cortical_ID not in _available_cortical_areas.keys():
		push_error("Attempted to remove cortical area " + removed_cortical_ID + " when already non existant in cache")
		return
	_available_cortical_areas[removed_cortical_ID].FEAGI_delete_cortical_area()
	cortical_area_about_to_be_removed.emit(_available_cortical_areas[removed_cortical_ID])
	print("FEAGI CACHE: Removing cortical area %s" % removed_cortical_ID)
	_available_cortical_areas.erase(removed_cortical_ID)
	
#endregion

#region Mass Operations

## Called by [FEAGICLocalCache] upon reloading genome
func FEAGI_load_all_cortical_areas(area_summary_data: Dictionary, area_ID_to_region_ID_mapping : Dictionary) -> void:
	for cortical_area_ID in area_summary_data.keys():
		var area_JSON_summary: Dictionary = area_summary_data[cortical_area_ID]
		var area_parent_region_ID: StringName
		if cortical_area_ID in area_ID_to_region_ID_mapping.keys():
			area_parent_region_ID = area_ID_to_region_ID_mapping[cortical_area_ID]
		else:
			push_error("CORE CACHE: Unknown parent region ID for area %s! Defaulting to root region ID!" % cortical_area_ID)
			area_parent_region_ID = BrainRegion.ROOT_REGION_ID
		if !(area_parent_region_ID in FeagiCore.feagi_local_cache.brain_regions.available_brain_regions):
			push_error("CORE CACHE: Unknown parent region %s for area %s! Skipping creating this cortical area!" % [area_parent_region_ID, cortical_area_ID] )
			continue
		var area_parent_region: BrainRegion = FeagiCore.feagi_local_cache.brain_regions.available_brain_regions[area_parent_region_ID]
		FEAGI_add_cortical_area_from_dict(area_JSON_summary, area_parent_region, cortical_area_ID)


## Applies mass update of 2d locations to cortical areas. Only call from FEAGI
func FEAGI_mass_update_2D_positions(IDs_to_locations: Dictionary) -> void:
	for cortical in IDs_to_locations.keys():
		if cortical == null:
			push_error("Unable to update position of %s null cortical area!")
			continue
		if !(cortical.cortical_ID in _available_cortical_areas.keys()):
			push_error("Unable to update position of %s due to this cortical area missing in cache" % cortical.cortical_ID)
			continue
		cortical.coordinates_2D = IDs_to_locations[cortical]

## Removes all cached cortical areas (and their connections). Should only be called during a reset
func FEAGI_hard_wipe_available_cortical_areas():
	print("CACHE: Wiping cortical areas")
	for cortical_ID in _available_cortical_areas:
		var area: AbstractCorticalArea = _available_cortical_areas[cortical_ID]
		area.FEAGI_delete_cortical_area()
		cortical_area_about_to_be_removed.emit(area)
	_available_cortical_areas = {}
	print("CACHE: Wiping cortical areas and connection wipe complete!")

## Sets all cortical areas in the list as visible, and all those not as not visible (in terms of activity rendering)
func FEAGI_set_invisible_cortical_areas(invisible_areas: Array[AbstractCorticalArea]) -> void:
	var cached_areas: Array[AbstractCorticalArea] = []
	cached_areas.assign(_available_cortical_areas.values())
	for area in cached_areas:
		area.FEAGI_set_cortical_visibility(!(area in invisible_areas))

	
#endregion

#region Queries

## Returns an array of cortical areas whose name contains a given substring
## WARNING: Do NOT use this for backend data operations, this is better suited for UI name filtering operations
func search_for_available_cortical_areas_by_name(search_term: StringName) -> Array[AbstractCorticalArea]:
	var lowercase_search: StringName = search_term.to_lower()
	var output: Array[AbstractCorticalArea] = []
	for cortical_area in _available_cortical_areas.values():
		if cortical_area.name.to_lower().contains(lowercase_search):
			output.append(cortical_area)
	return output

## Returns an array of cortical areas of given cortical type
func search_for_available_cortical_areas_by_type(searching_cortical_type: AbstractCorticalArea.CORTICAL_AREA_TYPE) -> Array[AbstractCorticalArea]:
	var output: Array[AbstractCorticalArea] = []
	for cortical_area in _available_cortical_areas.values():
		if cortical_area.cortical_type == searching_cortical_type:
			output.append(cortical_area)
	return output

## Returns an array of all the names of the cortical areas
func get_all_cortical_area_names() -> Array[StringName]:
	var output: Array[StringName] = []
	for cortical_area in _available_cortical_areas.values():
		output.append(cortical_area.cortical_ID)
	return output

## Returns true if a cortical area exists with a given name (NOT ID)
func exist_cortical_area_of_name(searching_name: StringName) -> bool:
	for cortical_area in _available_cortical_areas.values():
		if cortical_area.friendly_name.to_lower() == searching_name.to_lower():
			return true
	return false
#endregion

## Given an array of IDs, return the array of [AbstractCorticalArea] objects
func arr_of_IDs_to_arr_of_area(IDs: Array[StringName]) -> Array[AbstractCorticalArea]:
	var output: Array[AbstractCorticalArea] = []
	for ID in IDs:
		if !(ID in _available_cortical_areas.keys()):
			push_error("CORE CACHE: Unable to find cortical of ID %s! Skipping!" % ID)
			continue
		output.append(_available_cortical_areas[ID])
	return output

## Returns the [AbstractCorticalArea] if the given ID exists, otherwise returns null
func try_to_get_cortical_area_by_ID(ID: StringName) -> AbstractCorticalArea:
	if ID in _available_cortical_areas:
		return _available_cortical_areas[ID]
	else:
		return null

func invert_selecteion(selected: Array[AbstractCorticalArea]) -> Array[AbstractCorticalArea]:
	var output: Array[AbstractCorticalArea]
	output.assign(_available_cortical_areas.values())
	var search: int
	while len(selected) > 0:
		search = output.find(selected.pop_front())
		if search != -1:
			output.remove_at(search)
	return output

#region Internal




#endregion
