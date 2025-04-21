extends UI_BrainMonitor_AbstractInteractableVolumeRenderer
class_name UI_BrainMonitor_AbstractCorticalAreaRenderer
## Base class for all rendering methods for cortical areas. Essentially just a fancy interface


#NOTE All neuron selection / mouse events go up via signals, which will then call functions here to set highlighting to ensure predictable states!

@export var cortical_area_outline_mouse_over_color: Color = Color.AQUA
@export var cortical_area_outline_mouse_over_alpha: float = 0.2
@export var cortical_area_outline_select_color: Color = Color.ALICE_BLUE
@export var cortical_area_outline_select_alpha: float = 0.3
@export var cortical_area_outline_both_color: Color = Color.WHITE_SMOKE
@export var cortical_area_outline_both_alpha: float = 0.4

func setup(area: AbstractCorticalArea) -> void:
	assert(false, "Not Implemented!")

func update_friendly_name(new_name: String) -> void:
	assert(false, "Not Implemented!")

func set_cortical_area_mouse_over_highlighting(is_highlighted: bool) -> void:
	assert(false, "Not Implemented!")

func set_cortical_area_selection(is_selected: bool) -> void:
	assert(false, "Not Implemented!")

func set_highlighted_neurons(neuron_coordinates: Array[Vector3i]) -> void:
	assert(false, "Not Implemented!")
	
func set_neuron_selections(neuron_coordinates: Array[Vector3i]) -> void:
	assert(false, "Not Implemented!")

func clear_all_neuron_highlighting() -> void:
	assert(false, "Not Implemented!")

func clear_all_neuron_selection() -> void:
	assert(false, "Not Implemented!")

func update_visualization_data(visualization_data: PackedByteArray) -> void: # NOTE: The data is an SVO TODO document this!
	assert(false, "Not Implemented!")

func does_world_position_map_to_neuron_coordinate(world_position: Vector3) -> bool:
	assert(false, "Not Implemented!")
	return false

## Helper function that converts a world coordinate to neuron coordinate
func world_godot_position_to_neuron_coordinate(world_position: Vector3) -> Vector3i:
	assert(false, "Not Implemented!")
	return Vector3i(-1,-1,-1)

func get_parent_BM_abstraction() -> UI_BrainMonitor_CorticalArea:
	var output: UI_BrainMonitor_CorticalArea = get_parent() as UI_BrainMonitor_CorticalArea
	return output # returns null if something is wrong, but never should!
