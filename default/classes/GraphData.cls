@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class GraphData {
    @AuraEnabled
    public List<GraphNodeData> nodeDataArray;

    @AuraEnabled
    public List<GraphLinkData> linkDataArray;

    @AuraEnabled
    public String linkFromKeyProperty;

    @AuraEnabled
    public String linkToKeyProperty;

    @AuraEnabled
    public String linkFromPortIdProperty;

    @AuraEnabled
    public String linkToPortIdProperty;

    @AuraEnabled
    public String groupKeyProperty;

    @AuraEnabled
    public String searchKey;

    public GraphData() {
        this(new List<GraphNodeData>(), new List<GraphLinkData>());
    }

    public GraphData(List<GraphNodeData> nodeDataArray, List<GraphLinkData> linkDataArray) {
        this.nodeDataArray = nodeDataArray;
        this.linkDataArray = linkDataArray;
        this.linkFromKeyProperty = 'fromKey';
        this.linkToKeyProperty = 'toKey';
        this.linkFromPortIdProperty = 'fromPort';
        this.linkToPortIdProperty = 'toPort';
        this.groupKeyProperty = 'groupKey';
    }

    public Boolean equals(Object obj) {
        if (obj == null || !(obj instanceof GraphData)) {
            return false;
        }

        GraphData other = (GraphData) obj;

        return this.nodeDataArray == other.nodeDataArray && this.linkDataArray == other.linkDataArray;
    }

    public Integer hashCode() {
        return System.hashCode(this.nodeDataArray) + System.hashCode(this.linkDataArray);
    }
}