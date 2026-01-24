class_name Queue

var _data := []
var _head := 0

func push(x):
    _data.append(x)

func pop():
    if _head >= _data.size():
        return null
    var v = _data[_head]
    _head += 1
    if _head > 64 and _head * 2 > _data.size():
        _data = _data.slice(_head, _data.size())
        _head = 0
    return v

func is_empty():
    return _head >= _data.size()