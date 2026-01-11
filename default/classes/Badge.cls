public with sharing class Badge {
    @AuraEnabled
    public String id;

    @AuraEnabled
    public String geometryString;

    @AuraEnabled
    public String fill;

    @AuraEnabled
    public Boolean bounded;

    public Badge(String id, String geometryString, String fill, Boolean bounded) {
        this.id = id;
        this.geometryString = geometryString;
        this.fill = fill;
        this.bounded = bounded;
    }

    public Boolean equals(Object obj) {
        if (obj == null || !(obj instanceof Badge)) {
            return false;
        }

        Badge other = (Badge) obj;

        if (this.id != null && other.id != null) {
            return this.id == other.id;
        }
        return this.geometryString == other.geometryString;
    }

    public Integer hashCode() {
        if (this.id != null) {
            return this.id.hashCode();
        }
        return this.geometryString.hashCode();
    }
}