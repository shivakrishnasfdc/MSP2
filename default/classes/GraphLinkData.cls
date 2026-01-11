public with sharing class GraphLinkData {
    @AuraEnabled
    public String id;

    @AuraEnabled
    public String tempId;

    @AuraEnabled
    public String fromKey;

    @AuraEnabled
    public Boolean deletable;

    @AuraEnabled
    public String toKey;

    @AuraEnabled
    public String category;

    @AuraEnabled
    public String text;

    public GraphLinkData(
        String id,
        String tempId,
        String fromKey,
        Boolean deletable,
        String toKey,
        String category,
        String text
    ) {
        this.id = id;
        this.tempId = tempId;
        this.fromKey = fromKey;
        this.deletable = deletable;
        this.toKey = toKey;
        this.category = category;
        this.text = text;
    }

    public Boolean equals(Object obj) {
        if (obj == null || !(obj instanceof GraphLinkData)) {
            return false;
        }

        GraphLinkData other = (GraphLinkData) obj;

        if (this.id != null && other.id != null) {
            return this.id == other.id;
        }
        return this.tempId == other.tempId;
    }

    public Integer hashCode() {
        if (this.id != null) {
            return this.id.hashCode();
        }
        return this.tempId.hashCode();
    }
}