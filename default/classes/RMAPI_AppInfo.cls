@RestResource(urlMapping='/rmapi_appinfo/*')
global with sharing class RMAPI_AppInfo {
    // -----------------------------------------
    // CHANGES TO OUR CORE
    // -----------------------------------------
    // Mark our existing GraphData class as global to be able to retrieve via RelationshipMapMemberController.getUserGraphDataForHierarchyId(hierarchyId)
    // Mark our GraphNodeData class as global to be able to retrieve via RelationshipMapMemberController.createNewPlaceholder(graphDataJsonString, mapId);
    // Mark our NameValuePair class as global to be able to retrieve via RelationshipMapMemberController.getInfluenceValues() and getSupportValues()

    // Create new classes for each API endpoint, add decorator @RestResource(urlMapping='/graphapi_info/*')
    // Only one of each HTTP method per class (one GET, one POST etc)
    // Client URL must have our pqcrush namespace in it
    // -----------------------------------------

    // RMAPI_AppInfo
    //   -> Get Installation Info
    // GET  /services/apexrest/pqcrush/rmapi_appinfo/

    // RMAPI_Map
    //   -> Instance of a Relationship Map
    // GET  /services/apexrest/pqcrush/rmapi_map/a0M1F000004CwTWUA0
    // PUT  /services/apexrest/pqcrush/rmapi_map/a0M1F000004CwTWUA0
    // POST /services/apexrest/pqcrush/rmapi_map/

    // RMAPI_Map_Contacts
    //   -> Associate Contacts with a Relationship Map
    // POST  /services/apexrest/pqcrush/rmapi_map_contacts/

    // RMAPI_Map_Contact_Parents
    //   -> Get Parent nodes for Contacts
    // GET  /services/apexrest/pqcrush/rmapi_map_contact_parents/
    // GET  /services/apexrest/pqcrush/rmapi_map_contact_parents_v2/

    // RMAPI_Map_Members_Delete
    //   -> Delete a Relationship Map Member
    // POST  /services/apexrest/pqcrush/rmapi_map_members_delete/

    // RMAPI_Map_Member_Users
    //   -> Create and Update User map nodes
    // POST   /services/apexrest/pqcrush/rmapi_map_member_users/
    // PUT    /services/apexrest/pqcrush/rmapi_map_member_users/

    // RMAPI_Maps
    //   -> Listing of available Relationhips Maps for the caller
    // GET  /services/apexrest/pqcrush/rmapi_maps/

    // RMAPI_MapSettings
    //   -> Get the Settings info for RM in this Org
    // GET  /services/apexrest/pqcrush/rmapi_mapsettings/

    // RMAPI_Contact_Search
    //   -> Get Contact Graph Data for Search Terms
    // POST  /services/apexrest/pqcrush/rmapi_contact_search/

    // RMAPI_Group
    // POST  /services/apexrest/pqcrush/rmapi_group/
    // PUT   /services/apexrest/pqcrush/rmapi_group/

    // RMAPI_Group_Contacts_Add
    // POST  /services/apexrest/pqcrush/rmapi_group_contacts_add/

    // RMAPI_Group_Groups_Add
    // POST  /services/apexrest/pqcrush/rmapi_group_groups_add/

    // RMAPI_Group_Nodes_Remove
    // POST  /services/apexrest/pqcrush/rmapi_group_nodes_remove/

    // RMAPI_Hierarchy
    //   -> Updates ReportsTo hierarchy data
    // POST  /services/apexrest/pqcrush/rmapi_hierarchy/

    // RMAPI_CustomLinks
    // POST  /services/apexrest/pqcrush/rmapi_customlinks/
    // PUT   /services/apexrest/pqcrush/rmapi_customlinks/

    // RMAPI_CustomLinks_Delete
    //   -> Delete Custom Links
    // POST   /services/apexrest/pqcrush/rmapi_customlinks_delete/

    // RMAPI_Placeholder
    //   -> Create and Update Placeholder nodes
    // POST   /services/apexrest/pqcrush/rmapi_placeholder/
    // PUT    /services/apexrest/pqcrush/rmapi_placeholder/

    // RMAPI_Placeholder_Delete
    //   -> Delete Placeholder nodes
    // POST   /services/apexrest/pqcrush/rmapi_placeholder_delete/

    // RMAPI_RelationshipTypes
    //   -> Get the defined Contact Relationshp Types
    // GET   /services/apexrest/pqcrush/rmapi_relationshiptypes/

    // RMAPI_SupportColors
    //   -> Get the configured support colors for this org
    // GET   /services/apexrest/pqcrush/rmapi_supportcolors/

    // RMAPI_SupportValues
    //   -> Get the defined Support values
    // GET   /services/apexrest/pqcrush/rmapi_supportvalues/

    // RMAPI_InfluenceValues
    //   -> Get the defined Influence values
    // GET   /services/apexrest/pqcrush/rmapi_influencevalues/

    // RMAPI_UserRecordAccess
    //   -> Get the user's permissions for a given object
    // GET  /services/apexrest/pqcrush/rmapi_userrecordaccess/

    global class RMAPIEndpoint {
        public string resource;
        public string verb;
        public string url;

        public RMAPIEndpoint(String resource, String verb, String url) {
            this.resource = resource;
            this.verb = verb;
            this.url = url;
        }
    }

    global class RMAPI_InstallationInfo {
        public String rmVersion;
        public String versionNotes;
        public String versionMinimum;
        public List<RMAPIEndpoint> rmAPIEndpointMap;

        public RMAPI_InstallationInfo() {
            // Select Id,SubscriberPackage.Name,SubscriberPackageVersion.MajorVersion,SubscriberPackageVersion.MinorVersion,SubscriberPackageVersion.PatchVersion from InstalledSubscriberPackage

            // TODO - Pull these values from the package
            // TODO - How to handle with custom code push?
            this.rmVersion = '10.0';
            this.versionMinimum = '10.0';
            this.versionNotes = 'PROLIFIQ RM, Spring 2021 Release';

            mapAPIEndpoints();
        }

        private void mapAPIEndpoints() {
            // TODO - Any way to better way to reflect this from the code?
            this.rmAPIEndpointMap = new List<RMAPIEndpoint>();
            this.rmAPIEndpointMap.add(new RMAPIEndpoint('RMAPI_AppInfo', 'GET', '/services/apexrest/pqcrush/rmapi_appinfo/'));
            this.rmAPIEndpointMap.add(new RMAPIEndpoint('RMAPI_Map', 'GET', '/services/apexrest/pqcrush/rmapi_map/{MapId}'));
            this.rmAPIEndpointMap.add(new RMAPIEndpoint('RMAPI_Map', 'PUT', '/services/apexrest/pqcrush/rmapi_map/{MapId}'));
            this.rmAPIEndpointMap.add(new RMAPIEndpoint('RMAPI_Map', 'POST', '/services/apexrest/pqcrush/rmapi_map/'));
            this.rmAPIEndpointMap.add(new RMAPIEndpoint('RMAPI_Map_Contacts', 'POST', '/services/apexrest/pqcrush/rmapi_map_contacts/'));
            this.rmAPIEndpointMap.add(new RMAPIEndpoint('RMAPI_Map_Contact_Parents','GET','/services/apexrest/pqcrush/rmapi_map_contact_parents/'));
            this.rmAPIEndpointMap.add(new RMAPIEndpoint('Map_Contact_Parents','GET','/services/apexrest/pqcrush/rmapi/v2/map_contact_parents/'));
            this.rmAPIEndpointMap.add(new RMAPIEndpoint('RMAPI_Map_Members_Delete','POST','/services/apexrest/pqcrush/rmapi_map_members_delete/'));
            this.rmAPIEndpointMap.add(new RMAPIEndpoint('RMAPI_Map_Member_Users','POST','/services/apexrest/pqcrush/rmapi_map_member_users/'));
            this.rmAPIEndpointMap.add(new RMAPIEndpoint('RMAPI_Maps', 'GET', '/services/apexrest/pqcrush/rmapi_maps/'));
            this.rmAPIEndpointMap.add(new RMAPIEndpoint('RMAPI_MapSettings', 'GET', '/services/apexrest/pqcrush/rmapi_mapsettings/'));
            this.rmAPIEndpointMap.add(new RMAPIEndpoint('RMAPI_Group', 'POST', '/services/apexrest/pqcrush/rmapi_group/'));
            this.rmAPIEndpointMap.add(new RMAPIEndpoint('RMAPI_Group', 'PUT', '/services/apexrest/pqcrush/rmapi_group/'));
            this.rmAPIEndpointMap.add(new RMAPIEndpoint('RMAPI_Group_Contacts_Add','POST','/services/apexrest/pqcrush/rmapi_group_contacts_add/'));
            this.rmAPIEndpointMap.add(new RMAPIEndpoint('RMAPI_Group_Groups_Add','POST','/services/apexrest/pqcrush/rmapi_group_groups_add/'));
            this.rmAPIEndpointMap.add(new RMAPIEndpoint('RMAPI_Group_Nodes_Remove','POST','/services/apexrest/pqcrush/rmapi_group_nodes_remove/'));
            this.rmAPIEndpointMap.add(new RMAPIEndpoint('RMAPI_Hierarchy', 'POST', '/services/apexrest/pqcrush/rmapi_hierarchy/'));
            this.rmAPIEndpointMap.add(new RMAPIEndpoint('RMAPI_Contact_Search', 'POST', '/services/apexrest/pqcrush/rmapi_contact_search/'));
            this.rmAPIEndpointMap.add(new RMAPIEndpoint('RMAPI_CustomLinks', 'POST', '/services/apexrest/pqcrush/rmapi_customlinks/'));
            this.rmAPIEndpointMap.add(new RMAPIEndpoint('RMAPI_CustomLinks', 'PUT', '/services/apexrest/pqcrush/rmapi_customlinks/'));
            this.rmAPIEndpointMap.add(new RMAPIEndpoint('RMAPI_CustomLinks_Delete','POST','/services/apexrest/pqcrush/rmapi_customlinks_delete/'));
            this.rmAPIEndpointMap.add(new RMAPIEndpoint('RMAPI_Placeholder', 'POST', '/services/apexrest/pqcrush/rmapi_placeholder/'));
            this.rmAPIEndpointMap.add(new RMAPIEndpoint('RMAPI_Placeholder', 'PUT', '/services/apexrest/pqcrush/rmapi_placeholder/'));
            this.rmAPIEndpointMap.add(new RMAPIEndpoint('RMAPI_Placeholder_Delete','POST','/services/apexrest/pqcrush/rmapi_placeholder_delete/'));
            this.rmAPIEndpointMap.add(new RMAPIEndpoint('RMAPI_RelationshipTypes', 'GET', '/services/apexrest/pqcrush/rmapi_supportcolors/'));
            this.rmAPIEndpointMap.add(new RMAPIEndpoint('RMAPI_SupportColors', 'GET', '/services/apexrest/pqcrush/rmapi_supportcolors/'));
            this.rmAPIEndpointMap.add(new RMAPIEndpoint('RMAPI_SupportValues', 'GET', '/services/apexrest/pqcrush/rmapi_supportvalues/'));
            this.rmAPIEndpointMap.add(new RMAPIEndpoint('RMAPI_InfluenceValues', 'GET', '/services/apexrest/pqcrush/rmapi_influencevalues/'));
            this.rmAPIEndpointMap.add(new RMAPIEndpoint('RMAPI_UserRecordAccess', 'GET', '/services/apexrest/pqcrush/rmapi_userrecordaccess/'));
        }
    }

    @HttpGet
    global static RMAPI_InstallationInfo doGet() {
        return new RMAPI_InstallationInfo();
    }
}