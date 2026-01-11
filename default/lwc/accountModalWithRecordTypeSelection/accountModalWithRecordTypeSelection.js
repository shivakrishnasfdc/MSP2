import { LightningElement, api, wire } from 'lwc';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import { getRecord } from "lightning/uiRecordApi";
import ACCOUNT_ID from "@salesforce/schema/Account_Plan__c.Account__c";

// Importing to get the object info
import getRecordTypeInfos from '@salesforce/apex/SObjectController.getRecordTypeInfos';

// LABELS
import LABEL_CONTINUE from '@salesforce/label/c.Continue';
import LABEL_SELECT_RECORD_TYPE from '@salesforce/label/c.Select_Record_Type';
import { NavigationMixin } from 'lightning/navigation';


export default class AccountModalWithRecordTypeSelection extends NavigationMixin(LightningElement) {
    

    labels = {
        continue: LABEL_CONTINUE,
        selectRecordType: LABEL_SELECT_RECORD_TYPE
    };

    recordTypeOptions = [];

    defaultRecordType = null;

    error = null;

    isButtonDisabled = true;

    recordTypeSelection = null;

    showRecordTypeSelector = false;

    showRecordModal = false;

    @api modalTitle;

    @api mapId;

    @api recId;

    @api
    set modalError(value) {
        this.error = value;
    }

    get modalError() {
        return this.error;
    }

    @api show() {
        this.setShowRecordTypeSelector();
        this.template.querySelector('c-modal').show();
    }

    @api hide() {
        this.template.querySelector('c-modal').hide();
    }

    @api open(objectApiName) {
        this.error = null;
        this.getRecordTypes(objectApiName);
        this.show();
    }

    @wire(getRecord, {
    recordId: '$recId',
    fields: [ACCOUNT_ID]
  })
  accountPlan;

  get accountId() {
    console.log('aaa>>'+JSON.stringify(this.accountPlan.data));
    return this.accountPlan.data.fields.pqcrush__Account__c;
  }

    async getRecordTypes(sobjectApiName) {
        await getRecordTypeInfos({ sobjectApiName })
            .then((rtValues) => {
                let optionsValues = [];

                for (let i = 0; i < rtValues.length; i++) {
                    if (!rtValues[i].isMaster && rtValues[i].isActive && rtValues[i].isAvailable) {
                        optionsValues.push({
                            label: rtValues[i].name,
                            value: rtValues[i].recordTypeId
                        });

                        if (rtValues[i].isDefaultRecordTypeMapping) {
                            this.defaultRecordType = rtValues[i].recordTypeId;
                            this.recordTypeSelection = this.defaultRecordType;
                            this.isButtonDisabled = false;
                        }
                    }
                }

                this.recordTypeOptions = optionsValues;
                this.setShowRecordTypeSelector();
            })
            .catch((error) => {
                this.error = error.message;
            });
    }

    setShowRecordTypeSelector() {
        if (!this.recordTypeOptions) {
            this.showRecordModal = true;
            this.showRecordTypeSelector = false;

            return;
        }

        if (this.recordTypeOptions.length === 1) {
            this.showRecordModal = true;
            this.showRecordTypeSelector = false;
            let evt = new CustomEvent('recordtypeselected', {
                detail: { recordTypeId: this.recordTypeSelection }
            });

            this.dispatchEvent(evt);
        } else if (this.recordTypeOptions.length > 1) {
            this.showRecordTypeSelector = true;
            this.showRecordModal = false;
        } else {
            this.showRecordModal = true;
            this.showRecordTypeSelector = false;
        }
    }

    handleCancel() {
        let cancelEvent = new CustomEvent('cancel', {});

        this.dispatchEvent(cancelEvent);
    }

    handleError(event) {
        this.error = event.detail.message;
    }

    handleChange() {
        this.isButtonDisabled = false;
    }

    handleClick() {
        let combobox = this.template.querySelector('.combobox-container');

        this.recordTypeSelection = combobox.value;
        this.showRecordTypeSelector = false;
        this.showRecordModal = true;
        /*const defaultValues = encodeDefaultFieldValues({
        pqcrush__Origin__c:'LWC',
        });*/

        console.log('this.mapId>>>'+this.mapId);
        console.log('this.recId>>>>>'+this.recId);
        console.log('aaaaaaa>>>'+JSON.stringify(this.accountPlan.data.fields.pqcrush__Account__c.value));
        let accountId= JSON.stringify(this.accountPlan.data.fields.pqcrush__Account__c.value).replace(/"/g, '');
        console.log('accountId>>'+accountId);
        const defaultValues = encodeDefaultFieldValues({
            ParentId: accountId,
            //pqcrush__Parent_Id_Text__c: accountId,
            //'0017x00000kDtIoAAK',
        });
        

        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Account',
                actionName: 'new'
            },
            state: {
                recordTypeId: this.recordTypeId,
                defaultFieldValues: defaultValues,
                navigationLocation: 'RELATED_LIST'
            }
        });

        let evt = new CustomEvent('recordtypeselected', {
            detail: { recordTypeId: this.recordTypeSelection }
        });

        this.dispatchEvent(evt);

         // Dispatch a custom event named 'blockrefresh'
        const event = new CustomEvent('blockrefresh', {
            bubbles: true,  // Enable bubbling
            composed: true  // Enable crossing the shadow DOM boundary
        });
        this.dispatchEvent(event);

        this.handleCancel();
        //window.location.reload();
    }
    
}