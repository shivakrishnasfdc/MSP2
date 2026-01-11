import { LightningElement, wire, api } from 'lwc';

export default class AccountList extends LightningElement {
    @api accounts;
}