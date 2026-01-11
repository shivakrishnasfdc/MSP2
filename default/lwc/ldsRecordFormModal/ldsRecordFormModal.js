import { LightningElement, api, track } from 'lwc';
import requiredFieldDet from '@salesforce/apex/SObjectController.getFieldDetails';

export default class LdsRecordFormModal extends LightningElement {

   @api mapId;

    @api modalTitle;

    @api tempNode;

    @api recordId;

    @api mode = 'edit'; // [view, edit, readonly]

    @api columns = 2;

    error = null;

    layoutType = 'Full';

    objectApiName;

    recordTypeId = null;

    isContact = false;

    @track reqFieldsMap = [];

    mapData = [];

    @api open(objectApiName) {
        this.objectApiName = objectApiName;
        if (this.objectApiName === 'Contact') {
            this.getFieldDetails(this.objectApiName);
            this.template.querySelector('c-modal-with-record-type-selection').open(objectApiName);
        } else {
            this.template.querySelector('c-modal-with-record-type-selection').open(objectApiName);
        }
    }

    handleSuccess(event) {
        this.template.querySelector('c-modal-with-record-type-selection').hide();
        this.isContact = false;
        if(this.objectApiName === 'Contact'){
                const successEvent = new CustomEvent('success', {
            detail: {
                tempNode: JSON.parse(JSON.stringify(this.tempNode)),
                objectId: event.detail.id
            }
        });

        this.dispatchEvent(successEvent);
        }
        
    }

    handleError(event) {
        this.error = event.detail.message;
    }

    handleCancel() {
        this.template.querySelector('c-modal-with-record-type-selection').hide();
        this.isContact = false;
        let cancelEvent;

        if (this.tempNode) {
            let tempId = this.tempNode?.tempId;

            cancelEvent = new CustomEvent('cancel', {
                detail: { tempId }
            });
        } else {
            cancelEvent = new CustomEvent('cancel', {});
        }
        this.dispatchEvent(cancelEvent);
    }

    handleRecordTypeSelected(event) {
        this.recordTypeId = event.detail.recordTypeId;
    }

    async getFieldDetails(objectApiName) {
        this.reqFieldsMap = [];

        await requiredFieldDet({ sobjectApiName: objectApiName })
            .then((retValues) => {
                this.mapData = retValues;
                if (this.mapData) {
                    // eslint-disable-next-line guard-for-in
                    for (let key in this.mapData) {
                        this.reqFieldsMap.push({ key: key, value: this.mapData[key] });
                    }
                }
            })
            .catch((error) => {
                this.error = error.message;
            });
    }
}