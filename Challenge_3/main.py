def fetchKey(obj: dict):
    keys = list(obj)
    return keys[0]


def fetchNestedValue(obj: dict, key: str, isFound = False):
    if type(obj) is not dict and not isFound:
        return None
    if (isFound or (key in obj.keys())) :
        if type(obj[key]) is dict:
            return fetchNestedValue(obj[key], fetchKey(obj[key]), True)
        else:
            return obj[fetchKey(obj)]
    else:
        nestedKey = fetchKey(obj)
        return fetchNestedValue(obj[nestedKey], key, False)

if __name__ == '__main__':
    obj = {'a': {'b': {'c': 'd'}}}
    value = fetchNestedValue(obj, 'a')
    print(value)