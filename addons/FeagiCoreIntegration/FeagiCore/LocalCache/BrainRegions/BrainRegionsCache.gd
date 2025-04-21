extends RefCounted
class_name BrainRegionsCache
## Holds a local copy of all [BrainRegion]s

signal region_added(region: BrainRegion)
signal region_about_to_be_removed(region: BrainRegion)

var available_brain_regions: Dictionary:
	get: return _available_brain_regions

var _available_brain_regions: Dictionary = {}

## Calls from FEAGI to update the cache
#region FEAGI Interactions

## Called by [FEAGILocalCache] on genome load. Loads in all regions from FEAGI summary data to cache. Also creates a mapping table to add cortical areas in a later step of genome loading
func FEAGI_load_all_regions_and_establish_relations_and_calculate_area_region_mapping(region_summary_data: Dictionary) -> Dictionary: # This function name clearly isn't long enough
	
	# First pass is to generate all the region objects without any children
	for region_ID: StringName in region_summary_data.keys():
		_available_brain_regions[region_ID] = BrainRegion.from_FEAGI_JSON_ignore_children(region_summary_data[region_ID], region_ID)
	
	var cortical_area_mapping: Dictionary = {}
	# Second pass is to link all child region to a given parent region, and to calculate mappings for cortical IDs to their correct parent region
	for parent_region_ID: StringName in region_summary_data.keys():
		var parent_region: BrainRegion = _available_brain_regions[parent_region_ID]
		# link child regions
		var child_region_IDs: Array[StringName] = []
		child_region_IDs.assign(region_summary_data[parent_region_ID]["regions"])
		var child_regions: Array[BrainRegion] = arr_of_region_IDs_to_arr_of_Regions(child_region_IDs)
		for child_region in child_regions:
			child_region.FEAGI_init_parent_relation(parent_region)
		
		# Create cortical ID mapping (but don't add cortical areas yet)
		var cortical_IDs: Array[StringName] = []
		cortical_IDs.assign(region_summary_data[parent_region_ID]["areas"])
		for cortical_ID in cortical_IDs:
			if cortical_ID in cortical_area_mapping.keys():
				push_error("CORE CACHE: Cortical Area %s previously reported in region %s is now reported in region %s! Something is wrong with the genome! Keeping the original region!" % [cortical_ID, cortical_area_mapping[cortical_ID], parent_region_ID])
				continue
			cortical_area_mapping[cortical_ID] = parent_region_ID
	
	
	
	return cortical_area_mapping

func FEAGI_load_all_partial_mapping_sets(region_summary_data: Dictionary) -> void:
	var region_dict: Dictionary
	var arr_IO: Array[Dictionary]
	var region: BrainRegion
	for region_ID in region_summary_data:
		region_dict = region_summary_data[region_ID]
		if region_dict.has("inputs"):
			if !(region_ID in _available_brain_regions):
				push_error("CORE CACHE: Unable to find region %s to add partial mapping set to!")
				continue
			region = _available_brain_regions[region_ID]
			arr_IO = []
			arr_IO.assign(region_dict["inputs"])
			region.FEAGI_establish_partial_mappings_from_JSONs(arr_IO, true)
		if region_dict.has("outputs"):
			if !(region_ID in _available_brain_regions):
				push_error("CORE CACHE: Unable to find region %s to add partial mapping set to!")
				continue
			region = _available_brain_regions[region_ID]
			arr_IO = []
			arr_IO.assign(region_dict["outputs"])
			region.FEAGI_establish_partial_mappings_from_JSONs(arr_IO, false)
			

### Clears all regions from the cache
#func FEAGI_clear_all_regions() -> void:
#	for region_ID: StringName in _available_brain_regions.keys():
#		FEAGI_remove_region_and_internals(region_ID)

func FEAGI_add_region(region_ID: StringName, parent_region: BrainRegion, region_name: StringName, coord_2D: Vector2i, coord_3D: Vector3i, contained_objects: Array[GenomeObject] = []) -> void:
	if region_ID in _available_brain_regions.keys():
		push_error("CORE CACHE: Unable to add another region of the ID %s!" % region_ID)
		return
	var region: BrainRegion = BrainRegion.new(region_ID, region_name, coord_2D, coord_3D)
	region.FEAGI_init_parent_relation(parent_region)
	_available_brain_regions[region_ID] = region
	for object in contained_objects:
		object.FEAGI_change_parent_brain_region(region)
	region_added.emit(region)

func FEAGI_edit_region(editing_region: BrainRegion, title: StringName, _description: StringName, new_parent_region: BrainRegion, position_2D: Vector2i, position_3D: Vector3i) -> void:
	if !(editing_region.region_ID in _available_brain_regions.keys()):
		push_error("CORE CACHE: Unable to edit noncached region of the ID %s!" % editing_region.region_ID)
		return
	editing_region.FEAGI_edited_region(title, _description, new_parent_region, position_2D, position_3D)

## Applies mass update of 2d locations to cortical areas. Only call from FEAGI
func FEAGI_mass_update_2D_positions(IDs_to_locations: Dictionary) -> void:
	for region in IDs_to_locations.keys():
		if region == null:
			push_error("Unable to update position of %s null bnrain region!")
			continue
		if !(region.region_ID in _available_brain_regions.keys()):
			push_error("Unable to update position of %s due to this brain region missing in cache" % region.cortical_ID)
			continue
		region.FEAGI_change_coordinates_2D(IDs_to_locations[region])

#NOT COMPLETE #TODO
#func FEAGI_remove_region_and_internals(region_ID: StringName) -> void:
#	if !(region_ID in _available_brain_regions.keys()):
#		push_error("CORE CACHE: Unable to find region %s to delete! Skipping!" % region_ID)
#	var region: BrainRegion = _available_brain_regions[region_ID]
#	
#	region.FEAGI_delete_this_region()
#	region_about_to_be_removed.emit(region)
#	_available_brain_regions.erase(region_ID)

## FEAGI states that a region is to be removed and internals raised
func FEAGI_remove_region_and_raise_internals(region: BrainRegion) -> void:
	var contained_objects: Array[GenomeObject] = []
	var new_parent: BrainRegion = region.current_parent_region
	for object: GenomeObject in region.get_all_included_genome_objects():
		object.FEAGI_change_parent_brain_region(new_parent)
	region_about_to_be_removed.emit(region)
	region.FEAGI_delete_this_region()
	_available_brain_regions.erase(region.region_ID)

#endregion


## Get information about the cache state
#region Queries

## Returns True if the root region is in the cache
func is_root_available() -> bool:
	return BrainRegion.ROOT_REGION_ID in _available_brain_regions.keys()


## Attempts to return the root [BrainRegion]. If it fails, logs an error and returns null
func get_root_region() -> BrainRegion:
	if !(BrainRegion.ROOT_REGION_ID in _available_brain_regions.keys()):
		push_error("CORE CACHE: Unable to find root region! Something is wrong!")
		return null
	return _available_brain_regions[BrainRegion.ROOT_REGION_ID]

## Gets the path of regions that holds the common demoninator path between 2 regions
## Example: if region e is in region path [a,b,e] and region d is in path [a,b,c,d], this will return [a,b]
func get_common_path_containing_both_regions(A: BrainRegion, B: BrainRegion) -> Array[BrainRegion]:
	var path_A: Array[BrainRegion] = A.get_path()
	var path_B: Array[BrainRegion] = B.get_path()
	
	if len(path_A) == 0 or len(path_B) == 0:
		push_error("CORE CACHE: Unable to calculate lowest similar region path between %s and %s!" % [A.region_ID, B.region_ID])
		return []
	
	var search_depth: int
	var path: Array[BrainRegion] = []
	# Stop at shorter path distance
	if len(path_A) > len(path_B):
		search_depth = len(path_B)
	else:
		search_depth = len(path_A)
	
	for i in search_depth:
		if path_A[i].region_ID != path_B[i].region_ID:
			return path
		path.append(path_A[i])
	
	# no further to go, return the path
	return path

## Defines the directional path with 2 arrays (upward then downward) of the regions to transverse to get from the source to the destination
## Example given region layout {R{a,b{c,d{e}},f{g{h}}}, going from d -> g will return [[d,b,R],[R,f,g]]
func get_directional_path_between_regions(source: BrainRegion, destination: BrainRegion) -> Array[Array]:
	var common_path: Array[BrainRegion] = get_common_path_containing_both_regions(source, destination)
	if len(common_path) == 0:
		push_error("CORE CACHE: Unable to calculate directional path between %s toward %s!" % [source.region_ID, destination.region_ID])
	var lowest_common_region: BrainRegion = common_path.back()

	
	var source_path_reversed: Array[BrainRegion] = source.get_path()
	source_path_reversed.reverse()
	var index: int = source_path_reversed.find(lowest_common_region)
	var upward_path: Array[BrainRegion] = source_path_reversed.slice(0, index)
	
	var destination_path: Array[BrainRegion] = destination.get_path()
	index = destination_path.find(lowest_common_region)
	var downward_path: Array[BrainRegion]  = destination_path.slice(index + 1, len(destination_path))
	
	return [upward_path, downward_path]

## Convert an array of region IDs to an array of [BrainRegion] from cache
func arr_of_region_IDs_to_arr_of_Regions(IDs: Array[StringName]) -> Array[BrainRegion]:
	var output: Array[BrainRegion] = []
	for ID in IDs:
		if !(ID in _available_brain_regions.keys()):
			push_error("CORE CACHE: Unable to find region %s! Skipping!" % ID)
			continue
		output.append(_available_brain_regions[ID])
	return output

## As a single flat array, get the end inclusive path from the starting [GenomeObject], to the end [GenomeObject]
func get_total_path_between_objects(starting_point: GenomeObject, stoppping_point: GenomeObject) -> Array[GenomeObject]:
	# Get start / stop points
	var is_start_cortical_area: bool = starting_point is AbstractCorticalArea
	var is_end_cortical_area: bool = stoppping_point is AbstractCorticalArea
	
	var start_region: BrainRegion
	if is_start_cortical_area:
		start_region = (starting_point as AbstractCorticalArea).current_parent_region
	else:
		start_region = starting_point
	var end_region: BrainRegion
	if is_end_cortical_area:
		end_region = (stoppping_point as AbstractCorticalArea).current_parent_region
	else:
		end_region = stoppping_point
	
	# Generate total path
	var region_path: Array[Array] = FeagiCore.feagi_local_cache.brain_regions.get_directional_path_between_regions(start_region, end_region)
	var total_chain_path: Array[GenomeObject] = []
	#if is_start_cortical_area:
	#	total_chain_path.append(starting_point)
	total_chain_path.append(starting_point)
	total_chain_path.append_array(region_path[0])  # ascending
	total_chain_path.append_array(region_path[1])  # decending
	#if is_end_cortical_area:
	#	total_chain_path.append(stoppping_point)
	total_chain_path.append(stoppping_point)
	return total_chain_path

#endregion
