/**
* @File Name : ContactServiceImpl.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : November 19, 2024
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | November 19, 2024 |   | Initial Version
**/

public with sharing class ContactServiceImpl {
    
    public static void createRelationMapMember(List<Contact> newList) {
        system.debug('inside createRelationMapMember method>>');
        List<pqcrush__Relationship_Map_Member__c> relMapMemberList = new List<pqcrush__Relationship_Map_Member__c>();
        String originValue = System.label.Contact_Origin_Value_RMM;
        for(Contact con : newList){
            system.debug('insider for');
            if(con.pqcrush__Origin__c == originValue){
                system.debug('insider if');
                pqcrush__Relationship_Map_Member__c remMapMember = new pqcrush__Relationship_Map_Member__c();
                remMapMember.pqcrush__Contact__c = con.Id;
                //remMapMember.pqcrush__Relationship_Map__c = con.pqcrush__RelationShip_Map__c;
                remMapMember.pqcrush__Relationship_Map__c = con.pqcrush__RelationShipMap__c;
                relMapMemberList.add(remMapMember);
            }
        }
        if(relMapMemberList.size() > 0){
            system.debug('inside if');
            Database.Insert(relMapMemberList, false, AccessLevel.USER_MODE);
        }
    }

}