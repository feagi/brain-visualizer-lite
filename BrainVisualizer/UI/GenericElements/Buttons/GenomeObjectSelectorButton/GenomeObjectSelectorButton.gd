extends PanelContainerButton
class_name GenomeObjectSelectorButton

signal object_selected(object: GenomeObject)

var current_selected: GenomeObject:
	get: return _current_selected

var _current_selected: GenomeObject
var _selection_allowed: GenomeObject.SINGLE_MAKEUP
var _explorer_start_region: BrainRegion
var _cortical_icon: TextureRect
var _region_icon: TextureRect
var _text: Label

func _ready() -> void:
	super()
	_cortical_icon = $MarginContainer/HBoxContainer/IconCortical
	_region_icon = $MarginContainer/HBoxContainer/IconRegion
	_text = $MarginContainer/HBoxContainer/Label

#NOTE: Yes you can init with a type not allowed for the user to select
func setup(genome_object: GenomeObject, restricted_to: GenomeObject.SINGLE_MAKEUP, custom_region_to_start_explorer_at: BrainRegion = null) -> void:
	_selection_allowed = restricted_to
	_current_selected = genome_object
	if custom_region_to_start_explorer_at != null:
		_explorer_start_region = custom_region_to_start_explorer_at
	else:
		_explorer_start_region = FeagiCore.feagi_local_cache.brain_regions.get_root_region()
	_switch_button_visuals(genome_object)
	pressed.connect(_button_pressed)

func update_selection_with_signal(genome_object: GenomeObject) -> void:
	if !GenomeObject.is_given_object_covered_by_makeup(genome_object, _selection_allowed):
		push_error("UI: Invalid GenomeObject type selected for button given restriction! Ignoring!")
		return
	update_selection_no_signal(genome_object)
	object_selected.emit(_current_selected)

func update_selection_no_signal(genome_object: GenomeObject) -> void:
	if !GenomeObject.is_given_object_covered_by_makeup(genome_object, _selection_allowed):
		push_error("UI: Invalid GenomeObject type selected for button given restriction! Ignoring!")
		return
	_current_selected = genome_object
	_switch_button_visuals(genome_object)

## Change at what region the explorer starts when the button is pressed
func change_starting_exploring_region(start_region: BrainRegion) -> void:
	_explorer_start_region = start_region

func _button_pressed() -> void:
	var config: SelectGenomeObjectSettings
	match(_selection_allowed):
		GenomeObject.SINGLE_MAKEUP.SINGLE_CORTICAL_AREA:
			var current_area: AbstractCorticalArea = null
			if _current_selected is AbstractCorticalArea:
				current_area = _current_selected as AbstractCorticalArea
			config = SelectGenomeObjectSettings.config_for_single_cortical_area_selection(_explorer_start_region, current_area)
		
		GenomeObject.SINGLE_MAKEUP.SINGLE_BRAIN_REGION:
			var current_region: BrainRegion = null
			if _current_selected is BrainRegion:
				current_region = _current_selected as BrainRegion
			config = SelectGenomeObjectSettings.config_for_single_brain_region_selection(_explorer_start_region, current_region)
			
		_:
			config = SelectGenomeObjectSettings.config_for_selecting_anything(_explorer_start_region)
	var window: WindowSelectGenomeObject = BV.WM.spawn_select_genome_object(config)
	window.final_selection.connect(_update_selection)

func _switch_button_visuals(selected: GenomeObject) -> void:
	var type: GenomeObject.SINGLE_MAKEUP = GenomeObject.get_makeup_of_single_object(selected)
	_cortical_icon.visible = type == GenomeObject.SINGLE_MAKEUP.SINGLE_CORTICAL_AREA
	_region_icon.visible = type == GenomeObject.SINGLE_MAKEUP.SINGLE_BRAIN_REGION
	if type == GenomeObject.SINGLE_MAKEUP.UNKNOWN:
		_text.text = "None Selected"
	else:
		_text.text = selected.friendly_name

func _update_selection(genome_objects: Array[GenomeObject]) -> void:
	if len(genome_objects) == 0:
		return
	if len(genome_objects) > 1:
		push_error("UI: More than 1 genome object was somehow selected for the GenomeObjectSelectorButton! Using the first and discarding the rest!")
	update_selection_no_signal(genome_objects[0])
	object_selected.emit(_current_selected)
