import { LightningElement, api, wire } from 'lwc';
import { subscribe, publish, MessageContext } from 'lightning/messageService';
import INFLUENCE_CHART_DATA_CHANNEL from '@salesforce/messageChannel/influenceChartData__c';
import RELATIONSHIP_MAP_DATA_CHANNEL from '@salesforce/messageChannel/relationshipMapData__c';
import MAP_MEMBER_LIST_DATA_CHANNEL from '@salesforce/messageChannel/mapMemberListData__c';

// Apex calls
import getMapMembersByAccountPlan from '@salesforce/apex/RelationshipMapMemberController.getMapMembersByAccountPlan';
import getDatatableColumns from '@salesforce/apex/RelationshipMapMemberController.getDatatableColumns';
import getMatrixByAccountPlan from '@salesforce/apex/RelationshipMapMemberController.getMatrixByAccountPlan';
import getMatrixByRelationshipMap from '@salesforce/apex/RelationshipMapMemberController.getMatrixByRelationshipMap';
import getUserRecordAccess from '@salesforce/apex/UserRecordAccessServiceController.getUserRecordAccess';
import getMatrixMembers from '@salesforce/apex/InfluenceSupportMatrixController.getMatrixMembers';
import getMapParent from '@salesforce/apex/RelationshipMapMemberController.getParentIdForRelationshipMapId';
import getMapId from '@salesforce/apex/RelationshipMapMemberController.getMapIdForSObjectIdNoCreate';
import getPicklistValues from '@salesforce/apex/InfluenceSupportMatrixController.getPicklistValues';
// Labels
import Edit from '@salesforce/label/c.Edit';
import Influence from '@salesforce/label/c.Influence';
import Support from '@salesforce/label/c.Support';

export default class DataTableRelMapMember extends LightningElement {
    labels = {
        Edit,
        Influence,
        Support
    };

    @api recordId;

    @api objectApiName;

    @api title = 'Map Members';

    @api columns = 'pqcrush__Contact__r.Name,pqcrush__InfluenceId__r.Name,pqcrush__SupportId__r.Name,pqcrush__Contact__r.ReportsTo.Name';

    @api sortableFields = 'pqcrush__Contact__r.Name,pqcrush__InfluenceId__r.Name,pqcrush__SupportId__r.Name,pqcrush__Contact__r.ReportsTo.Name';

    @api sortedBy = 'name';

    @api sortedDirection = 'asc';

    @api useRelativeMaxHeight = false;

    @api customRelativeMaxHeight;

    @api showOpportunitiesForDescendentAccounts = false;

    @api filtersBasedOnData = false;

    accountId;

    mapId;

    showSpinner = false;

    filterObj = null;

    subscription = null;

    loaded = false;

    influence = [];

    support = [];

    canEditParentRecord = false;

    matrixData;

    statusOptions = [];

    UserOptions = [];

    mapMemData=[];
    mapMemColumns=[];
    mapMemColumns1=[{
            label: 'Name',
            fieldName: 'pqcrush__Contact__r_Nameurl',
            type: 'url',
            typeAttributes: {label: { fieldName: 'pqcrush__Contact__r_Name' }, 
            target: '_blank'},
            sortable: true
        },
        {
            label: 'Name',
            fieldName: 'pqcrush__InfluenceId__r_Nameurl',
            type: 'url',
            typeAttributes: {label: { fieldName: 'pqcrush__InfluenceId__r_Name' }, 
            target: '_blank'},
            sortable: true
        },
        {
            label: 'Name',
            fieldName: 'pqcrush__InfluenceId__r_Nameurl',
            type: 'url',
            typeAttributes: {label: { fieldName: 'pqcrush__InfluenceId__r_Name' }, 
            target: '_blank'},
            sortable: true
        },
        //{fieldName:'pqcrush__Contact__r_Name', label:'Name', type:'text'},
        //{fieldName:'pqcrush__InfluenceId__r_Name', label:'Influence', type:'text'},
        //{fieldName:'pqcrush__InfluenceId__r_Name', label:'Support', type:'text'},
        //{fieldName:'pqcrush__Contact__r_ReportsTo_Name', label:'Reports To', type:'text'}
        {
            label: 'Name',
            fieldName: 'pqcrush__Contact__r_ReportsTo_Nameurl',
            type: 'url',
            typeAttributes: {label: { fieldName: 'pqcrush__Contact__r_ReportsTo_Name' }, 
            target: '_blank'},
            sortable: true
        }
        /*{fieldName='pqcrush__Contact__r_Name', label: 'Full Name', type: 'text', typeAttributes: {columnName: 'Name', fieldApiName: 'Name', href: {fieldName: 'pqcrush__Contact__r_Id'}, objectApiName: 'Contact', target: '_parent'}}, 
        {fieldName: 'pqcrush__InfluenceId__r_Name', label: 'Influence Name', type: 'text', typeAttributes: {columnName: 'Name', fieldApiName: 'Name', href: {fieldName: 'pqcrush__InfluenceId__r_Id'}, objectApiName: 'pqcrush__pq_Influence__c', target: '_parent'}}, 
        {fieldName: 'pqcrush__SupportId__r_Name', label: 'Support Name', type: 'text', typeAttributes: {columnName: 'Name', fieldApiName: 'Name', href: {fieldName: 'pqcrush__SupportId__r_Id'}, objectApiName: 'pqcrush__pq_Support__c', target: '_parent'}}, 
        {fieldName: 'pqcrush__Contact__r_ReportsTo_Name', label: 'Full Name', type: 'text', typeAttributes: {columnName: 'Name', fieldApiName: 'Name', href: {fieldName: 'pqcrush__Contact__r.ReportsTo_Id'}, objectApiName: 'Contact', target: '_parent'}}*/
    ];
    @api columnAPIs='pqcrush__Contact__r.Name,pqcrush__InfluenceId__r.Name,pqcrush__SupportId__r.Name,pqcrush__Contact__r.ReportsTo.Name';
    @api columnLabels='Name, Influence, Support, Reports To';
    @api columnTypes='url,text,text,url';

    @wire(MessageContext) messageContext;

    get baseDatatable() {
        return this.template.querySelector('c-pq-datatable');
    }

    async connectedCallback() {
        await this.getParentPermission();
        await this.getMatrix();
        await this.initializeTable();
        if(this.messageContext){
            this.subscribeToChannel();
        }
        console.log('this.recordId apexColumns:: ',this.recordId);
        console.log('this.sortableFields apexColumns:: ',this.sortableFields);
        getDatatableColumns({fieldsString: this.columns, objectString: 'pqcrush__Relationship_Map_Member__c', sortableString: this.sortableFields})
        .then((result) => {
            console.log('result apexColumns:: ',result);
            this.mapMemColumns = result;
            console.log('mapMemColumns apexColumns:: ',this.mapMemColumns);
            /*console.log('result apexColumns parse:: ',JSON.parse(result));
            console.log('result apexColumns stringify:: ',JSON.stringify(result));
            this.mapMemColumns = result;
            const parsedColumns = JSON.parse(result);*/
                /*this.statusOptions = Object.keys(parsedMap).map(key => ({
                label: key,
                value: parsedMap[key]
            }));*/
            })
            .catch(() => {
                 console.log('error.message mapMemColumns');
            });
        getPicklistValues({objectName: 'pqcrush__Relationship_Map_Member__c' , fieldName: 'pqcrush__Support__c'})
        .then((result) => {
            const parsedMap = JSON.parse(result);
                this.statusOptions = [
                                        { label: 'All', value: '' }, // Add the "--None--" option with an empty value
                                        ...Object.keys(parsedMap).map(key => ({
                                            label: key,
                                            value: parsedMap[key]
                                        }))
                                    ];
            })
        getMapMembersByAccountPlan({accountPlanId: this.recordId , queryFileds: this.columns})
        .then((result) => {
            let mapMemResult = result;
            console.log('mapMemResult : ',JSON.stringify(mapMemResult));
            let columnsFields = this.columns.split(',');;
            mapMemResult.forEach(row => {
                let recordObj = {};
                //recordObj.pqcrush__Contact__r_Name = row.pqcrush__Contact__r.Name;
                recordObj.Id = row.Id;
                columnsFields.forEach(field => {
                    console.log('columnsFields.forEach(field : ',field);
                    let fieldTrim = field.trim();
                    let fieldName = fieldTrim.replaceAll('.', '_');
                    let fieldsArray = fieldTrim.split('.');
                    console.log('fieldsArray.length : ',fieldsArray.length);
                        if(fieldsArray.length == '2'){
                            if(row.hasOwnProperty(fieldsArray[0]) && row[fieldsArray[0]][fieldsArray[1]]){
                                console.log('row[fieldsArray[0]][fieldsArray[1]] : ',row[fieldsArray[0]][fieldsArray[1]]);
                                recordObj[fieldName] = row[fieldsArray[0]][fieldsArray[1]];
                                let urlField = fieldName+'url';
                                recordObj[urlField] = '/'+row[fieldsArray[0]].Id;
                                console.log('recordObj[urlField]:: ',recordObj[urlField]);
                            }
                        }
                        else if(fieldsArray.length == '3'){
                            console.log('row.hasOwnProperty(fieldsArray[0]): ',row.hasOwnProperty(fieldsArray[0]));
                            if(row.hasOwnProperty(fieldsArray[0])){
                            console.log('row[fieldsArray[0]]',row[fieldsArray[0]]);
                            console.log('row[fieldsArray[0]].hasOwnProperty([fieldsArray[1]])',row[fieldsArray[0]].hasOwnProperty([fieldsArray[1]]));
                            }
                            if(row.hasOwnProperty(fieldsArray[0]) && row[fieldsArray[0]].hasOwnProperty([fieldsArray[1]])){
                                console.log('row[fieldsArray[0]][fieldsArray[1]][fieldsArray[2]]',row[fieldsArray[0]][fieldsArray[1]][fieldsArray[2]]);
                            }
                            //if(row.hasOwnProperty(fieldsArray[0]) && row[fieldsArray[0]].hasOwnProperty([fieldsArray[1]]) && row[fieldsArray[0]][fieldsArray[1]][fieldsArray[2]]){
                            if(row.hasOwnProperty(fieldsArray[0]) && row[fieldsArray[0]].hasOwnProperty([fieldsArray[1]])){
                                recordObj[fieldName] = row[fieldsArray[0]][fieldsArray[1]][fieldsArray[2]];
                                let urlField = fieldName+'url';
                                recordObj[urlField] = '/'+row[fieldsArray[0]][fieldsArray[1]].Id;
                            }
                        }
                        else if(fieldsArray.length == '1'){
                            recordObj[fieldName] = row[fieldsArray[0]];
                        }
                        //recordObj[fieldName] = row[field];
                });
                this.mapMemData.push(recordObj);
            });
            console.log('this.mapMemData : ',JSON.stringify(this.mapMemData));
            })
        await this.initializeTable();
    }

    async getParentPermission() {
        this.mapId = await getMapId({ recordId: this.recordId });
        this.parentId = await getMapParent({ mapId: this.mapId });
        if (this.parentId) {
            await getUserRecordAccess({ recordId: this.parentId }).then((access) => {
                this.canEditParentRecord = access.HasAllAccess || access.HasEditAccess;
            });
        } else {
            this.canEditParentRecord = true;
        }
    }

    publishMessage() {
        const message = {
            recordId: this.mapId,
            action: 'refresh'
        };

        publish(this.messageContext, MAP_MEMBER_LIST_DATA_CHANNEL, message);
    }

    subscribeToChannel() {
        if (this.subscription) {
            return;
        }

        // Subscribing to the message channel
        this.subscription = subscribe(this.messageContext, INFLUENCE_CHART_DATA_CHANNEL, (message) => {
            this.handleMessage(message);
        });
        subscribe(this.messageContext, RELATIONSHIP_MAP_DATA_CHANNEL, (message) => {
            this.handleMessage(message);
        });
    }

    handleMessage(message) {
        if (message.action === 'refresh' && message.recordId === this.mapId) {
            this.handleRefresh();
        }
    }

    async initializeTable() {
        let tableData = [];
        const listColumnsString = this.columns?.split(',');
        const additionalFields = listColumnsString?.map((item) => {
            return item.trim();
        });
        const mapOrAccountPlanId = this.recordId;

        this.loaded = false;
        await getMatrixMembers({ mapOrAccountPlanId, additionalFields })
            .then((result) => {
                console.log('result : '+JSON.stringify(result));
                tableData = result;
                this.loaded = true;
            })
            .catch(() => {
                // console.log(error.message);
            });

        const actions = [{ label: this.labels.Edit, name: 'edit' }];

        const influenceLabel = this.matrixData?.influenceLabel ? this.matrixData.influenceLabel : this.labels.Influence;
        const supportLabel = this.matrixData?.supportLabel ? this.matrixData.supportLabel : this.labels.Support;

        let tableColumns = [
            {
                label: 'Name',
                type: 'customName',
                fieldName: 'name',
                typeAttributes: {
                    href: {
                        fieldName: 'personId'
                    },
                    target: '_target',
                    columnName: 'Name',
                    objectApiName: 'Contact',
                    fieldApiName: 'Name'
                }
            },
            {
                label: influenceLabel,
                type: 'text',
                fieldName: 'influence'
            },
            {
                label: supportLabel,
                type: 'text',
                fieldName: 'support'
            }
        ];

        if (tableData && tableData.length > 0) {
            tableData[0]?.additionalFields?.forEach((item) => {
                if (item.type === 'id') {
                    tableColumns.push({
                        label: item.label,
                        type: 'customName',
                        fieldName: item.name,
                        typeAttributes: {
                            href: {
                                fieldName: 'additionalFields.value.' + item.name
                            },
                            target: '_target',
                            columnName: item.name,
                            objectApiName: 'Contact',
                            fieldApiName: 'Name'
                        }
                    });
                } else {
                    tableColumns.push({
                        type: this.getLocalType(item.type),
                        label: item.label,
                        fieldName: 'additionalFields.value.' + item.name
                    });
                }
            });

            tableData.forEach((item) => {
                item?.additionalFields?.forEach((field) => {
                    item[field.name] = field.value;
                    item[field.name] = field.valueDisplay;
                });
            });
        }

        // Add actions
        if (this.canEditParentRecord) {
            tableColumns.push({
                type: 'action',
                typeAttributes: { rowActions: actions }
            });
        }
       this.UserOptions = [];
       this.UserOptions.push({
                        label: '--None--',
                        value: 'None'
                    });
       tableData.forEach(item => {
        console.log(JSON.stringify(item));
        if (item.additionalFields && item.additionalFields.length > 0) {
            item.additionalFields.forEach(field => {
                if (field.valueDisplay) {
                    this.UserOptions.push({
                        label: field.valueDisplay,
                        value: field.valueDisplay
                    });
                }
            });
        }
        });
        console.log('tableData:  '+JSON.stringify(tableData));
        if(this.selectedStatus) {
            let filteredTableData = [];
            console.log('inside if to fetch data');
            tableData.forEach(item => {
            //console.log(JSON.stringify(item)); 
            if(item.support && item.support === this.selectedStatus) {
                filteredTableData.push(item);
            }
            });
            this.baseDatatable.initializeTable(tableColumns, filteredTableData);
            this.isStatusSelected = false;
        } else if(this.selectedUser) {
            let filteredTableData = [];
            console.log('inside elseif to fetch data');
            tableData.forEach(item => { 
            if (item.additionalFields && item.additionalFields.length > 0) {
            item.additionalFields.forEach(field => {
                if (field.valueDisplay === this.selectedUser) {
                   filteredTableData.push(item); 
                }
            });
            }
            });
            this.baseDatatable.initializeTable(tableColumns, filteredTableData);
            this.isUserSelected = false;
        } else if(!this.isDateError && this.startDate && this.endDate) {
            let filteredTableData = [];
            console.log('!this.isDateError: '+ this.isDateError);
            console.log('this.startDate && this.endDate :'+this.startDate + this.endDate);
            tableData.forEach(item => {
            console.log('item.createdDate: '+ item.createdDate);
            if(item.createdDate && item.createdDate >= this.startDate && item.createdDate <= this.endDate) {
                console.log('inside createddate condition check' );
                filteredTableData.push(item);
            }
            });
            this.baseDatatable.initializeTable(tableColumns, filteredTableData);
            
        } else {
            //this.baseDatatable.initializeTable(tableColumns, tableData);
            this.baseDatatable.initializeTable(this.mapMemColumns, this.mapMemData);
        }
    }

    handleRefresh() {
        this.initializeTable();
        this.handleCloseModal();
    }

    getLocalType(apexType) {
        switch (apexType?.toLowerCase()) {
            case 'boolean':
                return 'boolean';
            case 'currency':
                return 'currency';
            case 'date':
            case 'datetime':
                return 'date';
            case 'integer':
            case 'double':
            case 'long':
                return 'number';
            case 'percent':
                return 'customPercent';
            case 'phone':
                return 'phone';
            case 'time':
                return 'text';
            case 'url':
                return 'url';
            case 'address':
            case 'anytype':
            case 'base64':
            case 'datacategorygroupreference':
            case 'email':
            case 'encryptedstring':
            case 'id':
            case 'location':
            case 'multipicklist':
            case 'picklist':
            case 'reference':
            case 'string':
            case 'textarea':
            default:
                return 'text';
        }
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        switch (actionName) {
            case 'edit':
                this.editRow(row);
                break;
            default:
        }
    }

    async getMatrix() {
        if (this.objectApiName === 'pqcrush__Account_Plan__c') {
            this.matrixData = await getMatrixByAccountPlan({ accountPlanId: this.recordId });
        } else {
            this.matrixData = await getMatrixByRelationshipMap({ mapId: this.recordId });
        }

        this.influence = this.matrixData?.influenceList;
        this.support = this.matrixData?.supportList;
    }

    async editRow(row) {
        const objectId = row.id;
        let canEdit = false;

        await getUserRecordAccess({ recordId: objectId }).then((access) => {
            canEdit = access.HasAllAccess || access.HasEditAccess;
        });

        const modal = this.template.querySelector('c-pq-matrix-member-modal');
        const memberType = 'pqcrush__Relationship_Map_Member__c';

        modal.open(memberType, objectId, this.influence, this.support, {}, canEdit);
    }

    handleMatrixMemberSuccess() {
        this.initializeTable();
        this.publishMessage();
    }

    isModalOpen = false;
    selectedStatus = ''; 
    selectedUser = '';
    // Open the modal
    handleOpenModal() {
        this.isModalOpen = !this.isModalOpen;
    
    }

    // Close the modal
    handleCloseModal() {
        this.selectedUser = '';
        this.selectedStatus = '';
        this.endDate = '';
        this.startDate = '';
        this.isModalOpen = false;
    }

    handleStatusChange(event) {
        this.selectedStatus = event.detail.value;
        this.selectedUser = '';
        this.endDate = '';
        this.startDate = '';
        console.log('Selected Status:', this.selectedStatus); 
        this.initializeTable();
    }

    startDate ;
    endDate ;

    
    isDateError = false;
    
    
    handleStartDateChange(event) {
        this.selectedStatus = '';
        this.selectedUser = '';
        this.startDate = event.target.value;
        this.validateDates();
        this.initializeTable();
    }

    
    handleEndDateChange(event) {
        this.selectedStatus = '';
        this.selectedUser = '';
        this.endDate = event.target.value;
        this.validateDates();
        this.initializeTable();
    }

    
    validateDates() {
        
        const start = new Date(this.startDate);
        const end = new Date(this.endDate);

        
        if (this.startDate && this.endDate && end <= start) {   
            this.isDateError = true; 
        } else {
            this.isDateError = false; 
        }
    }

    handleUserChange(event) {
        this.endDate = '';
        this.startDate = '';
        this.selectedStatus = '';
        if(event.target.value == 'None'){
            this.selectedUser = '';
        }
        else{
            this.selectedUser = event.target.value;
        }
        this.initializeTable();
    }
}