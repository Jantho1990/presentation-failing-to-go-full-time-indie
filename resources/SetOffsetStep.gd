## Directly sets offset posistions for target nodes.
class_name SetOffsetStep extends SlideStep


@export var targetNodePaths : Array[NodePath]: set = _set_targetNodePaths
@export var offset_distance := Vector2.ZERO
enum AXES { X, Y, BOTH }
@export var axis: AXES = AXES.BOTH

var _targetNodes : Array[Node]
var _old_offsets : Dictionary
var _old_offsets_enabled: Dictionary


func _set_targetNodePaths(new_value: Array) -> void:
  targetNodePaths = new_value
  _targetNodes = []
  if not slide:
    await slide_set
    if not slide.is_inside_tree():
      await slide.tree_entered
  for targetNodePath in targetNodePaths:
    _targetNodes.push_back(slide.get_node(targetNodePath))


func _get_destination_offset(targetNode: Control, base_offset: Vector2) -> Vector2:
  var ret := targetNode.offset_transform_position
  match axis:
      AXES.X:
        ret.x = base_offset.x
      AXES.Y:
        ret.y = base_offset.y
      AXES.BOTH:
        ret = base_offset
  return ret


func _update_old_offsets() -> void:
  _old_offsets = {}
  for targetNode in _targetNodes:
    _old_offsets[targetNode] = targetNode.offset_transform_position
    _old_offsets_enabled[targetNode] = targetNode.offset_transform_enabled


# Runs when the slide moves to the next step.
func next() -> void:
  step_next_began.emit()
  _update_old_offsets()
  
  for targetNode in _targetNodes:
    targetNode.offset_transform_enabled = true # Must be set for this animation to work.
    var destination_offset = _get_destination_offset(targetNode, offset_distance)
    targetNode.offset_transform_position = destination_offset
    #print('DBG: targetNode %s start %s destination %s' % [targetNode.name, targetNode.position, destination_offset])

  step_next_ended.emit()
  
  
# Runs when the slide moves to the previous step.
func previous() -> void:
  step_previous_began.emit()

  for targetNode in _targetNodes:
    targetNode.offset_transform_enabled = true # Must be set for this animation to work.
    var origin_offset = _get_destination_offset(targetNode, offset_distance)
    targetNode.offset_transform_position = origin_offset
    targetNode.offset_transform_enabled = _old_offsets_enabled[targetNode]
  
  step_previous_ended.emit()
