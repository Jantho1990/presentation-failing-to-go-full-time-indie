## Sets whether target nodes are visible. This directly controls whether the nodes render, and thus whether they take up space.
class_name SetVisibleStep extends SlideStep

@export var is_visible: bool : set = _set_is_visible
@export var targetNodes : Array[NodePath]

var _prev_is_visible: bool


func _init() -> void:
  _set_is_visible(is_visible)


func _set_is_visible(new_value: bool) -> void:
  is_visible = new_value
  _prev_is_visible = !is_visible


func next() -> void:
  step_next_began.emit()
  for targetNodePath in targetNodes:
    var targetNode = slide.get_node(targetNodePath)
    targetNode.visible = is_visible
  step_next_ended.emit()
  
  
func previous() -> void:
  step_previous_began.emit()
  for targetNodePath in targetNodes:
    var targetNode = slide.get_node(targetNodePath)
    targetNode.visible = _prev_is_visible
  step_previous_ended.emit() 
