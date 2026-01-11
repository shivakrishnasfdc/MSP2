import { LightningElement, api } from 'lwc';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';

// Importing to get the object info
import getRecordTypeInfos from '@salesforce/apex/SObjectController.getRecordTypeInfos';

// LABELS
import LABEL_CONTINUE from '@salesforce/label/c.Continue';
import LABEL_SELECT_RECORD_TYPE from '@salesforce/label/c.Select_Record_Type';
import { NavigationMixin } from 'lightning/navigation';


export default class ModalWithRecordTypeSelection extends NavigationMixin(LightningElement) {
    
    objAPIName;
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

    @api
    set modalError(value) {
        this.error = value;
    }

    get modalError() {
        return this.error;
    }

    @api show() {
        this.template.querySelector('c-modal').show();
    }

    @api hide() {
        this.template.querySelector('c-modal').hide();
    }

    @api open(objectApiName) {
        this.objAPIName=objectApiName;
        console.log('objectApiName>>>>>>>'+objectApiName);
        this.error = null;
        this.getRecordTypes(objectApiName);
        this.show();
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
        if (this.recordTypeOptions.length<=1) {
            console.log('inside setShowRecordTypeSelector>>>>');
                this.handleClick();
        }else{
            this.showRecordTypeSelector = true;
            this.showRecordModal = false;
        }
    }

    handleCancel() {
        let cancelEvent = new CustomEvent('cancel', {});

        this.dispatchEvent(cancelEvent);
    }

    handleError(event) {
        this.error = event.detail.message;
    }

    handleChange(event) {
        this.isButtonDisabled = false;
        this.defaultRecordType=event.detail.value;
    }

    handleClick() {
        if(this.recordTypeOptions.length>1){
              let combobox = this.template.querySelector('.combobox-container');
              this.recordTypeSelection = combobox.value;
        }else{
            this.recordTypeSelection = null;
        }       
        this.showRecordTypeSelector = false;
        this.showRecordModal = true;
        const defaultValues = encodeDefaultFieldValues({
            pqcrush__Origin__c: 'LWC',
            pqcrush__RelationShipMap__c :this.mapId
        });
        if(this.objAPIName=='Contact'){
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'Contact',
                    actionName: 'new'
                },
                state: {
                    recordTypeId: this.recordTypeSelection,
                    defaultFieldValues: defaultValues,
                    navigationLocation: 'RELATED_LIST'
                }
            });
        }

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
    }
}