public with sharing class Point {
    @AuraEnabled
    public Double x;

    @AuraEnabled
    public Double y;

    public Point(Double x, Double y) {
        this.x = x;
        this.y = y;
    }

    public Boolean equals(Object obj) {
        if (obj == null || !(obj instanceof Point)) {
            return false;
        }

        Point other = (Point) obj;

        return this.x == other.x && this.y == other.y;
    }

    public Integer hashCode() {
        return System.hashCode(this.x) + System.hashCode(this.y);
    }
}