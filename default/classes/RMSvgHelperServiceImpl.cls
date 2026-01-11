public with sharing class RMSvgHelperServiceImpl {
    public List<GraphNodeData> injectBoundBadges(List<RM_Svg__c> svgs, List<GraphNodeData> graphNodeDataList) {
        for (RM_Svg__c svg : svgs) {
            if (String.isBlank(svg.Contact_Field_API_Name__c)) {
                continue;
            }
            updateGraphNodeDataListForSvg(svg, graphNodeDataList);
        }
        return graphNodeDataList;
    }

    private void updateGraphNodeDataListForSvg(RM_Svg__c svg, List<GraphNodeData> graphNodeDataList) {
        for (GraphNodeData gnd : graphNodeDataList) {
            if (nodeContainsBoundField(gnd, svg.Contact_Field_API_Name__c)) {
                if (gnd.badges == null) {
                    gnd.badges = new List<Badge>();
                }
                gnd.badges.add(new Badge((String) svg.Id, '', '', true));
            }
            gnd.additionalFields = removeField(gnd.additionalFields, svg.Contact_Field_API_Name__c);
        }
    }

    private Boolean nodeContainsBoundField(GraphNodeData node, String apiName) {
        if (node.additionalFields != null && node.additionalFields.size() > 0) {
            for (OrgAdditionalField f : node.additionalFields) {
                if (f.apiName == apiName && f.value.toLowerCase() == 'true') {
                    return true;
                }
            }
        }
        return false;
    }

    private List<OrgAdditionalField> removeField(List<OrgAdditionalField> fields, String apiName) {
        List<OrgAdditionalField> newFields = new List<OrgAdditionalField>();
        if (fields != null && fields.size() > 0) {
            for (OrgAdditionalField f : fields) {
                if (f.apiName != apiName) {
                    newFields.add(f);
                }
            }
        }
        return newFields;
    }
}