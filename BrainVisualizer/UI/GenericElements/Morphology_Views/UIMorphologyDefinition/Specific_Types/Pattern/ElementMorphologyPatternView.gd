extends VBoxContainer
class_name ElementMorphologyPatternView

signal editability_changed(can_edit: bool) # used by scroll element children to update editability state

var _pattern_pair_scroll: BaseScroll
var _add_pattern: TextureButton
var _loaded_morphology: PatternMorphology
var _allow_editing_if_morphology_editable: bool
var _subheader: HBoxContainer

func _ready() -> void:
	_pattern_pair_scroll = $Patterns
	_add_pattern = $header/add_vector
	_subheader = $subheader
	_update_subheader_positions()

func setup(allow_editing_if_morphology_editable: bool) -> void:
	_allow_editing_if_morphology_editable = allow_editing_if_morphology_editable
	
func request_feag_to_set_morphology(morphology_name: StringName) -> void:
	FeagiCore.requests.update_pattern_morphology(morphology_name, get_pattern_pair_array())

func request_feag_to_create_morphology(morphology_name: StringName) -> void:
	FeagiCore.requests.add_pattern_morphology(morphology_name, get_pattern_pair_array())
	
## Overwrite the current UI view with a [PatternMorphology] object
func set_from_pattern_morphology(pattern_morphology: PatternMorphology) -> void:
	if _loaded_morphology != null:
		if _loaded_morphology.editability_changed.is_connected(_editability_updated):
			_loaded_morphology.editability_changed.disconnect(_editability_updated)
	_loaded_morphology = pattern_morphology
	_loaded_morphology.editability_changed.connect(_editability_updated)
	var can_edit: bool = _determine_boolean_editability(pattern_morphology.get_latest_known_editability())
	_add_pattern.disabled = !can_edit
	_set_pattern_pair_array(pattern_morphology.patterns, can_edit)
	
## Spawn in an additional row, usually for editing
func add_pattern_pair_row() -> void:
	# NOTE: Theoretically, "editable" will always end up true, because the only time we can call this function is if we can edit...
	var pattern_pair: PatternVector3Pairs = PatternVector3Pairs.create_empty()
	_pattern_pair_scroll.spawn_list_item(
		{
			"allow_editing_signal": editability_changed,
			"allow_editing": true,
			"vectorPair": pattern_pair
		}
	)

## Get the number of vectors
func get_number_rows() -> int:
	return _pattern_pair_scroll.get_number_of_children()

func _editability_updated(new_editability: BaseMorphology.EDITABILITY) -> void:
	#NOTE: Due to how this is used in signals, we cannot simplify the input to a bool
	var can_edit: bool = _determine_boolean_editability(new_editability)
	_add_pattern.disabled = !can_edit
	editability_changed.emit(can_edit)

func _determine_boolean_editability(editability: BaseMorphology.EDITABILITY) -> bool:
	if !_allow_editing_if_morphology_editable:
		return false
	match editability:
		BaseMorphology.EDITABILITY.IS_EDITABLE:
			return true
		BaseMorphology.EDITABILITY.WARNING_EDITABLE_USED:
			return true
		_: # any thing else
			return false

func get_pattern_pair_array() -> Array[PatternVector3Pairs]:
	var pairs: Array[PatternVector3Pairs] = []
	for child in _pattern_pair_scroll.get_children_as_list():
		pairs.append(child.current_vector_pair)
	return pairs

func _set_pattern_pair_array(input_pattern_pairs: Array[PatternVector3Pairs], is_editable: bool) -> void:
	_pattern_pair_scroll.remove_all_children()
	for pattern_pair in input_pattern_pairs:
		_pattern_pair_scroll.spawn_list_item({
			"allow_editing_signal": editability_changed,
			"allow_editing": is_editable,
			"vectorPair": pattern_pair
		})

func _update_subheader_positions() -> void:
	var gap1: Control = $subheader/initial_gap
	var gap2: Control = $subheader/end_gap
	
	var new_width: int = int( (size.x - _subheader.size.x) / 2.0 )
	gap1.custom_minimum_size.x = new_width
	gap2.custom_minimum_size.x = new_width
