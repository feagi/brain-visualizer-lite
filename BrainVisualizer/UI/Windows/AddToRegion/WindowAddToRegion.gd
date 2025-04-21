extends BaseDraggableWindow
class_name WindowAddToRegion

const WINDOW_NAME: StringName = "add_to_region"

var _region_to_move_to: BrainRegion = null
var _objects_adding: Array[GenomeObject]
var _explorer: ScrollGenomeObjectSelector
var _region_label: Label
var _select: Button

func _ready():
	super()
	_explorer = _window_internals.get_node("ScrollGenomeObjectSelector")
	_region_label = _window_internals.get_node("Label")
	_select = _window_internals.get_node("HBoxContainer/Select")

func setup(adding: Array[GenomeObject], current_parent: BrainRegion) -> void:
	_setup_base_window(WINDOW_NAME)
	_objects_adding = adding
	var config: SelectGenomeObjectSettings = SelectGenomeObjectSettings.config_for_selecting_new_parent_region(current_parent, _objects_adding)
	_region_label.text = "Current Parent is Region " + current_parent.friendly_name
	_explorer.setup_from_starting_region(config)
	

func _region_selected(object: GenomeObject) -> void:
	if !object is BrainRegion:
		return
	
	var region: BrainRegion = (object as BrainRegion)
	_region_to_move_to = region
	_region_label.text = "Selected " + region.friendly_name +" as the move destination"
	_select.disabled = false

func _add_region_pressed() -> void:
	var top_region: BrainRegion
	if len(_objects_adding) > 0:
		top_region = _objects_adding[0].current_parent_region
	else:
		top_region = FeagiCore.feagi_local_cache.brain_regions.get_root_region()
	BV.WM.spawn_create_region(top_region , _objects_adding)
	close_window()

func _move_pressed() -> void:
	FeagiCore.requests.move_objects_to_region(_region_to_move_to, _objects_adding)
	close_window()
