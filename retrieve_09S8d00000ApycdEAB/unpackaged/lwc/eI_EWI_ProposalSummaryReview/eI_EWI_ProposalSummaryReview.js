import { api, track, LightningElement, wire } from 'lwc';
import EWITheme from '@salesforce/resourceUrl/EWITheme';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import updateCaseAgreetoAGLLbyTenant from '@salesforce/apex/eI_EWI_DepositAllocationProposalCls.updateCaseAgreetoAGLLbyTenant';
import updateCaseNotAgreeAGLLAndSchemeBothbyTenant from '@salesforce/apex/eI_EWI_DepositAllocationProposalCls.updateCaseNotAgreeAGLLAndSchemeBothbyTenant';

export default class EI_EWI_ProposalSummaryReview extends NavigationMixin (LightningElement) {

    ew_arrow_dropleft = EWITheme + '/assets/img/ew-arrow-dropleft.png';
    circle_checked_icon = EWITheme + '/assets/img/circle_checked_icon.png';
    
    @track isShowThankyouPage = false;
    @track isAgreeToAGLLRequest = false;
    @track isNotAgreeButWishToScheme = false;
    @track isNotAgreeAndSchemeBoth = false;

    @track isAgreedButtonDisabled = false;
    @track isSelfresButtonDisabled = false;
    @track isCourtCaseButtonDisabled = false;

    @track isSubmitBtnDisable = false;

    @api depositEndDate;
    @api depositAmount;
    @api otherDisputeReason;
    @api initialAmountToTenant;
    @api initialAmountToAGLL;
    @api disputeItems;
    @api agllName;
    @api caseStatus;
    @api caseParticipant;
    
    constructor(){
        super();
    }

    get isProposalSubmittedAGLL(){
        if(this.caseStatus == 'Proposal submitted – agent/landlord' || this.caseStatus=='Proposal submitted – awaiting tenant response'
        && (this.caseParticipant.Type__c=='Agent' || this.caseParticipant.Type__c=='Independent-Landlord' || this.caseParticipant.Type__c=='Non-Member Landlord') ) 
            return true;
        else 
        return false;
    }
    get isAwaitingTenantResponse(){
        if(this.caseStatus == 'Proposal submitted – awaiting tenant response' && this.caseParticipant.Type__c=='Tenant') 
        return true;
        else {return false;}
    }
    get isShowResponseOptions_AwaitingTenantResponse(){
        console.log('this.caseStatus => ' + this.caseStatus);
        console.log('this.caseParticipant.Type__c => ' + this.caseParticipant.Type__c);
        console.log('this.caseParticipant.Is_Lead__c => ' + this.caseParticipant.Is_Lead__c);
        console.log('this.caseParticipant.Case__r.Nr_Of_Lead_Tenants__c => ' + this.caseParticipant.Case__r.Nr_Of_Lead_Tenants__c);
        if(this.caseStatus == 'Proposal submitted – awaiting tenant response' 
        && this.caseParticipant.Type__c=='Tenant'
        && this.caseParticipant.Is_Lead__c == false
        && this.caseParticipant.Case__r.Nr_Of_Lead_Tenants__c > 0)
        {
            return false;
        }
        else 
        {return true;}
    }

    handleGotoDepositSummary(event) {
        let currentURL = window.location.href;
        console.log('currentURL => ' + currentURL);
        let homeURL = currentURL.split('/s');
        console.log('homeURL => ' + homeURL);
        let redirectToURL = homeURL[0]+'/s/?accessCode='+this.caseParticipant.Access_Code__c;
        console.log('redirectToURL => ' + redirectToURL);
        window.location.href = redirectToURL; // "https://portal.tenancydepositscheme.com/s/?accessCode="+this.accessCode;
    }

    handleGoBack(event){
        event.preventDefault();
        const myEvent = new CustomEvent('goback', {
        });
        this.dispatchEvent(myEvent);
    }

    handleAgreeToAGLLRequest(event){
        event.preventDefault();
        this.isAgreeToAGLLRequest = true;
        this.isNotAgreeButWishToScheme = false;
        this.isNotAgreeAndSchemeBoth = false;
        
        this.template.querySelector('.agreebutton').classList.remove('disablebutton'); 
        this.template.querySelector('.selfresbutton').classList.add('disablebutton');
        this.template.querySelector('.courtcasebutton').classList.add('disablebutton');
    }
    handleSubmitAgreetoAGLLRequest(event){
        this.isSelfresButtonDisabled = true;
        this.isCourtCaseButtonDisabled = true;
        this.template.querySelector('.submit-btn-agree').classList.remove('bg-color-blue');
        this.template.querySelector('.submit-btn-agree').classList.add('disable_ew_btn');
        this.isSubmitBtnDisable = true;
        // need to add an apex call for update case status > ‘Case closed - resolved without adjudication’
        updateCaseAgreetoAGLLbyTenant({caseId: this.caseParticipant.Case__c, 
            agreedAmount: this.initialAmountToAGLL,
            depositAmount: this.depositAmount,
            accessCode: this.caseParticipant.Access_Code__c
        }).then(result => {
            console.log("updateCaseAgreetoAGLLbyTenant result => " + result);
            this.isShowThankyouPage = true;
        }).catch(error => {
            console.log("updateCaseAgreetoAGLLbyTenant error => ", error);
        });
    }

    handleNotAgreeButWishToScheme(event){
        event.preventDefault();
        this.isAgreeToAGLLRequest = false;
        this.isNotAgreeButWishToScheme = true;
        this.isNotAgreeAndSchemeBoth = false;

        this.template.querySelector('.agreebutton').classList.add('disablebutton'); 
        this.template.querySelector('.selfresbutton').classList.remove('disablebutton');
        this.template.querySelector('.courtcasebutton').classList.add('disablebutton');
    }
    handleContinueNotAgreeButWishToScheme(event){
        this.isAgreedButtonDisabled = true;
        this.isCourtCaseButtonDisabled = true;
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'ewirepaymentrespondbytenant'
            },
            state:{
                accessCode : this.caseParticipant.Access_Code__c
            }   
        });
    }

    handleNotAgreeAndSchemeBoth(event){
        event.preventDefault();
        this.isAgreeToAGLLRequest = false;
        this.isNotAgreeButWishToScheme = false;
        this.isNotAgreeAndSchemeBoth = true;

        this.template.querySelector('.agreebutton').classList.add('disablebutton'); 
        this.template.querySelector('.selfresbutton').classList.add('disablebutton');
        this.template.querySelector('.courtcasebutton').classList.remove('disablebutton');
    }
    handleSubmitNotAgreeAndSchemeBoth(event){
        this.isAgreedButtonDisabled = true;
        this.isSelfresButtonDisabled = true;
        this.template.querySelector('.submit-btn-notagree').classList.remove('bg-color-blue');
        this.template.querySelector('.submit-btn-notagree').classList.add('disable_ew_btn');
        this.isSubmitBtnDisable = true;
        // need to add an apex call for update case status > ’Consent to resolution not given'. 
        updateCaseNotAgreeAGLLAndSchemeBothbyTenant({caseId: this.caseParticipant.Case__c, 
            agreedAmount: this.initialAmountToAGLL,
            depositAmount: this.depositAmount,
            accessCode: this.caseParticipant.Access_Code__c
        }).then(result => {
            console.log("updateCaseNotAgreeAGLLAndSchemeBothbyTenant result => " + result);
            this.isShowThankyouPage = true;
        }).catch(error => {
            console.log("updateCaseNotAgreeAGLLAndSchemeBothbyTenant error => ", error);
        });
    }

    handleDepositSummaryReview(){
        window.location.reload(true);
    }
}