extends BaseDraggableWindow
class_name WindowQuickConnect

const WINDOW_NAME: StringName = "quick_connect"

enum POSSIBLE_STATES {
	SOURCE,
	DESTINATION,
	MORPHOLOGY,
	EDIT_MORPHOLOGY,
	IDLE
}


#@export var style_incomplete: StyleBoxFlat
#@export var style_waiting: StyleBoxFlat
#@export var style_complete: StyleBoxFlat

var current_state: POSSIBLE_STATES:
	get: return _current_state
	set(v):
		_update_current_state(v)

var _step1_panel: PanelContainer
var _step2_panel: PanelContainer
var _step3_panel: PanelContainer
var _step1_button: TextureButton
var _step2_button: TextureButton
var _step3_button: TextureButton
var _step1_label: Label
var _step2_label: Label
var _step3_label: Label
var _step3_scroll: MorphologyScroll
var _step3_morphology_container: PanelContainer
var _step3_morphology_view: UIMorphologyDefinition
var _step3_morphology_details: MorphologyGenericDetails
var _step4_button: Button

var _current_state: POSSIBLE_STATES = POSSIBLE_STATES.IDLE
var _finished_selecting: bool = false

var _source: AbstractCorticalArea = null
var _destination: AbstractCorticalArea = null
var _selected_morphology: BaseMorphology = null

func _ready() -> void:
	super()
	_step1_panel = _window_internals.get_node("step1")
	_step2_panel = _window_internals.get_node("step2")
	_step3_panel = _window_internals.get_node("step3")
	_step1_button = _window_internals.get_node("step1/step1/TextureButton")
	_step2_button = _window_internals.get_node("step2/step2/TextureButton")
	_step3_button = _window_internals.get_node("step3/step3/TextureButton")
	_step1_label = _window_internals.get_node("step1/step1/Label")
	_step2_label = _window_internals.get_node("step2/step2/Label")
	_step3_label = _window_internals.get_node("step3/step3/Label")
	_step3_morphology_container = _window_internals.get_node("MorphologyInfoContainer")
	_step3_scroll = _window_internals.get_node("MorphologyInfoContainer/MorphologyInfo/MorphologyScroll")
	_step3_morphology_view = _window_internals.get_node("MorphologyInfoContainer/MorphologyInfo/SmartMorphologyView")
	_step3_morphology_details = _window_internals.get_node("MorphologyInfoContainer/MorphologyInfo/MorphologyGenericDetails")
	_step4_button = _window_internals.get_node("Establish")
	
	
	BV.UI.selection_system.add_override_usecase(SelectionSystem.OVERRIDE_USECASE.QUICK_CONNECT)
	BV.UI.selection_system.objects_selection_event_called.connect(_on_user_selection)
	
	
	_step1_panel.theme_type_variation = "PanelContainer_QC_incomplete"
	_step2_panel.theme_type_variation = "PanelContainer_QC_incomplete"
	_step3_panel.theme_type_variation = "PanelContainer_QC_incomplete"
	current_state = POSSIBLE_STATES.SOURCE

func setup(cortical_source_if_picked: AbstractCorticalArea) -> void:
	_setup_base_window(WINDOW_NAME)
	if cortical_source_if_picked != null:
		_set_source(cortical_source_if_picked)

func _on_user_selection(objects: Array[GenomeObject], context: SelectionSystem.SOURCE_CONTEXT, _override_usecases: Array[SelectionSystem.OVERRIDE_USECASE]) -> void:
	if len(objects) != 1:
		return
	if objects[0] is BrainRegion:
		return
	var cortical_area: AbstractCorticalArea = objects[0] as AbstractCorticalArea
	
	match _current_state:
		POSSIBLE_STATES.SOURCE:
			_set_source(cortical_area)
		POSSIBLE_STATES.DESTINATION:
			_set_destination(cortical_area)
		_:
			return

func establish_connection_button():
	print("UI: WINDOW: QUICKCONNECT: User Requesting quick connection...")

	# Make sure the cache has the current mapping state of the cortical to source area to append to
	FeagiCore.requests.append_default_mapping_between_corticals(_source, _destination, _selected_morphology)
	## TODO: This is technically a race condition, if a user clicks through the quick connect fast enough
	close_window()

# State Machine
func _update_current_state(new_state: POSSIBLE_STATES) -> void:
	match new_state:
		POSSIBLE_STATES.SOURCE:
			_toggle_add_buttons(false)
			_step4_button.disabled = true
			_setting_source()

		POSSIBLE_STATES.DESTINATION:
			_toggle_add_buttons(false)
			_step4_button.disabled = true
			_setting_destination()

		POSSIBLE_STATES.MORPHOLOGY:
			_toggle_add_buttons(false)
			_step4_button.disabled = true
			_setting_morphology()
		POSSIBLE_STATES.EDIT_MORPHOLOGY:
			_step3_morphology_container.visible = !_step3_morphology_container.visible
			shrink_window()
		POSSIBLE_STATES.IDLE:
			_toggle_add_buttons(true)
			_step4_button.disabled = false
		_:
			push_error("UI: WINDOWS: WindowQuickConnect in unknown state!")
	
	_current_state = new_state



func _setting_source() -> void:
	print("UI: WINDOW: QUICKCONNECT: User Picking Source Area...")
	_source = null
	_step1_label.text = " Please Select A Source Area..."
	_step1_panel.theme_type_variation = "PanelContainer_QC_waiting"

func _setting_destination() -> void:
	print("UI: WINDOW: QUICKCONNECT: User Picking Destination Area...")
	_destination = null
	_step2_label.text = " Please Select A Destination Area..."
	_step2_panel.theme_type_variation = "PanelContainer_QC_waiting"

func _setting_morphology() -> void:
	print("UI: WINDOW: QUICKCONNECT: User Picking Connectivity Rule...")
	var mapping_defaults: MappingRestrictionDefault = FeagiCore.feagi_local_cache.mapping_restrictions.get_defaults_between_2_cortical_areas(_source, _destination)
	_selected_morphology = null
	_step3_label.text = " Please Select A Morphology..."
	_step3_panel.theme_type_variation = "PanelContainer_QC_waiting"
	if FeagiCore.feagi_local_cache.mapping_restrictions.get_restrictions_between_2_cortical_areas(_source, _destination).has_restricted_morphologies():
		_step3_scroll.set_morphologies(FeagiCore.feagi_local_cache.mapping_restrictions.get_restrictions_between_2_cortical_areas(_source, _destination).get_morphologies_restricted_to())
	if mapping_defaults.try_get_default_morphology() == null:
		return
	_step3_scroll.select_morphology(mapping_defaults.try_get_default_morphology())
	

func _set_source(cortical_area: AbstractCorticalArea) -> void:
	_source = cortical_area
	_step1_label.text = " Selected Source Area: [" + cortical_area.friendly_name + "]"
	_step1_panel.theme_type_variation = "PanelContainer_QC_Complete"
	if !_finished_selecting:
		_step2_panel.visible = true
		current_state = POSSIBLE_STATES.DESTINATION
	else:
		current_state = POSSIBLE_STATES.IDLE


func _set_destination(cortical_area: AbstractCorticalArea) -> void:
	_destination = cortical_area
	_step2_label.text = " Selected Destination Area: [" + cortical_area.friendly_name + "]"
	_step2_panel.theme_type_variation = "PanelContainer_QC_Complete"
	FeagiCore.requests.get_mappings_between_2_cortical_areas(_source.cortical_ID, _destination.cortical_ID)
	if !_finished_selecting:
		_step3_panel.visible = true
		current_state = POSSIBLE_STATES.MORPHOLOGY
		pass
	else:
		current_state = POSSIBLE_STATES.IDLE


func _set_morphology(morphology: BaseMorphology) -> void:
	_selected_morphology = morphology
	_step3_label.text = " Selected Connectivity Rule: " + morphology.name
	_step3_panel.theme_type_variation = "PanelContainer_QC_Complete"
	_step3_morphology_view.load_morphology(morphology)
	_step3_morphology_details.load_morphology(morphology)
	_finished_selecting = true
	current_state = POSSIBLE_STATES.IDLE


func _toggle_add_buttons(is_enabled: bool):
	_step1_button.visible = is_enabled
	_step2_button.visible = is_enabled
	_step3_button.visible = is_enabled

#TODO Delete?
func _set_completion_state():
	if _source == null:
		_finished_selecting = false
		_step4_button.visible = false
		return
	if _destination == null:
		_finished_selecting = false
		_step4_button.visible = false
		return
	if _selected_morphology == null:
		_finished_selecting = false
		_step4_button.visible = false
		return	
	_finished_selecting = true
	_step4_button.visible = true
		
func close_window():
	super()
	BV.UI.selection_system.remove_override_usecase(SelectionSystem.OVERRIDE_USECASE.QUICK_CONNECT)
