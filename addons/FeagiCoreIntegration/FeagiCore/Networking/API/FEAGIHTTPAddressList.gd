extends RefCounted
class_name FEAGIHTTPAddressList
## Essentially a list of endpoints to FEAGI

# Get Requests
var GET_corticalAreas_ipu: StringName = "/v1/cortical_area/ipu"
var GET_corticalAreas_opu: StringName = "/v1/cortical_area/opu"
var GET_corticalAreas_corticalAreaIDList: StringName = "/v1/cortical_area/cortical_area_id_list"
var GET_neuronMorphologies_morphologyList: StringName = "/v1/morphology/morphology_list"
var GET_genome_fileName: StringName = "/v1/genome/file_name"
var GET_corticalAreas_corticalAreaNameList: StringName = "/v1/cortical_area/cortical_area_name_list"
var POST_corticalAreas_corticalNameLocation: StringName = "/v1/cortical_area/cortical_name_location"
var POST_corticalArea_corticalAreaProperties: StringName = "/v1/cortical_area/cortical_area_properties"
var GET_corticalArea_corticalMapDetailed: StringName = "/v1/cortical_area/cortical_map_detailed"
var POST_corticalMappings_afferents: StringName = "/v1/cortical_mapping/afferents"
var POST_corticalMappings_efferents: StringName = "/v1/cortical_mapping/efferents"
var POST_corticalMappings_mappingProperties: StringName = "/v1/cortical_mapping/mapping_properties"
var GET_genome_circuits: StringName = "/v1/genome/circuits"
var GET_morphology_morphology_types: StringName = "/v1/morphology/morphology_types"
var POST_morphology_morphologyProperties: StringName = "/v1/morphology/morphology_properties"
var POST_morphology_morphologyUsage: StringName = "/v1/morphology/morphology_usage"
var GET_corticalArea_corticalIDNameMapping: StringName = '/v1/cortical_area/cortical_id_name_mapping'
var GET_corticalArea_corticalLocations2D: StringName = '/v1/cortical_area/cortical_locations_2d'
var GET_corticalArea_corticalArea_geometry: StringName = '/v1/cortical_area/cortical_area/geometry'
var GET_corticalArea_corticalTypes: StringName = "/v1/cortical_area/cortical_types"
var GET_connectome_properties_dimensions: StringName = "/v1/connectome/properties/dimensions"
var GET_connectome_properties_mappings: StringName = "/v1/connectome/properties/mappings"
var GET_connectome_corticalAreas_list_detailed: StringName = "/v1/connectome/cortical_areas/list/detailed"
var GET_burstEngine_stimulationPeriod: StringName = "/v1/burst_engine/stimulation_period"
var GET_system_healthCheck: StringName = "/v1/system/health_check"
var POST_insight_neurons_membranePotentialStatus: StringName = '/v1/insight/neurons/membrane_potential_status'
var POST_insight_neuron_synapticPotentialStatus: StringName = '/v1/insight/neuron/synaptic_potential_status'
var GET_morphology_list_types: StringName = '/v1/morphology/list/types'
var GET_morphology_morphologies: StringName = '/v1/morphology/morphologies'
var GET_region_regionsMembers: StringName = '/v1/region/regions_members'
var GET_corticalArea_corticalVisibility: StringName = '/v1/cortical_area/cortical_visibility'
var GET_system_corticalAreaVisualizationSkipRate: StringName = "/v1/system/cortical_area_visualization_skip_rate"
var GET_system_corticalAreaVisualizationSupressionThreshold: StringName = "/v1/system/cortical_area_visualization_suppression_threshold"
var GET_neuroplasticity_plasticityQueueDepth: StringName = "/v1/neuroplasticity/plasticity_queue_depth"
var GET_agent_list: StringName = "/v1/agent/list"
var GET_agent_properties: StringName = "/v1/agent/properties"
var GET_input_vision: StringName = "/v1/input/vision"

# Post Requests
var POST_feagi_burstEngine: StringName = "/v1/burst_engine/stimulation_period"
var POST_genome_corticalArea: StringName = "/v1/cortical_area/cortical_area"
var POST_genome_customCorticalArea: StringName = "/v1/cortical_area/custom_cortical_area"
var POST_genome_morphology: StringName = "/v1/morphology/morphology"
var POST_genome_append: StringName = "/v1/feagi/genome/append"
var POST_genome_amalgamationDestination: StringName = "/v1/genome/amalgamation_destination"
var POST_monitoring_neuron_membranePotential_set: StringName = "/v1/insight/neurons/membrane_potential_set"
var POST_monitoring_neuron_synapticPotential_set: StringName = "/v1/insight/neuron/synaptic_potential_set"
var POST_region_region: StringName = "/v1/region/region"
var POST_corticalArea_multi_corticalAreaProperties: StringName = "/v1/cortical_area/multi/cortical_area_properties"
var POST_input_vision: StringName = "/v1/input/vision"

# Put Requests
var PUT_genome_corticalArea: StringName = "/v1/cortical_area/cortical_area"
var PUT_genome_mappingProperties: StringName = "/v1/cortical_mapping/mapping_properties"
var PUT_genome_morphology: StringName = "/v1/morphology/morphology"
var PUT_genome_coord2d: StringName = "/v1/cortical_area/coord_2d"
var PUT_genome_relocate_members: StringName = "/v1/region/relocate_members"
var PUT_region_region: StringName = "/v1/region/region"
var PUT_region_relocateMembers: StringName = "/v1/region/relocate_members"
var PUT_corticalArea_suppressCorticalVisibility: StringName = "/v1/cortical_area/suppress_cortical_visibility"
var PUT_corticalArea_multi_corticalArea: StringName = "/v1/cortical_area/multi/cortical_area"
var PUT_system_corticalAreaVisualizationSkipRate: StringName = "/v1/system/cortical_area_visualization_skip_rate"
var PUT_system_corticalAreaVisualizationSupressionThreshold: StringName = "v1/system/cortical_area_visualization_suppression_threshold"
var PUT_neuroplasticity_plasticityQueueDepth: StringName = "/v1/neuroplasticity/plasticity_queue_depth"
var PUT_corticalArea_reset: StringName = "/v1/cortical_area/reset"

# Delete Requests
var DELETE_GE_corticalArea: StringName = "/v1/cortical_area/cortical_area"
var DELETE_GE_morphology: StringName = "/v1/morphology/morphology"
var DELETE_GE_amalgamationCancellation: StringName = "/v1/genome/amalgamation_cancellation"
var DELETE_region_region: StringName = "/v1/region/region"
var DELETE_region_regionAndMembers: StringName = "/v1/region/region_and_members"
var DELETE_corticalArea_multi_corticalArea: StringName = "/v1/cortical_area/multi/cortical_area"

func _init(FEAGIFullAddress: StringName) -> void:
	# Preappend the FEAGIFullAddress to each string above
	var properties: Array[Dictionary] = get_property_list()
	for prop: Dictionary in properties:
		if prop["type"] == TYPE_STRING_NAME:
			set(prop["name"], FEAGIFullAddress + get(prop["name"]))
