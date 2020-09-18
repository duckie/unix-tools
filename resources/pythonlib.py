#!/usr/bin/env python

#def DeepUpdate(d, u):
    #for k, v in u.iteritems():
        #if isinstance(v, collections.Mapping):
            #d[k] = update(d.get(k, {}), v)
        #else:
            #d[k] = v
    #return d
class MakeNamespace(object):
    def __init__(self,values):
        self.__dict__.update(values)

def DeepUpdate(d, u):
    for k, v in u.iteritems():
        previous_value = d.get(k,None)
        if isinstance(v, collections.Mapping):
            d[k] = DeepUpdate(d.get(k, {}), v)
        elif isinstance(v, list) and isinstance(previous_value, list):
            previous_length = len(previous_value)
            for index in range(0, len(v)):
                if index < previous_length:
                    if isinstance(v[index], collections.Mapping) and isinstance(previous_value[index], collections.Mapping):
                        DeepUpdate(previous_value[index], v[index])
                    else:
                        previous_value[index] = v[index]
                else:
                    previous_value.append(v[index])
        else:
            d[k] = v
    return d

def ConvertStringIndexedArrays(value):
    if isinstance(value, collections.Mapping):
        flattened_value = None
        if sorted([str(i) for i in range(0,len(value))]) == sorted(value.keys()):
            flattened_value = []
            for i in range(0,len(value)):
                flattened_value.append(ConvertStringIndexedArrays(value[str(i)]))
        else:
            flattened_value = {}
            for k,v in value.items():
                flattened_value[k] = ConvertStringIndexedArrays(v)
        return flattened_value
    elif isinstance(value, list):
        flattened_value = []
        for v in value:
            flattened_value.append(ConvertStringIndexedArrays(v))
        return flattened_value
    else:
        return value

def UnflattenTerraformState(value):
    if isinstance(value, collections.Mapping):
        flattened_value = {}
        for k,v in value.items():
            current = flattened_value
            path = k.split('.')
            if path[-1] == "#":
                continue
            for element in path[:-1]:
                if current.get(element,None) is None:
                    current[element] = {}
                current = current[element]
            current[path[-1]] = UnflattenTerraformState(v)
            #print("{} {}".format(current,v))
        return flattened_value
    elif isinstance(value, list):
        flattened_value = []
        for v in value:
            flattened_value.append(UnflattenTerraformState(v))
        return flattened_value
    else:
        return value

def recursive_jinja_render(template, data, jinja_env=jinja2.Environment(loader=jinja2.BaseLoader())):
    result = None
    if isinstance(template, collections.abc.Mapping):
        result = {}
        for k, v in template.items():
            result[k] = recursive_jinja_render(v, data, jinja_env)
    elif isinstance(template, list):
        result = []
        for v in template:
            result.append(recursive_jinja_render(v,data,jinja_env))
    elif isinstance(template, six.string_types):
        result = jinja_env.from_string(template).render(**data)
    else:
        result = template
    return result
