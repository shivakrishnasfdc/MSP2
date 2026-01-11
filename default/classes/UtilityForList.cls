public with sharing class UtilityForList {
    public static List<Object> slice(List<Object> input, Integer startIndex, Integer length) {
        if (input == null) {
            return null;
        }
        List<Object> output = input.clone();
        if (startIndex == null || startIndex < 0) {
            startIndex = 0;
        }
        if (length == null || length < 0) {
            length = 0;
        }
        Integer min = startIndex >= output.size() ? output.size() : startIndex;
        for (Integer i = 0; i < min; i++) {
            output.remove(0);
        }
        while (output.size() > length) {
            output.remove(length);
        }
        return output;
    }

    public static Object first(List<Object> objects) {
        return (objects == null || objects.size() == 0) ? null : objects[0];
    }

    public static Object last(List<Object> objects) {
        return (objects == null || objects.size() == 0) ? null : objects[objects.size() - 1];
    }
}