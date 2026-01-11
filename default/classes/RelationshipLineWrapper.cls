public with sharing class RelationshipLineWrapper {
    @AuraEnabled
    public Id id { get; set; }
    @AuraEnabled
    public String lineLabel { get; set; }
    @AuraEnabled
    public String lineColor { get; set; }
    @AuraEnabled
    public String nodeName { get; set; }

    public RelationshipLineWrapper(Id id, String lineLabel, String lineColor, String nodeName) {
        this.id = id;
        this.lineColor = lineColor;
        this.lineLabel = lineLabel;
        this.nodeName = nodeName;
    }
}