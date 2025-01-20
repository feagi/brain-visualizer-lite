extends TextureButton
class_name UIMorphologyDeleteButton

var _loaded_morphology: BaseMorphology

func load_morphology(morphology: BaseMorphology) -> void:
	if _loaded_morphology != null:
		if _loaded_morphology.editability_changed.is_connected(_deletability_updated):
			_loaded_morphology.editability_changed.disconnect(_deletability_updated)
	_loaded_morphology = morphology
	_deletability_updated(morphology.get_latest_known_deletability())
	_loaded_morphology.editability_changed.connect(_deletability_updated)

func _deletability_updated(deletable: BaseMorphology.DELETABILITY) -> void:
	match(deletable):
		BaseMorphology.DELETABILITY.IS_DELETABLE:
			disabled = false
			tooltip_text = "Delete connectivity rule..."
		BaseMorphology.DELETABILITY.NOT_EDITABLE_CORE_CLASS:
			disabled = true
			tooltip_text = "Cannot delete a core connectivity rule!"
		BaseMorphology.DELETABILITY.NOT_DELETABLE_USED:
			disabled = true
			tooltip_text = "Connectivity rule is in use and cannot be deleted!"
		BaseMorphology.DELETABILITY.NOT_DELETABLE_UNKNOWN:
			disabled = true
			tooltip_text = "Connectivity rule is in an unknown state and cannot be deleted at this time."
			
