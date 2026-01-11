import { LightningElement, api, wire } from 'lwc';
import { publish, subscribe, MessageContext } from 'lightning/messageService';
import RELATIONSHIP_MAP_DATA_CHANNEL from '@salesforce/messageChannel/relationshipMapData__c';
import INFLUENCE_CHART_DATA_CHANNEL from '@salesforce/messageChannel/influenceChartData__c';
import MAP_MEMBER_LIST_DATA_CHANNEL from '@salesforce/messageChannel/mapMemberListData__c';
import getMapIdForSObjectId from '@salesforce/apex/RelationshipMapMemberController.getMapIdForSObjectId';

import addContactToRelationshipMap from '@salesforce/apex/RelationshipMapMemberController.addContactToRelationshipMap';
import addAccountToRelationshipMap from '@salesforce/apex/RelationshipMapMemberController.addAccountToRelationshipMap';
import addUserToRelationshipMap from '@salesforce/apex/GraphDataController.createMapMemberUsers';
import addLeadToRelationshipMap from '@salesforce/apex/RelationshipMapMemberController.addLeadToRelationshipMap';
import deleteMembers from '@salesforce/apex/RelationshipMapMemberController.removeParentId';
import deleteMapMemberUsers from '@salesforce/apex/GraphDataController.deleteMapMemberUsers';
import deleteMapMemberLeads from '@salesforce/apex/RelationshipMapMemberController.deleteMapMemberLeads';
import getGraphData from '@salesforce/apex/RelationshipMapMemberController.getUserGraphDataForHierarchyId';
import getAccountGraphData1 from '@salesforce/apex/RelationshipMapMemberController.getAccountGraphDataForHierarchyId';
import getAccountGraphData from '@salesforce/apex/RelationshipMapMemberController.getAccountGraphData';
import searchContactRecords from '@salesforce/apex/RelationshipMapMemberController.getContactGraphDataForSearchTerm';
import searchAccountRecords from '@salesforce/apex/RelationshipMapMemberController.getAccountGraphDataForSearchTerm';
import searchLeadRecords from '@salesforce/apex/GraphDataController.getLeadGraphDataForSearchTerm';
import searchUserRecords from '@salesforce/apex/GraphDataController.getUserGraphDataForSearchTerm';
import getSettingsRecordAccess from '@salesforce/apex/RMChartSettingController.getRelationshipMapAccessRecordForObject';
import getChartSettings from '@salesforce/apex/RMChartSettingController.getRelationshipMapSettingForObject';
import getRMOrgSetting from '@salesforce/apex/RMOrgSettingService.getRMOrgSetting';
import getAccountMatrixByRelationshipMap from '@salesforce/apex/RelationshipMapMemberController.getAccountMatrixByRelationshipMap';
import setAnchor from '@salesforce/apex/GraphDataController.setAnchor';
import getAnchors from '@salesforce/apex/GraphDataController.getAnchors';
import getMapParent from '@salesforce/apex/RelationshipMapMemberController.getParentIdForRelationshipMapId';
import isAccountPlanMap from '@salesforce/apex/RelationshipMapMemberController.isAccountPlanMap';
import getAccountRelationshipMapId from '@salesforce/apex/AccountHierarchyController.getAccountRelationshipMapId';
import getAccountId from '@salesforce/apex/AccountHierarchyController.getAccountId';

// Contact Relationship Types
import getRelationshipTypes from '@salesforce/apex/GraphDataController.getContactRelationshipTypes';

// Hierarchy
import updateParentAccountId from '@salesforce/apex/GraphDataController.updateParentAccountId';

// Links
import newCustomLinks from '@salesforce/apex/GraphDataController.newCustomLinks';

// Groups
import createNewGroup from '@salesforce/apex/GraphDataController.createNewGroup';
import addContactsToGroup from '@salesforce/apex/GraphDataController.addContactsToGroup';

import saveAllNodeCoordinates from '@salesforce/apex/GraphDataController.saveAllNodeCoordinates';
import updateNodeCoordinates from '@salesforce/apex/GraphDataController.updateNodeCoordinates';

// Placeholder
import createNewPlaceholder from '@salesforce/apex/GraphDataController.createNewPlaceholder';

// Get Parent Nodes
import getParentNodes from '@salesforce/apex/RelationshipMapMemberController.getParentNodesForContactIds';

// User Access Record
import getUserRecordAccess from '@salesforce/apex/UserRecordAccessServiceController.getUserRecordAccess';

// Badge
import getBadgeOptions from '@salesforce/apex/GraphDataController.getBadgeOptions';
import associateBadge from '@salesforce/apex/GraphDataController.associateBadge';
import removeBadge from '@salesforce/apex/GraphDataController.removeBadge';

import { formatLabel } from 'c/stringUtils';

import LABEL_RELATIONSHIP_MAP_SETTINGS from '@salesforce/label/c.Relationship_Map_Settings';

// Relationship Map Info
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import RELATIONSHIP_MEMBER from '@salesforce/schema/Relationship_Map_Member__c';
import RELATIONSHIP_MAP from '@salesforce/schema/Relationship_Map__c';

import insufficientAccessException from '@salesforce/label/c.error_insufficient_access';

export default class AccountrelationshipMap extends LightningElement {
    @api containerRecordId;

    @api recordId;

    @api objectApiName;

    parentId;

    openCloneModal = false;

    graphData = undefined;

    mapIsUpdateable = false;

    containerIsUpdateable = false;

    isAccountPlanMap = false;

    errorMessage = null;

    objectLabel;

    supportData;

    influenceData;

    chartSettings;

    rmOrgSettings;

    anchors;

    currentSearchKey;

    relationshipTypes = [];

    badgeOptions;

    mapId;

    accRelMapId;

    accId;

    
    getMapId() {
        if (!this.objectApiName || !this.recordId) {
            return;
        }
        let self = this;

        getMapIdForSObjectId({ recordId: this.recordId })
            .then((result) => {
                self.mapId = result;
            })
            .catch((error) => {
                this.updateErrorMessage(error.body.message);
                self.mapId = null;
            });
    }

    get canEditGraph() {
        if (this.isAccountPlanMap) {
            return this.mapIsUpdateable && this.containerIsUpdateable;
        }

        return this.mapIsUpdateable;
    }

    get containerId() {
        if (this.parentId) {
            return this.parentId;
        }

        return this.containerRecordId;
    }

    @wire(MessageContext) messageContext;

    // Object Info
    @wire(getObjectInfo, { objectApiName: RELATIONSHIP_MEMBER.objectApiName })
    wiredCheckMapMember({ data, error }) {
        if (data) {
            this.objectLabel = data.label;
        } else if (error) {
            if (error.status === 403) {
                this.updateErrorMessage(formatLabel(insufficientAccessException, [RELATIONSHIP_MEMBER.objectApiName]));
            } else {
                this.createErrorEvent(error);
            }
        }
    }

    @wire(getObjectInfo, { objectApiName: RELATIONSHIP_MAP.objectApiName })
    wiredCheckMap({ data, error }) {
        if (data) {
            this.mapIsUpdateable = data.updateable;
        } else if (error) {
            if (error.status === 403) {
                this.updateErrorMessage(formatLabel(insufficientAccessException, [RELATIONSHIP_MAP.objectApiName]));
            } else {
                this.createErrorEvent(error);
            }
        }
    }

    @wire(isAccountPlanMap, { mapId: '$recordId' })
    wiredCheckAccountPlanMap({ data, error }) {
        if (data) {
            this.isAccountPlanMap = data;
        } else {
            this.isAccountPlanMap = false;
        }
        if (error) {
            this.createErrorEvent(error);
        }
    }

    // Container info
    @wire(getUserRecordAccess, { recordId: '$containerId' })
    wiredCheckContainer({ data, error }) {
        if (data) {
            this.containerIsUpdateable = data.HasAllAccess || data.HasEditAccess;
        } else if (error) {
            if (error.status === 403) {
                this.updateErrorMessage(formatLabel(insufficientAccessException, [this.objectLabel]));
            } else {
                this.createErrorEvent(error);
            }
        }
    }

    updateErrorMessage(message) {
        if (this.errorMessage == null) {
            this.errorMessage = '';
        }
        this.errorMessage += message + '<br/>';
    }

    async getSettingsAndData() {
        Promise.all([
            getChartSettings({ objectId: this.recordId }),
            getRMOrgSetting({ recordId: this.recordId }),
            getBadgeOptions({ mapOrAccountPlanId: this.recordId }),
            getRelationshipTypes({ mapOrAccountPlanId: this.recordId })
        ])
            .then(([resultChartSettings, resultGetRMOrgSetting, resultBadgeOptions, resultRelationshipTypes]) => {
                this.chartSettings = resultChartSettings;
                this.rmOrgSettings = resultGetRMOrgSetting;
                this.badgeOptions = resultBadgeOptions;
                this.relationshipTypes = resultRelationshipTypes;

                this.retrieveData();
            })
            .catch((error) => {
                this.handleError(error);
            });
    }

    getAnchors() {
        getAnchors({ objectId: this.recordId })
            .then((result) => {
                if (result) {
                    let arr = [];

                    result.forEach((anchor) => {
                        arr.push({
                            from: anchor.pqcrush__From__c,
                            to: anchor.pqcrush__To__c
                        });
                    });
                    this.anchors = arr;
                }
            })
            .catch((error) => {
                this.createErrorEvent(error);
            });
    }

    checkContainerObject() {
        getMapParent({ mapId: this.recordId })
            .then((result) => {
                this.parentId = result;
            })
            .catch((error) => {
                this.createErrorEvent(error);
            });
    }

    editSettings() {
        getSettingsRecordAccess({ objectId: this.recordId })
            .then((result) => {
                const detail = {
                    name: 'settings',
                    objectLabel: LABEL_RELATIONSHIP_MAP_SETTINGS,
                    objectId: result.RecordId,
                    access: result
                };

                const objectEditClickedEvent = new CustomEvent('requestobjectviewer', {
                    detail: detail
                });

                // Dispatches the event.
                this.dispatchEvent(objectEditClickedEvent);
            })
            .catch((error) => {
                this.createErrorEvent(error);
            });
    }

    connectedCallback() {

        this.retrieveAccountId()
        //this.retrieveAccountRelationshipMapId();
        //setTimeout(this.retrieveAccountRelationshipMapId(), 8000);
        //this.getMapId();
        this.checkContainerObject();
        this.getSettingsAndData();
        this.getAnchors();
        this.subscribeToChannel();
    }

    retrieveAccountRelationshipMapId(){
        getAccountRelationshipMapId({ accountPlanId: this.recordId })
        .then((result) => {
            console.log('==getting the id==');
            console.log(result)
            this.accRelMapId = result;
        })
        .catch((error) => {
            console.log('==Error in getting the id==');
        });
    }
//Account Data
    retrieveAccountId(){
        getAccountId({ recordId: this.recordId })
        .then((result) => {
            console.log('==getting the id==');
            console.log(result)
            this.accId = result;
        })
        .catch((error) => {
            console.log('==Error in getting the id==');
        });
    }

    //need to send Account relationship Map Id dynamically relationshipMapId
    async retrieveData() {
        var self = this;

        if (!this.recordId) {
            return;
        }
        if (!getGraphData) {
            return;
        }

        let matrix = await getAccountMatrixByRelationshipMap({
            mapId: this.recordId
        });

        this.influenceData = matrix?.influenceList;
        this.supportData = matrix?.supportList;
        console.log('==retrieve data called==');
        console.log('==this.recordId hierarchyId=='+this.recordId);
        /*let armId = this.accRelMapId;//a0iOz000003aYpUIAU
        getAccountGraphData1({ hierarchyId: armId })
            .then((result) => {
                console.log('==getGraphData called==');
                self.graphData = result;
                self.graphData.influenceData = this.influenceData;
                self.graphData.supportData = this.supportData;
                self.graphData.badgeOptions = this.badgeOptions;
                this.publishMessage();
            })*/
        let aid =this.accId;
        console.log('this.accId'+aid);
        getAccountGraphData({ hierarchyId: aid })
            .then((result) => {
                console.log('==getGraphData called==',JSON.stringify(result));
                self.graphData = result;
                self.graphData.influenceData = this.influenceData;
                self.graphData.supportData = this.supportData;
                self.graphData.badgeOptions = this.badgeOptions;
                console.log('==getGraphData called graphData==',JSON.stringify(self.graphData));
                this.publishMessage();
            })
            .catch((error) => {
                console.log('==getGraphData ERROR==',error);
                console.log('==getGraphData ERROR==');
                console.log('error.body.message'+JSON.stringify(error.body.message));
                this.updateErrorMessage(error.body.message);
                self.graphData = undefined;
            });
    }

    publishMessage() {
        const message = {
            recordId: this.recordId,
            action: 'refresh'
        };

        publish(this.messageContext, RELATIONSHIP_MAP_DATA_CHANNEL, message);
    }

    subscribeToChannel() {
        if (this.subscription) {
            return;
        }

        // Subscribing to the message channel
        this.subscription = subscribe(this.messageContext, MAP_MEMBER_LIST_DATA_CHANNEL, (message) => {
            this.handleMessage(message);
        });
        subscribe(this.messageContext, INFLUENCE_CHART_DATA_CHANNEL, (message) => {
            this.handleMessage(message);
        });
    }

    handleMessage(message) {
        if (message.action === 'refresh' && message.recordId === this.recordId) {
            this.handleUpdateGraph();
        }
    }

    createErrorEvent(error) {
        if (this.errorMessage) {
            return;
        }
        const graphErrorEvent = new CustomEvent('grapherror', { detail: { error: error } });

        this.dispatchEvent(graphErrorEvent);
    }

    graphError(event) {
        this.createErrorEvent(event.detail.error);
    }

    updateSaving(isSaving) {
        const rmc = this.template.querySelector('c-account-relationship-map-controller');

        if (rmc && rmc.updateSaving) {
            console.log('===isSaving===');
            rmc.updateSaving(isSaving);
        }
    }
    //need to send Account relationship Map Id dynamically relationshipMapId
    addMembers(event) {
        console.log('===addMembers=== called');
        let contactIds = [];

        event.detail.nodeDataArray.forEach((node) => {
            contactIds.push(node.key);
        });

        const gd = {
            nodeDataArray: event.detail.nodeDataArray,
            linkDataArray: []
        };

        let graphDataJsonString = JSON.stringify(gd);
        let relationshipMapId = this.accRelMapId;
        let acId = this.accId;
        let mapOrAccountPlanId = this.recordId;
        console.log('====accId in Acc Plan==='+acId);
        console.log('====mapOrAccountPlanId in AccountrelationshipMap==='+mapOrAccountPlanId);

        try {
            // Switch on type being added, fork to add Contacts or Users
            console.log('==gd.nodeDataArray[0].category=='+gd.nodeDataArray[0].category);
            switch (gd.nodeDataArray[0].category) {
                case 'keystakeholder':
                case 'account':
                this.passthroughEvent(event);
                /*addAccountToRelationshipMap({ relationshipMapId, graphDataJsonString })
                    .then((graphData) => {
                        if (event.detail.tempId) {
                            graphData.nodeDataArray.forEach((node) => {
                                node.tempId = event.detail.tempId;
                            });
                        }
                        this.template.querySelector('c-account-relationship-map-controller')?.updateNodes(graphData);
                        this.publishMessage();
                    })
                    .catch((error) => {
                        this.createErrorEvent(error);
                        this.retrieveData();
                    });*/
                break;

                case 'contact':
                    addContactToRelationshipMap({ relationshipMapId, graphDataJsonString })
                        .then((graphData) => {
                            if (event.detail.tempId) {
                                graphData.nodeDataArray.forEach((node) => {
                                    node.tempId = event.detail.tempId;
                                });
                            }
                            this.template.querySelector('c-account-relationship-map-controller')?.updateNodes(graphData);
                            this.publishMessage();
                        })
                        .catch((error) => {
                            this.createErrorEvent(error);
                            this.retrieveData();
                        });
                    break;
                
                case 'user':
                case 'manager':
                    addUserToRelationshipMap({ graphDataJsonString, mapOrAccountPlanId })
                        .then((graphData) => {
                            if (event.detail.tempId) {
                                graphData.nodeDataArray.forEach((node) => {
                                    node.tempId = event.detail.tempId;
                                });
                            }
                            this.template.querySelector('c-account-relationship-map-controller')?.updateNodes(graphData);
                            this.publishMessage();
                        })
                        .catch((error) => {
                            this.createErrorEvent(error);
                            this.retrieveData();
                        });
                    break;
                case 'lead':
                    addLeadToRelationshipMap({ graphDataJsonString, relationshipMapId })
                        .then((graphData) => {
                            if (event.detail.tempId) {
                                graphData.nodeDataArray.forEach((node) => {
                                    node.tempId = event.detail.tempId;
                                });
                            }
                            this.template.querySelector('c-account-relationship-map-controller')?.updateNodes(graphData);
                            this.publishMessage();
                        })
                        .catch((error) => {
                            this.createErrorEvent(error);
                            this.retrieveData();
                        });
                    break;
                case null:
                    return null;
                default:
                    return null;
            }
        } catch (error) {
            this.createErrorEvent(error);
            this.retrieveData();
        }

        return null;
    }

    // Get Parent Nodes
    handleAddParentContactsToChart(event) {
        const contactIds = event.detail;

        this.updateSaving(true);
        getParentNodes({ contactIds: contactIds, mapOrAccountPlanId: this.recordId })
            .then((graphData) => {
                this.updateSaving(false);
                console.log('==parent node adding==');
                this.template.querySelector('c-account-relationship-map-controller').addParentNodes(graphData);
            })
            .catch((error) => {
                this.handleError(error);
            });
    }

    handleError(error) {
        this.updateSaving(false);
        this.createErrorEvent(error);
        this.retrieveData();
    }

    handleCloneClicked() {
        this.openCloneModal = true;
    }

    handleCloseClone() {
        this.openCloneModal = false;
    }

    handleDeleteMembers(event) {
        console.log('event.detail removeids: ',event.detail);
        deleteMembers({ memberIds: event.detail })
            .then(() => {
                this.publishMessage();
            })
            .catch((error) => {
                this.createErrorEvent(error);
                this.retrieveData();
            });
    }

    handleDeleteMapMemberUsers(event) {
        deleteMapMemberUsers({ mapMemberUserIds: event.detail })
            .then(() => {
                this.publishMessage();
            })
            .catch((error) => {
                this.createErrorEvent(error);
                this.retrieveData();
            });
    }

    handleDeleteMapMemberLeads(event) {
        deleteMapMemberLeads({ stakeholderIds: event.detail })
            .then(() => {
                this.publishMessage();
            })
            .catch((error) => {
                this.createErrorEvent(error);
                this.retrieveData();
            });
    }

    handleUpdateGraph() {
        this.template.querySelector('c-account-relationship-map-controller').showMap(false);
        this.getSettingsAndData();
    }

    handlePerformSearch(event) {
        console.log('===event in handleperformsearch accountRelationshipMap===')
        console.log(event.detail)
        
        const { searchMode, searchTerm, excludeIds, accountId, searchKey } = event.detail;
        const mapOrAccountPlanId = this.recordId;

        this.currentSearchKey = searchKey;
        console.log('==currentSearchKey==='+this.currentSearchKey);
        console.log('==searchMode==='+searchMode);
        console.log('==searchTerm==='+searchTerm);
        console.log('==excludeIds==='+excludeIds);
        console.log('==searchMode==='+searchMode);
        console.log('==searchMode==='+searchMode);
        searchAccountRecords({ searchTerm, excludeIds, accountId, mapOrAccountPlanId, searchKey })
                .then((result) => {
                    if (this.currentSearchKey === result.searchKey) {
                        this.template
                            .querySelector('c-account-relationship-map-controller')
                            .handleSearchResults(result, 'account');
                    }
                })
                .catch((error) => {
                    this.createErrorEvent(error);
                });
        /*if (searchMode === 'user') {
            searchUserRecords({ searchTerm, excludeIds, mapOrAccountPlanId, searchKey })
                .then((result) => {
                    if (this.currentSearchKey === result.searchKey) {
                        this.template
                            .querySelector('c-account-relationship-map-controller')
                            .handleSearchResults(result, 'user');
                    }
                })
                .catch((error) => {
                    this.createErrorEvent(error);
                });
        } else if (searchMode === 'lead') {
            searchLeadRecords({ searchTerm, excludeIds, mapOrAccountPlanId, searchKey })
                .then((result) => {
                    if (this.currentSearchKey === result.searchKey) {
                        this.template
                            .querySelector('c-account-relationship-map-controller')
                            .handleSearchResults(result, 'lead');
                    }
                })
                .catch((error) => {
                    this.handleError(error);
                });
        } else if (searchMode === 'contact') {
            searchContactRecords({ searchTerm, excludeIds, accountId, mapOrAccountPlanId, searchKey })
                .then((result) => {
                    if (this.currentSearchKey === result.searchKey) {
                        this.template
                            .querySelector('c-account-relationship-map-controller')
                            .handleSearchResults(result, 'contact');
                    }
                })
                .catch((error) => {
                    this.createErrorEvent(error);
                });
        }
        else if (searchMode === 'account') {
            searchAccountRecords({ searchTerm, excludeIds, accountId, mapOrAccountPlanId, searchKey })
                .then((result) => {
                    if (this.currentSearchKey === result.searchKey) {
                        this.template
                            .querySelector('c-account-relationship-map-controller')
                            .handleSearchResults(result, 'account');
                    }
                })
                .catch((error) => {
                    this.createErrorEvent(error);
                });
        }*/
    }

    handleSetTargetAnchor(event) {
        const { rootNodeKey, anchorNodeKey } = event.detail;
        let objectId = this.recordId;

        this.updateSaving(true);
        setAnchor({ objectId, rootNodeKey, anchorNodeKey })
            .then(() => {
                this.updateSaving(false);
            })
            .catch((error) => {
                this.handleError(error);
            });
    }

    handleSaveAllNodeCoordinates(event) {
        let gd = {
            nodeDataArray: event.detail.nodeDataArray,
            linkDataArray: []
        };
        let graphDataJsonString = JSON.stringify(gd);
        let objectId = this.recordId;

        this.updateSaving(true);
        saveAllNodeCoordinates({ objectId, graphDataJsonString })
            .then(() => {
                this.updateSaving(false);
            })
            .catch((error) => {
                this.handleError(error);
            });
    }

    handleUpdateNodeCoordinates(event) {
        let gd = {
            nodeDataArray: event.detail.nodeDataArray,
            linkDataArray: []
        };
        let graphDataJsonString = JSON.stringify(gd);
        let objectId = this.recordId;

        this.updateSaving(true);
        updateNodeCoordinates({ objectId, graphDataJsonString })
            .then(() => {
                this.updateSaving(false);
            })
            .catch((error) => {
                this.handleError(error);
            });
    }

    // Placeholder
    handleCreateNewPlaceholder(event) {
        const graphData = { nodeDataArray: [event.detail.nodeData] };

        this.updateSaving(true);
        createNewPlaceholder({
            graphDataJsonString: JSON.stringify(graphData),
            objectId: this.recordId
        })
            .then((nodeData) => {
                this.updateSaving(false);
                this.template.querySelector('c-account-relationship-map-controller').updateLocalNodeData(nodeData);
            })
            .catch((error) => {
                this.handleError(error);
            });
    }

    @api
    handleApplicationEvent(eventName, eventValue) {
        const rmc = this.template.querySelector('c-account-relationship-map-controller');

        if (rmc) {
            rmc.handleApplicationEvent(eventName, eventValue);
        }
    }

    @api
    handleBubbledApplicationEvent(eventName, eventValue, refreshViews) {
        switch (eventName) {
            case 'RM_HIERARCHY_UPDATED':
            case 'RM_EDIT_SETTINGS_SAVE_SUCCESS':
            case 'RM_EDIT_RECORD_SAVE_SUCCESS':
                this.publishMessage();
                break;
            default:
                break;
        }
        this.fireApplicationEvent(eventName, eventValue, refreshViews);
    }

    fireApplicationEvent(eventName, eventValue, shouldUpdateSystemViews) {
        const evt = new CustomEvent('pqapplicationevent', {
            detail: { name: eventName, value: eventValue, refreshViews: shouldUpdateSystemViews }
        });

        this.dispatchEvent(evt);
    }

    passthroughEvent(event) {
        console.log('event.type: ',event.type);
        const passedEvent = new CustomEvent(event.type, {
            detail: event.detail
        });

        // Dispatches the event.
        this.dispatchEvent(passedEvent);
    }

    handleCreateNewGroup(event) {
        const memberIds = event.detail.memberIds;

        const graphData = { nodeDataArray: [event.detail.groupData] };

        this.updateSaving(true);
        createNewGroup({ graphDataJsonString: JSON.stringify(graphData), idList: memberIds, objectId: this.recordId })
            .then((graphNodeData) => {
                this.updateSaving(false);
                this.template.querySelector('c-account-relationship-map-controller').updateLocalNodeData(graphNodeData);
            })
            .catch((error) => {
                this.handleError(error);
            });
    }

    handleAddContactsToGroup(event) {
        const graphData = { nodeDataArray: [event.detail.groupData] };

        this.updateSaving(true);
        addContactsToGroup({
            graphDataJsonString: JSON.stringify(graphData),
            contactIds: event.detail.contactIds,
            mapOrAccountPlanId: this.recordId
        })
            .then(() => {
                this.updateSaving(false);
            })
            .catch((error) => {
                this.handleError(error);
            });
    }

    handleNewCustomLinks(event) {
        const graphData = { linkDataArray: event.detail };

        this.updateSaving(true);
        newCustomLinks({ graphDataJsonString: JSON.stringify(graphData), mapOrAccountPlanId: this.recordId })
            .then(() => {
                this.updateSaving(false);
            })
            .catch((error) => {
                this.handleError(error);
            });
    }

    // Hierarchy
    handleUpdateHierarchyLinks(event) {
        console.log('==full event detail===');
        console.log(event.detail);
        const graphData = { linkDataArray: event.detail };
        console.log('==handleUpdateHierarchyLinks called==');
        this.updateSaving(true);
        console.log('===stringifieddddddd===')
        console.log('===this.recordId==='+this.recordId)
        console.log(JSON.stringify(graphData))
        updateParentAccountId({ graphDataJsonString: JSON.stringify(graphData), mapOrAccountPlanId: this.recordId })
        .then(() => {
                console.log('==updateParentAccountId called==');
                this.updateSaving(false);
                let accountIds = [];

                graphData.linkDataArray.forEach((node) => {
                    console.log('===node.toKey.substr(0,18)==='+node.toKey.substr(0,18))
                    accountIds.push(node.toKey.substr(0,18));
                });
                this.fireApplicationEvent('RM_HIERARCHY_UPDATED', accountIds, true);
                this.publishMessage();
                //this handle search was called to refresh the side panel loaded accounts
                this.handlePerformSearch(event);
            })
            .catch((error) => {
                this.handleError(error);
            });
    }

    handleAssociateBadge(event) {
        this.updateSaving(true);
        associateBadge({
            mapOrAccountPlanId: this.recordId,
            badgeId: event.detail.badgeId,
            nodeIds: event.detail.nodeIds
        })
            .then(() => {
                this.updateSaving(false);
            })
            .catch((error) => {
                this.handleError(error);
                this.getSettingsAndData();
            });
    }

    handleRemoveBadge(event) {
        this.updateSaving(true);
        removeBadge({
            mapOrAccountPlanId: this.recordId,
            nodeIds: event.detail.nodeIds
        })
            .then(() => {
                this.updateSaving(false);
            })
            .catch((error) => {
                this.handleError(error);
            });
    }

    async handleObjectViewerRequested(event) {
        console.log('==handleObjectViewerRequested===')
        console.log('==event datil here=='+JSON.stringify(event.detail))
        const { typeHint, objectId } = event.detail;
        let modal;
        let canEdit = false;
        console.log('==typeHint== ' + typeHint);
        console.log('==objectId== ' + objectId);
        switch (typeHint) {
            case 'keystakeholder':
                if (this.canEditGraph) {
                    await getUserRecordAccess({ recordId: objectId }).then((access) => {
                        canEdit = access.HasAllAccess || access.HasEditAccess;
                    });
                }
                modal = this.template.querySelector('c-pq-matrix-member-modal');
                modal.open(
                    'pqcrush__Relationship_Map_Member__c',
                    objectId,
                    this.influenceData,
                    this.supportData,
                    {},
                    canEdit
                );
                break;

            case 'account':
                console.log('inside account');
                this.passthroughEvent(event);
                /*modal = this.template.querySelector('c-pq-matrix-member-modal');
                modal.open(
                    'Account',
                    objectId,
                    this.influenceData,
                    this.supportData,
                    {},
                    false
                );
                break;

            default:
                this.passthroughEvent(event);
                break;*/
        }
    }

    handleMatrixMemberSuccess(event) {
        this.template.querySelector('c-account-relationship-map-controller').updateInfluenceSupport(event.detail);
        this.publishMessage();
    }
}