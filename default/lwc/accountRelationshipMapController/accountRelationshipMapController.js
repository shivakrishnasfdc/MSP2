import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

// Groups

import addGroupsToGroup from '@salesforce/apex/GraphDataController.addGroupsToGroup';
import removeNodesFromGroup from '@salesforce/apex/GraphDataController.removeNodesFromGroup';
import updateGroupName from '@salesforce/apex/GraphDataController.updateGroupName';
import updateGroupLayout from '@salesforce/apex/GraphDataController.updateGroupLayout';

// Links
import deleteCustomLinks from '@salesforce/apex/GraphDataController.deleteCustomLinks';

import updateCustomLinks from '@salesforce/apex/GraphDataController.updateCustomLinks';

// Placeholder
import updatePlaceholderDescription from '@salesforce/apex/GraphDataController.updatePlaceholderDescription';
import updatePlaceholderNameAndLabel from '@salesforce/apex/GraphDataController.updatePlaceholderNameAndLabel';
import deletePlaceholders from '@salesforce/apex/GraphDataController.deletePlaceholders';

// Support
import getSupportColors from '@salesforce/apex/GraphDataController.getSupportColors';

// Object Info
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import REPORTS_TO_ID from '@salesforce/schema/Contact.ReportsToId';
import RelationshipGroupsObj from '@salesforce/schema/Relationship_Group__c';

// Get Account Id
import getAccountId from '@salesforce/apex/AccountService.getRelatedAccountIdForRecordId';

// User Record Access
import getAccessForObject from '@salesforce/apex/UserRecordAccessServiceController.getUserRecordAccess';

// Settings
import updateAutoLayout from '@salesforce/apex/RMChartSettingController.updateAutoLayout';
import updateCardStyle from '@salesforce/apex/RMChartSettingController.updateCardStyle';
import updateReadOnly from '@salesforce/apex/RMChartSettingController.updateReadOnly';
import updateCustomHierarchy from '@salesforce/apex/AccountHierarchyController.updateCustomHierarchy';


// Org Settings
// Import getRMOrgSetting from '@salesforce/apex/RMOrgSettingService.getRMOrgSetting';

// Custom Labels
import Click_Anywhere_To_Refresh from '@salesforce/label/c.Click_Anywhere_To_Refresh';
import Account_Hierarchy from '@salesforce/label/c.Account_Hierarchy';
import CUSTOMHIERARCHYLABEL from '@salesforce/label/c.Custom_Hierarchy_Label';
import Auto_Layout from '@salesforce/label/c.Auto_Layout';
import Manual_Layout from '@salesforce/label/c.Manual_Layout';
import Settings from '@salesforce/label/c.Settings';
import Members from '@salesforce/label/c.Accounts';
import Toggle_Extended_Profile_Fields from '@salesforce/label/c.Toggle_Extended_Profile_Fields';
import Zoom_In from '@salesforce/label/c.Zoom_In';
import Zoom_Out from '@salesforce/label/c.Zoom_Out';
import Refresh from '@salesforce/label/c.Refresh_Data';
import Full_Screen from '@salesforce/label/c.Full_Screen';
import Relationship_Map from '@salesforce/label/c.Relationship_Map';
import Saving from '@salesforce/label/c.Saving';
import Contact from '@salesforce/label/c.Contact';
import Clone from '@salesforce/label/c.Clone';
import Card_Detail from '@salesforce/label/c.Card_Detail';
import Switch_To_Auto_Layout from '@salesforce/label/c.Switch_To_Auto_Layout';
import Switch_To_Manual_Layout from '@salesforce/label/c.Switch_To_Manual_Layout';
import Hide_Extended_Fields from '@salesforce/label/c.Hide_Extended_Fields';
import Show_Extended_Fields from '@salesforce/label/c.Show_Extended_Fields';
import Switch_To_Compact_Cards from '@salesforce/label/c.Switch_To_Compact_Cards';
import Switch_To_Detailed_Cards from '@salesforce/label/c.Switch_To_Detailed_Cards';
import Switch_To_Fixed_Size_Cards from '@salesforce/label/c.Switch_To_Fixed_Size_Cards';
import User_Info from '@salesforce/label/c.User_Info';
import Create_New_Account from '@salesforce/label/c.Create_New_Account';
import Exit_Full_Screen from '@salesforce/label/c.Exit_Full_Screen';
import GlobalInfluence from '@salesforce/label/c.Global_Influence_And_Support';
import Undo from '@salesforce/label/c.Undo';
import Read_Only from '@salesforce/label/c.Read_Only';

export default class AccountRelationshipMapController extends NavigationMixin(LightningElement) {
    @track fullscreenClass = '';

    @track isSaving = false;

    @api anchors;

    @api recordId;

     canEditGraph=true;

    @api objectLabel;

    @api canCopyGraph = false;

    @api relationshipTypes = [];

    @api rmOrKeystakeholder = null;

    _graphData = null;

    showGraph = true;

    showAutoManualToggle = false;

    supportColors;

    allowCreateContact = false;

    allowCreateGroup = false;

    allowDrop = false;

    accountId;

    _chartSettings;

    _rmOrgSettings;

    _containerRecordId;

    modalTitle = '';

    objectApiName = '';

    mode = '';

    modalRecordId = null;

    openCreateModal = false;

    tempContact;

    autoLayout = false;

    callforaccountrecords=true;

    _readOnly = false;
    isSettingOpen = false;
    isCustomHierarchy = true;
    wireRecordId;
    label = {
        Click_Anywhere_To_Refresh,
        Account_Hierarchy,
        Auto_Layout,
        Manual_Layout,
        Settings,
        Members,
        Toggle_Extended_Profile_Fields,
        Undo,
        Read_Only,
        Zoom_In,
        Zoom_Out,
        Refresh,
        Full_Screen,
        Relationship_Map,
        Saving,
        Contact,
        Clone,
        Card_Detail,
        Create_New_Account,
        Switch_To_Auto_Layout,
        Switch_To_Manual_Layout,
        Hide_Extended_Fields,
        Show_Extended_Fields,
        Switch_To_Compact_Cards,
        Switch_To_Detailed_Cards,
        Switch_To_Fixed_Size_Cards,
        User_Info,
        Exit_Full_Screen,
        GlobalInfluence,
        CUSTOMHIERARCHYLABEL
    };

    layoutLabel = this.label.Auto_Layout;

    layoutMenuLabel = this.label.Switch_To_Auto_Layout;

    detailVisibility = false;

    extendedFieldVisibleLabel = this.label.Show_Extended_Fields;

    extendedFieldVisibleIcon = 'utility:chevrondown';

    cardStyle = 'Detail';

    cardStyleLabel = '';

    isGlobalInfluence = true;

    openSetting(event){
        this.isSettingOpen = true;
    }
    closeSetting(event){
        this.isSettingOpen = false;
    }

    handleTodoChange(event){
        console.log('==handleTodoChange called==');
        this.isCustomHierarchy = event.target.checked;
        console.log('==this.wireRecordId==='+this.recordId);
        console.log('==this._readOnly==='+this._readOnly);
        this.toggleReadOnly();
        // updateReadOnly({ recordId: this.recordId, readOnly: this._readOnly })
        //     .then(() => {
        //         this.updateSaving(false);
        //         console.log('Success');
        //     })
        //     .catch((error) => {
        //         this.handleError(error);
        //     });
        // updateCustomHierarchy({isHierarchy:this.isCustomHierarchy,recordId: this.recordId})
        //  .then(data => {
        //     console.log('Success');
        //  })
        //  .catch(error => {
        //      console.error('Error fetching hierarchy data', error);
        //  });
    }

    @api
    get graphData() {
        //  console.log('==getter graphData=='+JSON.stringify(this._graphData))

        return this._graphData;
    }

    set graphData(val) {
        this._graphData = val;
        //  console.log('==setter graphData=='+JSON.stringify(this._graphData))
        this.toggleGraph();
    }

    @api showMap(val) {
        this.showGraph = val;
        //  console.log('==showGraph=='+JSON.stringify(this.showGraph))
    }

    @api
    get chartSettings() {
        //  console.log('==getter chartSettings=='+JSON.stringify(this._chartSettings))
        return this._chartSettings;

    }

    set chartSettings(value) {
        this._chartSettings = value;
        this.autoLayout = this._chartSettings.autoLayout;
        this._readOnly = this._chartSettings.readOnly;
        this.cardStyle = this._chartSettings.cardStyle;
        this.isGlobalInfluence = this._chartSettings.isInfluenceSupportGlobal;
        // console.log('==_chartSettings=='+JSON.stringify(this._chartSettings))
        // console.log('==this.isGlobalInfluence=='+JSON.stringify(this.isGlobalInfluence))
        // console.log('==this.cardStyle=='+JSON.stringify(this.cardStyle))
        this.updateLabels();
    }

    @api
    get rmOrgSettings() {
        // console.log('==_rmOrgSettings=='+JSON.stringify(this._rmOrgSettings));
        return this._rmOrgSettings;
    }

    set rmOrgSettings(value) {
        this._rmOrgSettings = value;
        this.showAutoManualToggle = value?.pqcrush__Show_Auto_Manual_Toggle__c && this.canEditGraph;
    }

    // Get Account Id
    @api
    get containerRecordId() {
        return this._containerRecordId;
    }

    set containerRecordId(value) {
        this._containerRecordId = value;
        getAccountId({ recordId: value }).then((result) => {
            this.accountId = result;
        });
    }

    get showSettingsButton() {
        return (
            this.canEditGraph &&
            this.chartSettings &&
            this.chartSettings.isSettingsEnabled &&
            this.chartSettings.userCanAccessSettings
        );
    }

    get showCopyButton() {
        return (
            this.canCopyGraph &&
            this.chartSettings &&
            this.chartSettings.isCloneEnabled &&
            this.chartSettings.userCanClone
        );
    }
    get readOnly() {
        return this._readOnly;
    }
    

    toggleGraph() {
        this.showGraph = this.graphData && this.supportColors;
    }

    // Object Info DAI
    @wire(getObjectInfo, { objectApiName: RelationshipGroupsObj })
    wiredCheckGroupCreate({ data }) {
        if (data) {
            console.log('==data.createable=='+data.createable); 
            this.allowCreateGroup = data.createable;
        }
    }

    // Object Info
    @wire(getObjectInfo, { objectApiName: REPORTS_TO_ID.objectApiName })
    wiredCheckReportsTo({ data }) {
        if (data) {
            this.allowDrop = data.fields[REPORTS_TO_ID.fieldApiName].updateable;
            this.allowCreateContact = data.createable;
            console.log('==allowDrop=='+JSON.stringify(this.allowDrop));
            console.log('==allowCreateContact=='+JSON.stringify(this.allowCreateContact));
            // console.log('==data=='+JSON.stringify(data));
        }
    }

    updateLabels() {
        this.layoutMenuLabel = this.autoLayout ? this.label.Switch_To_Manual_Layout : this.label.Switch_To_Auto_Layout;
        this.layoutLabel = this.autoLayout ? this.label.Auto_Layout : this.label.Manual_Layout;

        this.extendedFieldVisibleLabel = this.extendedFieldVisible
            ? this.label.Hide_Extended_Fields
            : this.label.Show_Extended_Fields;

        this.extendedFieldVisibleIcon = this.extendedFieldVisible ? 'utility:chevronup' : 'utility:chevrondown';
        console.log('==cardStyle=='+JSON.stringify(this.cardStyle));
        console.log('==this.label.Switch_To_Compact_Cards=='+JSON.stringify(this.label.Switch_To_Compact_Cards));
        console.log('==layoutMenuLabel=='+JSON.stringify(this.layoutMenuLabel));
        console.log('==layoutLabel=='+JSON.stringify(this.layoutLabel));
        console.log('==extendedFieldVisibleLabel=='+JSON.stringify(this.extendedFieldVisibleLabel));
        switch (this.cardStyle) {
            case 'Detail':
                this.cardStyleLabel = this.label.Switch_To_Compact_Cards;
                break;
            case 'Compact':
                this.cardStyleLabel = this.label.Switch_To_Fixed_Size_Cards;
                break;
            case 'FixedSize':
                this.cardStyleLabel = this.label.Switch_To_Detailed_Cards;
                break;
            default:
                break;
        }
    }

    // Action Bar

    manageMembers() {
        console.log('==manageMembers==called==')
        this.template.querySelector('c-accountorggraph')?.showContactLookup();
        this.redrawGraph();
    }
    
    toggleReadOnly() {
        console.log('==toggleReadOnly==called==')
        this._readOnly = this.template.querySelector('c-accountorggraph')?.toggleReadOnly();
        console.log('==this._readOnly=='+JSON.stringify(this._readOnly));
        this.updateSaving(true);
        updateReadOnly({ recordId: this.recordId, readOnly: this._readOnly })
            .then(() => {
                this.updateSaving(false);
            })
            .catch((error) => {
                this.handleError(error);
            });
    }

    increaseZoom() {
        this.template.querySelector('c-accountorggraph')?.increaseZoom();
    }

    decreaseZoom() {
        this.template.querySelector('c-accountorggraph')?.decreaseZoom();
    }

    undoChanges() {
        this.template.querySelector('c-accountorggraph')?.undoChanges();
        this._readOnly = false;
    }

    reloadData() {
        this.createUpdateGraphEvent();
    }

    fullScreenHandler() {
        this.isExpanded = !this.isExpanded;
        console.log('==this.isExpanded=='+JSON.stringify(this.isExpanded));
        if (this.isExpanded) {
            document.body.style.overflow = 'hidden';
            this.fullscreenClass = 'fullScreen';
        } else {
            document.body.style.overflow = '';
            this.fullscreenClass = '';
        }
    }

    // Side Panel Management

    handleClosePanel() {
        this.template.querySelector('c-accountorggraph')?.closeSidePanel();
        this.redrawGraph();
    }

    redrawGraph() {
        this.template.querySelector('c-accountorggraph')?.redrawGraph();
    }

    @api
    handleSearchResults(data, mode) {
        this.template.querySelector('c-accountorggraph')?.handleSearchResults(data, mode);
    }

    @api
    updateLocalNodeData(nodeData) {
        this.template.querySelector('c-accountorggraph')?.updateLocalNodeData(nodeData);
    }

    @api
    updateInfluenceSupport(data) {
        this.template.querySelector('c-accountorggraph')?.updateInfluenceSupport(data);
    }

    @api
    updateSaving(isSaving) {
        this.isSaving = isSaving;
    }

    // Groups

    handleAddGroupsToGroup(event) {
        console.log('==handleAddGroupsToGroup==');
        const graphData = { nodeDataArray: [event.detail.groupData] };
        console.log('===graphData=== ' + JSON.stringify(graphData));
        this.updateSaving(true);
        addGroupsToGroup({
            graphDataJsonString: JSON.stringify(graphData),
            groupIds: event.detail.groupIds
        })
            .then(() => {
                this.updateSaving(false);
            })
            .catch((error) => {
                this.handleError(error);
            });
    }

    handleRemoveNodesFromGroup(event) {
        console.log('==handleRemoveNodesFromGroup==');
        const graphData = { nodeDataArray: event.detail };
        console.log('===graphData=== ' + JSON.stringify(graphData));
        this.updateSaving(true);
        removeNodesFromGroup({ graphDataJsonString: JSON.stringify(graphData) })
            .then(() => {
                this.updateSaving(false);
            })
            .catch((error) => {
                this.handleError(error);
            });
    }

    handleGroupNameChange(event) {
        
        const graphData = { nodeDataArray: [event.detail.groupData] };
        console.log('==handleRemoveNodesFromGroup==');
        console.log('===graphData=== ' + JSON.stringify(graphData));
        this.updateSaving(true);
        updateGroupName({ graphDataJsonString: JSON.stringify(graphData), newName: event.detail.newName })
            .then(() => {
                this.updateSaving(false);
            })
            .catch((error) => {
                this.handleError(error);
            });
    }

    // Links
    handleDeleteCustomLinks(event) {
        const graphData = { linkDataArray: event.detail };
        console.log('==handleDeleteCustomLinks==');
        console.log('===graphData=== ' + JSON.stringify(graphData));
        this.updateSaving(true);
        deleteCustomLinks({ graphDataJsonString: JSON.stringify(graphData) })
            .then(() => {
                this.updateSaving(false);
            })
            .catch((error) => {
                this.handleError(error);
            });
    }

    handleUpdateCustomLinks(event) {
        const graphData = { linkDataArray: event.detail };
        console.log('==handleUpdateCustomLinks==');
        console.log('===graphData=== ' + JSON.stringify(graphData));
        this.updateSaving(true);
        updateCustomLinks({ graphDataJsonString: JSON.stringify(graphData) })
            .then(() => {
                this.updateSaving(false);
            })
            .catch((error) => {
                this.handleError(error);
            });
    }

    // Placeholder
    handleUpdatePlaceholderDescription(event) {
        const graphData = { nodeDataArray: [event.detail.nodeData] };
        console.log('==handleUpdatePlaceholderDescription==');
        console.log('===graphData=== ' + JSON.stringify(graphData));
        this.updateSaving(true);
        updatePlaceholderDescription({
            graphDataJsonString: JSON.stringify(graphData),
            newDescription: event.detail.newDescription
        })
            .then(() => {
                this.updateSaving(false);
            })
            .catch((error) => {
                this.handleError(error);
            });
    }

    handleUpdatePlaceholderNameAndLabel(event) {
        const graphData = { nodeDataArray: [event.detail.nodeData] };
        console.log('==handleUpdatePlaceholderNameAndLabel==');
        console.log('===graphData=== ' + JSON.stringify(graphData));
        this.updateSaving(true);
        updatePlaceholderNameAndLabel({
            graphDataJsonString: JSON.stringify(graphData),
            newLabel: event.detail.newLabel
        })
            .then(() => {
                this.updateSaving(false);
            })
            .catch((error) => {
                this.handleError(error);
            });
    }

    handleDeletePlaceholders(event) {
        console.log('==handleDeletePlaceholders==');
        console.log('===event.detail=== ' + JSON.stringify(event.detail));
        this.updateSaving(true);
        deletePlaceholders({
            placeholderIds: event.detail
        })
            .then(() => {
                this.updateSaving(false);
            })
            .catch((error) => {
                this.handleError(error);
            });
    }

    handleGroupLayoutChange(event) {
        const { groupId, type } = event.detail;
        console.log('==handleDeletePlaceholders==');
        console.log('===groupId=== ' + groupId+'==type=='+type);
        this.updateSaving(true);
        updateGroupLayout({
            groupId,
            type
        })
            .then(() => {
                this.template.querySelector('c-accountorggraph')?.updateGroupData(groupId, type);
                this.updateSaving(false);
            })
            .catch((error) => {
                this.handleError(error);
            });
    }

    @wire(getSupportColors, {})
    wiredSupportData({ error, data }) {
        if (data) {
            this.supportColors = data;
            this.toggleGraph();
        } else if (error) {
            this.createErrorEvent(error);
        }
    }

    passthroughEvent(event) {
        const passedEvent = new CustomEvent(event.type, {
            detail: event.detail
        });

        // Dispatches the event.
        this.dispatchEvent(passedEvent);
    }

    @api
    addParentNodes(graphData) {
        this.template.querySelector('c-accountorggraph')?.addParentNodes(graphData);
    }

    handleError(error) {
        this.updateSaving(false);
        this.createErrorEvent(error);
        this.createUpdateGraphEvent();
    }

    // Pass Error Event Up
    createErrorEvent(error) {
        const graphErrorEvent = new CustomEvent('grapherror', { detail: { error: error } });

        this.dispatchEvent(graphErrorEvent);
    }

    createUpdateGraphEvent() {
        const updateGraphEvent = new CustomEvent('updategraph', { detail: {} });

        this.dispatchEvent(updateGraphEvent);
    }

    // Pass Up Edit Info Clicked
    handleObjectViewerRequested(event) {
        this.updateSaving(true);
        getAccessForObject({ recordId: event.detail.objectId })
            .then((result) => {
                this.updateSaving(false);
                event.detail.access = result;
                if (event.detail.typeHint === 'keystakeholder') {
                    event.detail.objectLabel = this.objectLabel;
                } else if (event.detail.typeHint === 'account') {
                    event.detail.objectLabel = 'Account';
                }
                const objectEditClickedEvent = new CustomEvent('requestobjectviewer', {
                    detail: event.detail
                });

                // Dispatches the event.
                this.dispatchEvent(objectEditClickedEvent);
            })
            .catch((error) => {
                this.handleError(error);
            });
    }

    // Application events
    @api
    handleApplicationEvent(eventName, eventValue) {
        switch (eventName) {
            case 'RM_HIERARCHY_UPDATED':
                this.fireApplicationEvent('REFRESH_HISTORY', eventValue, false);
                this.fireApplicationEvent('STAKEHOLDER_UPDATE', eventValue, true);
                break;
            case 'RM_EDIT_SETTINGS_SAVE_SUCCESS':
            case 'RM_EDIT_RECORD_SAVE_SUCCESS':
                this.reloadData();
                this.fireApplicationEvent('REFRESH_HISTORY', eventValue, false);
                this.fireApplicationEvent('STAKEHOLDER_UPDATE', eventValue, true);
                break;
            case 'MATRIX_UPDATED':
                this.reloadData();
                break;
            default:
                break;
        }
    }

    fireApplicationEvent(eventName, eventValue, shouldUpdateSystemViews) {
        const evt = new CustomEvent('pqapplicationevent', {
            detail: { name: eventName, value: eventValue, refreshViews: shouldUpdateSystemViews }
        });

        this.dispatchEvent(evt);
    }

    // Update nodes bypass
    @api
    updateNodes(graphData) {
        this.template.querySelector('c-accountorggraph')?.updateNodes(graphData);
    }

    handleCreateNewContact(event) {
        this.tempContact = event.detail.nodeData;
        this.modalTitle = this.label.Create_New_Account;
        this.objectApiName = 'Account';
        this.mode = 'edit';
        this.modalRecordId = '';
        this.template.querySelector('c-account-lds-record-form-modal').open('Account');
    }

    handleViewUser(event) {
        this.modalRecordId = event.detail.userId;
        this.modalTitle = this.label.User_Info;
        this.objectApiName = 'User';
        this.mode = 'readonly';
        this.template.querySelector('c-lds-record-form-modal').open('User');
    }

    handleCreateNewTask(event) {
        let contactId = event.detail.contactId;
        let ownerId = event.detail.userId;
        let containerId = this._containerRecordId;
        let defaultValues = '';

        if (ownerId) {
            defaultValues = 'OwnerId=' + ownerId + ',';
        }
        if (contactId) {
            defaultValues = defaultValues + 'WhoId=' + contactId + ',';
        }
        if (containerId) {
            defaultValues = defaultValues + 'WhatId=' + containerId;
        }

        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Task',
                actionName: 'new'
            },
            state: {
                count: '1',
                nooverride: '1',
                useRecordTypeCheck: '1',
                defaultFieldValues: defaultValues,
                navigationLocation: 'RELATED_LIST'
            }
        });

        let recordType = 'Task';

        const evt = new CustomEvent('createnewtask', {
            detail: { ownerId, containerId, contactId, recordType }
        });

        this.dispatchEvent(evt);
    }

    handleModalSuccess(event) {
        console.log('==handleModalSuccess== called');
        this.openCreateModal = false;
        /*if (event?.detail?.tempNode) {
            let tempNode = event.detail.tempNode;
            tempNode.key = event.detail.objectId;
            console.log('==handleModalSuccess called in ACCRelationshipMapcontroller==');

            console.log('==tempnode=='+JSON.stringify(tempNode))
            const createContactEvent = new CustomEvent('addnodestochart', {
                detail: {
                    tempId: tempNode.tempId,
                    nodeDataArray: [tempNode]
                }
            });

            this.dispatchEvent(createContactEvent);
        }*/
    }

    handleModalCancel(event) {
        this.openCreateModal = false;
        if (event?.detail?.tempId) {
            this.template.querySelector('c-accountorggraph')?.cancelCreateContact(event.detail.tempId);
        }
    }

    handleAutoLayoutClick() {
        this.autoLayout = !this.autoLayout;
        this.updateLabels();
        this.updateSaving(true);
        updateAutoLayout({ recordId: this.recordId, autoLayout: this.autoLayout })
            .then(() => {
                this.updateSaving(false);
            })
            .catch((error) => {
                this.handleError(error);
            });
    }

    handleUpdateProfileImage(event) {
        let contactId = event.detail.contactId;

        this.template.querySelector('c-profile-image-picker').showModal(contactId);
    }

    handleProfileImageDataChange(event) {
        this.template
            .querySelector('c-accountorggraph')
            .updateProfileImageData(event.detail.contactId, event.detail.base64Data);
    }

    handleMenuSelect(event) {
        const selected = event.detail.value;

        switch (selected) {
            case 'settings':
                this.dispatchEvent(new CustomEvent('settingsclicked', {}));
                break;
            case 'clone':
                this.dispatchEvent(new CustomEvent('cloneclicked', {}));
                break;
            case 'carddetail':
                switch (this.cardStyle) {
                    case 'Detail':
                        this.cardStyle = 'Compact';
                        break;
                    case 'Compact':
                        this.cardStyle = 'FixedSize';
                        break;
                    case 'FixedSize':
                        this.cardStyle = 'Detail';
                        break;
                    default:
                        break;
                }
                updateCardStyle({ recordId: this.recordId, cardStyle: this.cardStyle })
                    .then(() => {
                        this.createUpdateGraphEvent();
                    })
                    .catch((error) => {
                        this.handleError(error);
                    });
                this.updateLabels();
                break;
            case 'refresh':
                this.createUpdateGraphEvent();
                break;
            case 'extendedfield':
                this.extendedFieldVisible = !this.extendedFieldVisible;
                this.template.querySelector('c-accountorggraph')?.toggleDetailVisibility(this.extendedFieldVisible);
                this.updateLabels();
                break;
            case 'fullScreenHandler':
                this.fullScreenHandler();
                break;
            case 'layout':
                this.handleAutoLayoutClick();
                break;
            default:
                break;
        }
    }
    handleBlockRefresh(){
        console.log('account handleBlockRefresh>>>');
        let transparentLayer = this.template.querySelector("[data-name='transparent-layer']");
        transparentLayer.setAttribute('class', 'transparent-layer');
    }

    transparencylLayerClicked(event) {
        event.currentTarget.setAttribute('class', 'slds-hide');
        this.reloadData();
    }
    connectedCallback() {
       console.log('recordId>>>>>>>>'+this.recordId);
    }
}