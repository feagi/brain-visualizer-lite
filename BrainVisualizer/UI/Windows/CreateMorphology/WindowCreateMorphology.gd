extends BaseDraggableWindow
class_name WindowCreateMorphology

const WINDOW_NAME: StringName = "create_morphology"

#TODO: Clean up unused get as morphology stuff in this window and in kids

const HEADER_CHOOSE_TYPE: StringName = "Select Connectivity Rule Type:"
const HEADER_VECTOR: StringName = "Adding Vector Connectivity Rule"
const HEADER_PATTERN: StringName = "Adding Pattern Connectivity Rule"
const NAME_VECTOR: StringName = "Vector Title:"
const NAME_PATTERN: StringName = "Pattern Title:"
const DESCRIPTION_VECTOR: StringName = "Vector Description:"
const DESCRIPTION_PATTERN: StringName = "Pattern Description:"

var _header_label: Label
var _options: PartWindowCreateMorphologyOptions
var _name_holder: HBoxContainer
var _morphology_name: TextInput
var _morphology_name_header: Label
var _composite: ElementMorphologyCompositeView
var _vectors: ElementMorphologyVectorsView
var _patterns: ElementMorphologyPatternView
var _morphology_description: TextEdit
var _description_label: Label
var _bottom_buttons: HBoxContainer

var _selected_morphology_type: BaseMorphology.MORPHOLOGY_TYPE = BaseMorphology.MORPHOLOGY_TYPE.NULL

func _ready():
	super()
	_header_label = _window_internals.get_node("Header")
	_options = _window_internals.get_node("Options")
	_name_holder = _window_internals.get_node("Name")
	_morphology_name_header = _window_internals.get_node("Name/Label")
	_morphology_name = _window_internals.get_node("Name/Name")
	_vectors = _window_internals.get_node("ElementMorphologyVectorsView")
	_patterns = _window_internals.get_node("ElementMorphologyPatternView")
	_composite = _window_internals.get_node("ElementMorphologyCompositeView")
	_description_label = _window_internals.get_node("Description")
	_morphology_description = _window_internals.get_node("Description_text")
	_bottom_buttons = _window_internals.get_node("Buttons")
	
	_composite.setup(true)
	_vectors.setup(true)
	_patterns.setup(true)
	
	
	print("initialized create morphology window")

func setup() -> void:
	_setup_base_window(WINDOW_NAME)
	

func _step_1_pick_type():
	_options.visible = true
	_composite.visible = false
	_vectors.visible = false
	_patterns.visible = false
	_name_holder.visible = false
	_description_label.visible = false
	_morphology_description.visible = false
	_bottom_buttons.visible = false
	
	_header_label.text = HEADER_CHOOSE_TYPE
	shrink_window()

func _step_2_input_properties(morphology_type: BaseMorphology.MORPHOLOGY_TYPE):
	_selected_morphology_type = morphology_type
	_options.visible = false
	_name_holder.visible = true
	_description_label.visible = true
	_morphology_description.visible = true
	_bottom_buttons.visible = true
	
	match morphology_type:
		BaseMorphology.MORPHOLOGY_TYPE.VECTORS:
			_composite.visible = false
			_vectors.visible = true
			_patterns.visible = false
			_header_label.text = HEADER_VECTOR
			_morphology_name_header.text = NAME_VECTOR
			_description_label.text = DESCRIPTION_VECTOR
		BaseMorphology.MORPHOLOGY_TYPE.PATTERNS:
			_composite.visible = false
			_vectors.visible = false
			_patterns.visible = true
			_header_label.text = HEADER_PATTERN
			_morphology_name_header.text = NAME_PATTERN
			_description_label.text = DESCRIPTION_PATTERN
			
	shrink_window()

func _on_create_morphology_pressed():

	if _morphology_name.text == "":
		var popup_definition: ConfigurablePopupDefinition = ConfigurablePopupDefinition.create_single_button_close_popup("Missing Name", "Please define a name for your connectivity rule!")
		BV.WM.spawn_popup(popup_definition)
		return
	
	if _morphology_name.text in FeagiCore.feagi_local_cache.morphologies.available_morphologies.keys():
		var popup_definition: ConfigurablePopupDefinition = ConfigurablePopupDefinition.create_single_button_close_popup("Existing Name", "A connectivity rule with this name already exists!!")
		BV.WM.spawn_popup(popup_definition)
		return
	

	match _selected_morphology_type:
		BaseMorphology.MORPHOLOGY_TYPE.VECTORS:
			if _vectors.get_number_rows() == 0:
				var popup_definition: ConfigurablePopupDefinition = ConfigurablePopupDefinition.create_single_button_close_popup("No Vectors", "Please define at least one vector for your connectivity rule!")
				BV.WM.spawn_popup(popup_definition)
				return
			FeagiCore.requests.add_vector_morphology(_morphology_name.text, _vectors.get_vector_array())
		BaseMorphology.MORPHOLOGY_TYPE.PATTERNS:
			if _patterns.get_number_rows() == 0:
				var popup_definition: ConfigurablePopupDefinition = ConfigurablePopupDefinition.create_single_button_close_popup("No Patterns", "Please define at least one pattern for your connectivity rule!")
				BV.WM.spawn_popup(popup_definition)
				return
			FeagiCore.requests.add_pattern_morphology(_morphology_name.text, _patterns.get_pattern_pair_array())
	
	close_window()
