class_name SlideToOffestStep extends SlideStep


@export var animatedNodePaths : Array[NodePath]: set = _set_animatedNodePaths
@export var offset_distance := Vector2.ZERO
enum AXES { X, Y, BOTH }
@export var axis: AXES = AXES.BOTH

var _animatedNodes : Array[Node]
var _old_offsets : Dictionary
var _old_offsets_enabled: Dictionary
var _slideTween: Tween


func _set_animatedNodePaths(new_value: Array) -> void:
  animatedNodePaths = new_value
  _animatedNodes = []
  if not slide:
    await slide_set
    if not slide.is_inside_tree():
      await slide.tree_entered
  for animatedNodePath in animatedNodePaths:
    _animatedNodes.push_back(slide.get_node(animatedNodePath))


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


func _kill_tween() -> void:
  _slideTween.kill()
  _slideTween = null


func _update_old_offsets() -> void:
  _old_offsets = {}
  for animatedNode in _animatedNodes:
    _old_offsets[animatedNode] = animatedNode.offset_transform_position
    _old_offsets_enabled[animatedNode] = animatedNode.offset_transform_enabled


# Runs when the slide moves to the next step.
func next() -> void:
  step_next_began.emit()
  if _slideTween:
    _kill_tween()
  else:
    _update_old_offsets()
  
  _slideTween = slide.create_tween().set_parallel(true)
  for animatedNode in _animatedNodes:
    animatedNode.offset_transform_enabled = true # Must be set for this animation to work.
    var destination_offset = _get_destination_offset(animatedNode, offset_distance)
    #print('DBG: animatedNode %s start %s destination %s' % [animatedNode.name, animatedNode.position, destination_offset])
    _slideTween.tween_property(animatedNode, "offset_transform_position", destination_offset, animation_duration).from(_old_offsets[animatedNode])
    _slideTween.finished.connect(func (): animatedNode.offset_transform_enabled = _old_offsets_enabled[animatedNode], CONNECT_ONE_SHOT)

  await _slideTween.finished
  _slideTween = null
  step_next_ended.emit()
  
  
# Runs when the slide moves to the previous step.
func previous() -> void:
  step_previous_began.emit()
  if _slideTween:
    _kill_tween()
  
  _slideTween = slide.create_tween().set_parallel(true)
  for animatedNode in _animatedNodes:
    animatedNode.offset_transform_enabled = true # Must be set for this animation to work.
    var origin_offset = _get_destination_offset(animatedNode, offset_distance)
    _slideTween.tween_property(animatedNode, "offset_transform_position", _old_offsets[animatedNode], animation_duration).from(origin_offset)
    _slideTween.finished.connect(func (): animatedNode.offset_transform_enabled = _old_offsets_enabled[animatedNode], CONNECT_ONE_SHOT)
  
  await _slideTween.finished
  _slideTween = null
  step_previous_ended.emit()
