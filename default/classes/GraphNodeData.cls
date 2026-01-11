@SuppressWarnings('PMD.ExcessivePublicCount,PMD.TooManyFields,PMD.AvoidGlobalModifier')
global with sharing class GraphNodeData {
    @AuraEnabled
    public String key;

    @AuraEnabled
    public String secondaryKey;

    @AuraEnabled
    public String category;

    @AuraEnabled
    public String name;

    @AuraEnabled
    public String title;

    @AuraEnabled
    public String profileImageUrlOrData;

    @AuraEnabled
    public String influence;

    @AuraEnabled
    public String influenceImageUrl;

    @AuraEnabled
    public Boolean hasInfluenceImageUrl;

    @AuraEnabled
    public Boolean hasInfluenceSupport;

    @AuraEnabled
    public String support;

    @AuraEnabled
    public String supportColor;

    @AuraEnabled
    public String supportImageUrl;

    @AuraEnabled
    public Boolean hasSupportImageUrl;

    @AuraEnabled
    public List<OrgAdditionalField> additionalFields;

    @AuraEnabled
    public String groupKey;

    @AuraEnabled
    public Boolean isKeyTemp;

    @AuraEnabled
    public Boolean isGroup;

    @AuraEnabled
    public String groupLayout;

    @AuraEnabled
    public String text;

    @AuraEnabled
    public String tempId;

    @AuraEnabled
    public Boolean isParentNode;

    @AuraEnabled
    public Point location;

    @AuraEnabled
    public String accountName;

    @AuraEnabled
    public List<Badge> badges;

    public GraphNodeData(
        String key,
        String secondaryKey,
        String category,
        String name,
        String title,
        String profileImageUrlOrData,
        String influence,
        String influenceImageUrl,
        String support,
        String supportColor,
        String supportImageUrl,
        String accountName,
        List<OrgAdditionalField> additionalFields
    ) {
        this.isGroup = false;
        this.text = '';
        this.isKeyTemp = true;
        this.isParentNode = false;

        this.key = key;
        this.secondaryKey = secondaryKey;
        this.category = category;
        this.name = name;
        this.title = title;
        this.profileImageUrlOrData = profileImageUrlOrData;
        this.influence = influence;
        this.influenceImageUrl = influenceImageUrl;

        this.hasInfluenceImageUrl = false;
        if (!String.isBlank(influenceImageUrl)) {
            this.hasInfluenceImageUrl = true;
        }
        this.supportImageUrl = supportImageUrl;
        this.hasSupportImageUrl = false;
        if (!String.isBlank(supportImageUrl)) {
            this.hasSupportImageUrl = true;
        }

        this.support = support;
        this.supportColor = supportColor;
        this.accountName = accountName;
        this.additionalFields = additionalFields;

        this.hasInfluenceSupport = false;
        if (!String.isBlank(support) || !String.isBlank(influence)) {
            this.hasInfluenceSupport = true;
        }
    }

    public GraphNodeData(String key, String groupKey, String label, String groupLayout) {
        this.key = key;
        this.groupKey = groupKey;
        this.isKeyTemp = false;
        this.isGroup = true;
        this.text = label;
        this.isParentNode = false;
        this.groupLayout = groupLayout;
    }

    public GraphNodeData(String label, String description) {
        this.name = label;
        this.title = description;
    }

    public Boolean equals(Object obj) {
        if (obj == null || !(obj instanceof GraphNodeData)) {
            return false;
        }

        GraphNodeData other = (GraphNodeData) obj;

        return other.key == this.key &&
            other.secondaryKey == this.secondaryKey &&
            other.groupKey == this.groupKey &&
            other.text == this.text;
    }

    public Integer hashCode() {
        return key.hashCode() * secondaryKey.hashCode() * groupKey.hashCode() * text.hashCode();
    }
}