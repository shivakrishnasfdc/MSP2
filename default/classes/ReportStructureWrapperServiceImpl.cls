public with sharing class ReportStructureWrapperServiceImpl {
    public Map<Id, List<Map_Member_Placeholder_Relationship__c>> organizeMemberList(
        List<Map_Member_Placeholder_Relationship__c> mapMemberList
    ) {
        Map<Id, List<Map_Member_Placeholder_Relationship__c>> mapByContainerId = new Map<Id, List<Map_Member_Placeholder_Relationship__c>>();

        for (Map_Member_Placeholder_Relationship__c mmpr : mapMemberList) {
            Id key;
            if (mmpr.Relationship_Map__c != null) {
                key = mmpr.Relationship_Map__c;
            } else if (mmpr.Account_Plan__c != null) {
                key = mmpr.Account_Plan__c;
            } else {
                continue;
            }

            if (mapByContainerId.containsKey(key)) {
                List<Map_Member_Placeholder_Relationship__c> mList = mapByContainerId.get(key);
                mList.add(mmpr);
                mapByContainerId.put(key, mList);
            } else {
                mapByContainerId.put(key, new List<Map_Member_Placeholder_Relationship__c>{ mmpr });
            }
        }

        return mapByContainerId;
    }

    public Map<Id, Contact> getContactMap(List<Map_Member_Placeholder_Relationship__c> mapMemberList) {
        Set<Id> contactIds = new Set<Id>();
        for (Map_Member_Placeholder_Relationship__c mmpr : mapMemberList) {
            contactIds.add(mmpr.To__c);
            contactIds.add(mmpr.From__c);
        }

        // Query contacts & put them in a map
        List<Contact> allContacts = ContactSelector.newInstance().selectById(contactIds);
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        for (Contact c : allContacts) {
            contactMap.put(c.Id, c);
        }
        return contactMap;
    }
}