import { LightningElement, track, wire, api } from 'lwc';
import EWITheme from '@salesforce/resourceUrl/EWITheme';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import getclaimdetailsforevidence from '@salesforce/apex/EI_EWI_AGLLEvidenceGathering.getclaimdetailsforevidence';
import updateClaimAGLL from '@salesforce/apex/EI_EWI_AGLLEvidenceGathering.updateClaimAGLL';
import updateAdditionalComments from '@salesforce/apex/EI_EWI_AGLLEvidenceGathering.updateAdditionalComments';

import updateClaimBreakdown from '@salesforce/apex/EI_EWI_AGLLEvidenceGathering.updateClaimBreakdown';
import updatekeyDocuments from '@salesforce/apex/EI_EWI_AGLLEvidenceGathering.updatekeyDocuments';
import cancelclaimHoldingDisputedAmount from '@salesforce/apex/EI_EWI_AGLLEvidenceGathering.cancelclaimHoldingDisputedAmount';
import cancelclaimNotHoldingDisputedAmount from '@salesforce/apex/EI_EWI_AGLLEvidenceGathering.cancelclaimNotHoldingDisputedAmount';
import getHelpArticleDocument from '@salesforce/apex/EI_EWI_AGLLEvidenceGathering.getHelpArticleDocument';
import fetchErrorLabel from '@salesforce/apex/EI_EWI_AGLLEvidenceGathering.fetchErrorLabel';
import updateBankDetails from '@salesforce/apex/el_EWI_MyAccountClass.updateBankDetails';
import EWIVPlus_Link from '@salesforce/label/c.EWIVPlus_Link';

export default class EI_EWI_Evidence_Gathering_AGLL extends LightningElement {
   ew_arrow_dropleft = EWITheme + '/assets/img/ew-arrow-dropleft.png';
   md_arrow_dropleft = EWITheme + '/assets/img/md-arrow-dropleft.png';
   warning_icon = EWITheme + '/assets/img/warning_icon.png';
   feather_download = EWITheme + '/assets/img/feather-download.svg';
   question_circle = EWITheme + '/assets/img/question-circle.png';

   pound_icon = EWITheme + '/assets/img/pound_icon.png';
   
   @track ClaimsDetails = {isTenantObligationsEviAttachment: false, isInventorycheckEviAttachmentFound: false, isCheckoutReportEviAttachmentFound: false, isRentStatementEviAttachmentFound: false};
   @track evidenceAttachments = [];
   @track disputeItems = [];
   @track currentItem = 0;
   @track ViewContinue = true;
   @track keyDocuments = false;
   @track isShowPaymentOfRentKey = false;
   @track Isclaimamountexceed = false;
   @track showClaimBreakdown = false;
   @track showClaimBreakdownCleaning = false;
   @track showClaimBreakdownDamage = false;
   @track showClaimBreakdownRedecoration = false;
   @track showClaimBreakdownGardening = false;
   @track showClaimBreakdownRentArrears = false;
   @track showClaimBreakdownOther = false;
   @track showAdditionalComments = false;
   @track showReviewsubmission = false;
   @track showCancelDispute = false;
   @track cancelFromPage = '';
   @track isHoldingDisputedFunds = false;
   @track showDisputeItemError = false;
   @track showKeyDocumentsError = false;
   @track allFieldsRequiredErrorMsg;
   @track isBankMemberNotes = false;
   @track isBankDetailsEmpty = false;
   @track bankHolderName;
   @track bankName;
   @track bankSortCode;
   @track bankAccountNo;
   @track showBankDetails=false;
   @track Sortcodelengtherror=false;
   @track invalidSortCodeError = false;
   @track sortCodeBlankError = false;
   @track bankOfAmericaSortCode = false;
   @track nameOnAccountBlankError = false;
   @track bankaccountnamelengtherror = false;
   @track nameOnAccountSpecialCharError = false;
   @track accountNumberBlankError = false;
   @track invalidAccountNumberError = false;
   @track bankSuccessMessage =false;
   @track bankErrorMessage = false;
   @track accountNumberLengthError=false;
   @track cp;
   @track NonmemberLL =false;
   @track isBankDetailsEditable=false;
   @track showDetails=true;

    handlebankAccountNumberChange(event){
      this.bankAccountNo =event.target.value;
      this.cp.Bank_Account_Number__c = event.target.value;
    }
    handlesortcodeChange(event){
      this.bankSortCode =event.target.value;
      this.cp.Bank_Sort_Code__c = event.target.value;
    }
    handlebankAccountNamechange(event){
      this.bankHolderName=event.target.value;
      this.cp.Bank_Account_Holder_Name__c = event.target.value;
    }

    handleBankUpdate(){
      var isValid = false;
      this.invalidSortCodeError = false; 
      this.invalidAccountNumberError = false;
      this.bankSuccessMessage = false;
      this.showPopup=false;
  
      let result = {};
      result.caseParticipants = this.cp;
      if(this.handleBankValidation()) {
      updateBankDetails({strResult : JSON.stringify(result)})
        .then(result=>{
    
          var messageValue = result;
          console.log('messageValue='+messageValue);
          if (messageValue == 'InvalidAccountNumber') {
            this.invalidAccountNumberError = true;
            isValid = false;
            this.bankSuccessMessage = false;
          }
    
          if(messageValue=='UnknownSortCode'){
            this.invalidSortCodeError = true; 
            isValid = false;
            this.bankSuccessMessage = false;
           }
           if (messageValue != 'UnknownSortCode' && messageValue != 'InvalidAccountNumber'){
             this.bankSuccessMessage = true;   
             isValid = false;      
             this.handleDoInit(result);
           }
           else{
             this.bankErrorMessage= true;
             this.bankSuccessMessage = false;
           }
    
      })
     .catch(error=>{
        this.error=error.message;
        this.bankSuccessMessage = false;
        console.log('ERROR=>'+this.error);
     });
      
      }
      if(isValid==false){
        console.log("line--> 708 " + isValid);
        this.template.querySelector(".errorMsgDiv").scrollIntoView();
      }
    }
  
    handleBankValidation(){

      let bankHolderName = this.bankHolderName;
      let bankSortCode = this.bankSortCode;
      let bankAccountNo = this.bankAccountNo;
      var isValid = true;
      console.log('bankHolderName'+bankHolderName);
      var accountnummberalphaCharacter = /[A-Za-z]/;
      var Numberonlycheck = /^\d+$/;
      this.bankSuccessMessage = false;
      this.sortCodeBlankError = false;
      this.bankErrorMessage = false;
      this.invalidSortCodeError = false; 
      this.bankOfAmericaSortCode =false;
      this.nameOnAccountBlankError = false;
      this.nameOnAccountSpecialCharError = false;
      this.accountNumberBlankError = false;
      this.invalidAccountNumberError = false;
      this.Sortcodelengtherror = false; 
      this.accountNumberLengthError=false; 

      
  
      if (bankHolderName == undefined || bankHolderName == "" || bankHolderName == null) {
        isValid = false;
        this.nameOnAccountBlankError = true;
        this.bankSuccessMessage = false;
      }  
      if(bankSortCode == undefined || bankSortCode == "" || bankSortCode == null) {
        console.log('bankSortCode ' + bankSortCode);
        isValid = false;
        this.sortCodeBlankError = true;
        this.bankSuccessMessage = false;
        // this.bankOfAmericaSortCode = false;
        }         
      if(bankSortCode){
        if(bankSortCode.length <6 ||  bankSortCode.length>6){
          this.Sortcodelengtherror = true;
          isValid = false;
        }
        }  
        if(bankSortCode == '234079'){
          isValid = false;
          this.bankOfAmericaSortCode = true;
          this.sortCodeBlankError = false;
        }  
        if(bankSortCode){
          console.log('line--> 608 ' + accountnummberalphaCharacter.test(bankSortCode));
        if(!Numberonlycheck.test(bankSortCode)){
          console.log('line--> 624 ' + Numberonlycheck.test(bankSortCode));
          isValid = false;
          this.invalidSortCodeError = true;
          this.sortCodeBlankError = false;
        }
      }
  
      if(bankAccountNo){
        if((!Numberonlycheck.test(bankAccountNo))){
          isValid = false;
          this.invalidAccountNumberError=true;
          this.sortCodeBlankError = false;
          this.bankErrorMessage = false;
        }
      }
  
      if (bankAccountNo == undefined || bankAccountNo == "" || bankAccountNo == null) {
        console.log('accountNumber blank');
        isValid = false;
       this.accountNumberBlankError = true;
     }
     if (bankAccountNo){
      if (bankAccountNo.length<8 || bankAccountNo.length >8 ){
        this.accountNumberLengthError=true;
        isValid = false;
      }
      }
  
    //code for pattern regex
    var pattermatch = /(012|123|234|345|456|567|678|789|111|222|333|444|555|666|777|888|999|987|765|654|543|432|321|210)/g ;
    console.log('pattern='+pattermatch);
       //if(pattermatch.test(this.bankAccountNumber)){
        var passBankAccNumber =  bankAccountNo;
      if(pattermatch.test(bankAccountNo)){
        console.log('test');
        this.invalidAccountNumberError = true;
      }
      else if(/(000)/g.test(bankAccountNo)){ 
        passBankAccNumber='11111111';
        console.log('test000');
        this.invalidAccountNumberError = true;
       // isValid = false;
      }
     
      return isValid;      
    }

   handleDoInit(result){
      this.isBankMemberNotes = result.isBankMemberNotes;
      this.isBankDetailsEmpty = result.isBankDetailsEmpty;
      this.cp = result.caseParticipants;
      console.log('result cp='+JSON.stringify(this.cp));
      this.bankHolderName = this.cp.Bank_Account_Holder_Name__c;     
      this.bankName = this.cp.Bank_Name__c;
      this.bankSortCode = this.cp.Bank_Sort_Code__c;
      this.bankAccountNo= this.cp.Bank_Account_Number__c;
      
      // if(this.isBankDetailsEmpty){
      //    this.template.querySelector('.consentbox').classList.add('disable_ew_btn');
      //    this.template.querySelector('.consentbox').classList.remove('blue_theme');
      // }
      if(this.cp.Type__c == 'Agent' || this.cp.Type__c == 'Independent-Landlord'){

         this.isBankDetailsEditable = true;

      }else{

         this.isBankDetailsEditable = false;

      }
   }

   handleShowBankDetails(){
      this.showBankDetails = true;
   }

   preventBack() { 
      window.history.forward(); 
      // $(document).ready(function() { 
      //    function disableBack() { window.history.forward() } 
      //    window.onload = disableBack(); 
      //    window.onpageshow = function(evt) { 
      //       if (evt.persisted) disableBack() 
      //    } 
      // });
   }

   connectedCallback(){
     setTimeout(() => { this.preventBack() }, 0); 
     
      const queryString = window.location.search;
      console.log('queryString => ' + queryString);
      const urlParams = new URLSearchParams(queryString);
      console.log('urlParams => ' + urlParams);
      const caseId = urlParams.get('caseId');
      console.log('caseId => ' + caseId);
      const accessCode = urlParams.get('accessCode');
      this.accessCode = accessCode;
      console.log('accessCode => ' + accessCode);

      if(accessCode == null || accessCode == undefined || accessCode == ''){
         this.showDetails = false;   
         return;
      }
     
      getclaimdetailsforevidence({accessCode: accessCode}).then(result=>{
         if(result.caseParticipants == null){    
            this.showDetails = false;  
            return;
         }
         this.showDetails = true;
         console.log('getclaimdetailsforevidence result => ' + JSON.stringify(result)); 
         if(result.claim.Status != 'Evidence gathering agent/landlord'){
            this.handlegotoDepositSummary();
         }    
         else{   
            let caseDetails = result.claim;
            let claimItems = result.disputeItems;
            this.handleDoInit(result);
            this.evidenceAttachments = result.evidAttach; // caseDetails.Evidence_Attachments__r;
            
            this.ClaimsDetails['AGLL_Respond_Evidance_Gathering__c'] = caseDetails.AGLL_Respond_Evidance_Gathering__c;
            this.ClaimsDetails['Status'] = caseDetails.Status;
            this.ClaimsDetails['Total_Protected_Amount__c'] = caseDetails.Total_Protected_Amount__c;
            if(caseDetails.Amount_of_Disputed_Funds_Received__c>0 ){
               this.ClaimsDetails['Amounttopaid'] = caseDetails.Total_amount_in_dispute__c<caseDetails.Amount_of_Disputed_Funds_Received__c?caseDetails.Total_amount_in_dispute__c:caseDetails.Amount_of_Disputed_Funds_Received__c;
            }
            else{
               this.ClaimsDetails['Amounttopaid'] =0.00;  
            }
            this.isHoldingDisputedFunds = caseDetails.Amount_of_Disputed_Funds_Received__c>0?true:false;
            // this.ClaimsDetails['Total_Agreed_Amount__c'] = (caseDetails.Total_Agreed_by_AG_LL__c-caseDetails.Total_Agreed_by_Tenant__c);
            // this.isHoldingDisputedFunds = this.ClaimsDetails.Total_Agreed_Amount__c==0?false:true;
            
         
            this.ClaimsDetails['Total_Claimed_by_Landlord__c'] = caseDetails.Total_Claimed_by_Landlord__c;
            if(caseDetails.Total_Claimed_by_Landlord__c >= caseDetails.Total_Deposit__c){
                  this.Isclaimamountexceed = true;
            }
            else{
                  this.Isclaimamountexceed = false;   
            }
            
            if(claimItems){
               const rentItem = claimItems.find(item => item.Type__c == 'Rent');
               if(rentItem){
                  this.isShowPaymentOfRentKey = true;
               }else{
                  this.isShowPaymentOfRentKey = false;
               }
               console.log('isShowPaymentOfRentKey => ' + this.isShowPaymentOfRentKey);
            }

            this.ClaimsDetails['totalAgreedByAGLL'] = parseFloat(caseDetails.Total_Agreed_by_AG_LL__c).toFixed(2);
            this.ClaimsDetails['totalAgreedByTT'] = parseFloat(caseDetails.Total_Agreed_by_Tenant__c).toFixed(2);
            this.ClaimsDetails['remainDisputeAmount'] = parseFloat(caseDetails.Total_Agreed_by_AG_LL__c - caseDetails.Total_Agreed_by_Tenant__c).toFixed(2);
            this.ClaimsDetails['Id'] = caseDetails.Id;
            this.ClaimsDetails['Evidence_Attachments__r'] = caseDetails.Evidence_Attachments__r;
            this.ClaimsDetails['Dispute_Responded_By__c'] = caseDetails.Dispute_Responded_By__c;
            this.ClaimsDetails['Additional_comments_AGLL__c'] = caseDetails.Additional_comments_AGLL__c;
            this.ClaimsDetails['Additional_comments_AGLL__c_length'] = 0;
            if(caseDetails.Consent_box_AGLL__c =='Yes'){
               this.ClaimsDetails['Consent_box_AGLL__c'] = true;
            }
            else{
               this.ClaimsDetails['Consent_box_AGLL__c'] = false;
            }
            if(caseDetails.Claim_exceed__c =='Yes' || caseDetails.Claim_exceed__c =='No'){
               this.ClaimsDetails['isClaimExceedValue'] = true;
               if(caseDetails.Claim_exceed__c =='Yes'){
                  this.ClaimsDetails['claimExceed'] = true;
               }
               else if(caseDetails.Claim_exceed__c =='No'){
                  this.ClaimsDetails['claimExceed'] = false;
               }
            }
            this.ClaimsDetails['claimExceedsComment'] = caseDetails.Claim_exceeds_comment_AGLL__c;
            this.ClaimsDetails['claimExceedsComment_length'] = false;
            
            if(caseDetails.Tenant_obligations__c =='Yes' || caseDetails.Tenant_obligations__c =='No'){
               this.ClaimsDetails['isTenantObligationsValue'] = true;
               if(caseDetails.Tenant_obligations__c =='Yes'){
                  this.ClaimsDetails['TenantObligations'] = true;
                  this.ClaimsDetails['TenantObligationsNoWarning'] = false;
               }
               else if(caseDetails.Tenant_obligations__c =='No'){
                  this.ClaimsDetails['TenantObligations'] = false;
                  this.ClaimsDetails['TenantObligationsNoWarning'] = true;
               }
            }
            if(caseDetails.inventorycheck_in_report_AGLL__c =='Yes' || caseDetails.inventorycheck_in_report_AGLL__c =='No'){
               this.ClaimsDetails['isInventorycheckValue'] = true;
               if(caseDetails.inventorycheck_in_report_AGLL__c =='Yes'){
                  this.ClaimsDetails['inventorycheck'] = true;
                  this.ClaimsDetails['inventorycheckNoWarning'] = false;
               }
               else if(caseDetails.inventorycheck_in_report_AGLL__c =='No'){
                  this.ClaimsDetails['inventorycheck'] = false;
                  this.ClaimsDetails['inventorycheckNoWarning'] = true;
               }
            }
            if(caseDetails.check_out_report_AGLL__c =='Yes' || caseDetails.check_out_report_AGLL__c =='No'){
               this.ClaimsDetails['isCheckoutReportValue'] = true;
               if(caseDetails.check_out_report_AGLL__c =='Yes'){
                  this.ClaimsDetails['checkoutReport'] = true;
                  this.ClaimsDetails['checkoutReportNoWarning'] = false;
               }
               else if(caseDetails.check_out_report_AGLL__c =='No'){
                  this.ClaimsDetails['checkoutReport'] = false;
                  this.ClaimsDetails['checkoutReportNoWarning'] = true;
               }
            }
            if(caseDetails.Rent_statement_AGLL__c =='Yes' || caseDetails.Rent_statement_AGLL__c =='No'){
               this.ClaimsDetails['isRentStatementValue'] = true;
               if(caseDetails.Rent_statement_AGLL__c =='Yes'){
                  this.ClaimsDetails['rentStatement'] = true;
                  this.ClaimsDetails['rentStatementNoWarning'] = false;
               }
               else if(caseDetails.Rent_statement_AGLL__c =='No'){
                  this.ClaimsDetails['rentStatement'] = false;
                  this.ClaimsDetails['rentStatementNoWarning'] = true;
               }
            }
            
            var respondDate = new Date(caseDetails.Respond_Date__c);
            if(respondDate!= null || respondDate!= undefined|| respondDate!= ''){
               var checkdate = respondDate.getDate().toString().padStart(2, "0");;
               var checkmonth = (respondDate.getMonth()+1).toString().padStart(2, "0");
               var checkyear = respondDate.getFullYear();
               var newDate = checkdate +'/'+ checkmonth+'/'+checkyear;
               this.ClaimsDetails['respondDate'] = newDate;
            }
            let disputeItems = [];
            disputeItems.push({key:'Cleaning'});
            disputeItems.push({key:'Damage'});
            disputeItems.push({key:'Redecoration'});
            disputeItems.push({key:'Gardening'});
            disputeItems.push({key:'Rent arrears'});
            disputeItems.push({key:'Other'});
            
            console.log('disputeItems.length before');
            for(let i=0; i<disputeItems.length; i++){
               console.log('disputeItems.length after');
               let flag = false;
               console.log('claimItems.length before');
                  for(let j=0; j<claimItems.length; j++){
               console.log('claimItems.length after');

                     if(disputeItems[i].key.includes(claimItems[j].Type__c)){
                        flag = true;
                        console.log('claimItems[j].Agreed_by_AGLL__c => ' + claimItems[j].Agreed_by_AGLL__c);
                        // console.log("claimItems includes => " + claimItems[j].Type__c)
                        // this.disputeItems.push({key:claimItems[j].Type__c, isOther: claimItems[j].Type__c == 'Other'?claimItems[j].Agreed_by_AGLL__c.toFixed(2)+' '+claimItems[j].Other_Reason__c:'',
                        //    requestedByAGLL: claimItems[j].Agreed_by_AGLL__c.toFixed(2), agreedbyTenant: claimItems[j].Agreed_by_Tenant__c, 
                        //    amountInDispute: claimItems[j].Agreed_by_AGLL__c - claimItems[j].Agreed_by_Tenant__c,
                        //    [claimItems[j].Type__c] :true, isShow: j==0?true:false});
                        disputeItems[i]['isOther']= claimItems[j].Type__c == 'Other'?claimItems[j].Agreed_by_AGLL__c.toFixed(2)+'\n'+claimItems[j].Other_Reason__c:'';
                        disputeItems[i]['requestedByAGLL']= claimItems[j].Agreed_by_AGLL__c.toFixed(2);
                        disputeItems[i]['agreedbyTenant']= claimItems[j].Agreed_by_Tenant__c;
                        disputeItems[i]['amountInDispute']= claimItems[j].Agreed_by_AGLL__c - claimItems[j].Agreed_by_Tenant__c;
                        disputeItems[i][claimItems[j].Type__c] =true;
                        disputeItems[i]['isShow']= j==0?true:false;

                        disputeItems[i]['Id']= claimItems[j].Id;

                        disputeItems[i]['Claim_description_for_cleaning_agll__c']= claimItems[j].Claim_description_for_cleaning_agll__c;
                        disputeItems[i]['Supporting_clause_cleaning_agll__c']= claimItems[j].Supporting_clause_cleaning_agll__c;
                        disputeItems[i]['Evidence_at_tenancystart_cleaning_agll__c']= claimItems[j].Evidence_at_tenancystart_cleaning_agll__c;
                        disputeItems[i]['Evidence_at_tenancy_end_for_cleaning_agl__c']= claimItems[j].Evidence_at_tenancy_end_for_cleaning_agl__c;
                        disputeItems[i]['Supporting_evidence_for_cleaning_agll__c']= claimItems[j].Supporting_evidence_for_cleaning_agll__c;

                        disputeItems[i]['Claim_description_for_cleaning_agll__c_length']=false;
                        disputeItems[i]['Supporting_clause_cleaning_agll__c_length']=false;
                        disputeItems[i]['Evidence_at_tenancystart_cleaning_agll__c_length']=false;
                        disputeItems[i]['Evidence_at_tenancy_end_for_cleaning_agl__c_length']=false;
                        disputeItems[i]['Supporting_evidence_for_cleaning_agll__c_length']=false;

                        disputeItems[i]['Claim_description_for_damage_agll__c']= claimItems[j].Claim_description_for_damage_agll__c;
                        disputeItems[i]['Supporting_clause_damage_agll__c']= claimItems[j].Supporting_clause_damage_agll__c;
                        disputeItems[i]['Evidence_at_tenancystart_damage_agll__c']= claimItems[j].Evidence_at_tenancystart_damage_agll__c;
                        disputeItems[i]['Evidence_at_tenancy_end_for_damage_agll__c']= claimItems[j].Evidence_at_tenancy_end_for_damage_agll__c;
                        disputeItems[i]['Supporting_evidence_for_damage_agll__c']= claimItems[j].Supporting_evidence_for_damage_agll__c;

                        disputeItems[i]['Claim_description_for_damage_agll__c_length']=false;
                        disputeItems[i]['Supporting_clause_damage_agll__c_length']=false;
                        disputeItems[i]['Evidence_at_tenancystart_damage_agll__c_length']=false;
                        disputeItems[i]['Evidence_at_tenancy_end_for_damage_agll__c_length']=false;
                        disputeItems[i]['Supporting_evidence_for_damage_agll__c_length']=false;

                        disputeItems[i]['Claim_description_for_redecoration_agll__c']= claimItems[j].Claim_description_for_redecoration_agll__c;
                        disputeItems[i]['Supporting_clause_redecoration_agll__c']= claimItems[j].Supporting_clause_redecoration_agll__c;
                        disputeItems[i]['Evidence_at_tenancystart_redecoration_ag__c']= claimItems[j].Evidence_at_tenancystart_redecoration_ag__c;
                        disputeItems[i]['Evidence_at_tenancyend_redecoration_agll__c']= claimItems[j].Evidence_at_tenancyend_redecoration_agll__c;
                        disputeItems[i]['Supporting_evidence_for_redecoration_agl__c']= claimItems[j].Supporting_evidence_for_redecoration_agl__c;

                        disputeItems[i]['Claim_description_for_redecoration_agll__c_length']=false;
                        disputeItems[i]['Supporting_clause_redecoration_agll__c_length']=false;
                        disputeItems[i]['Evidence_at_tenancystart_redecoration_ag__c_length']=false;
                        disputeItems[i]['Evidence_at_tenancyend_redecoration_agll__c_length']=false;
                        disputeItems[i]['Supporting_evidence_for_redecoration_agl__c_length']=false;

                        disputeItems[i]['Claim_description_for_gardening_agll__c']= claimItems[j].Claim_description_for_gardening_agll__c;
                        disputeItems[i]['Supporting_clause_gardening_agll__c']= claimItems[j].Supporting_clause_gardening_agll__c;
                        disputeItems[i]['Evidence_at_tenancystart_gardening_agll__c']= claimItems[j].Evidence_at_tenancystart_gardening_agll__c;
                        disputeItems[i]['Evidence_at_tenancyend_gardening_agll__c']= claimItems[j].Evidence_at_tenancyend_gardening_agll__c;
                        disputeItems[i]['Supporting_evidence_for_gardening__c']= claimItems[j].Supporting_evidence_for_gardening__c;

                        disputeItems[i]['Claim_description_for_gardening_agll__c_length']=false;
                        disputeItems[i]['Supporting_clause_gardening_agll__c_length']=false;
                        disputeItems[i]['Evidence_at_tenancystart_gardening_agll__c_length']=false;
                        disputeItems[i]['Evidence_at_tenancyend_gardening_agll__c_length']=false;
                        disputeItems[i]['Supporting_evidence_for_gardening__c_length']=false;

                        disputeItems[i]['Rent_arrears_description_agll__c']= claimItems[j].Rent_arrears_description_agll__c;
                        disputeItems[i]['Was_the_property_re_let_rent_agll__c']= claimItems[j].Was_the_property_re_let_rent_agll__c;
                        disputeItems[i]['Supporting_clause_rent_agll__c']= claimItems[j].Supporting_clause_rent_agll__c;
                        disputeItems[i]['Supporting_evidence_for_rent_agll__c']= claimItems[j].Supporting_evidence_for_rent_agll__c;

                        disputeItems[i]['Rent_arrears_description_agll__c_length']=false;
                        disputeItems[i]['Was_the_property_re_let_rent_agll__c_length']=false;
                        disputeItems[i]['Supporting_clause_rent_agll__c_length']=false;
                        disputeItems[i]['Supporting_evidence_for_rent_agll__c_length']=false;

                        disputeItems[i]['Claim_breakdown_other_AGLL__c']= claimItems[j].Claim_breakdown_other_AGLL__c;
                        disputeItems[i]['Supporting_clause_other_agll__c']= claimItems[j].Supporting_clause_other_agll__c;
                        disputeItems[i]['Supporting_evidence_for_other_agll__c']= claimItems[j].Supporting_evidence_for_other_agll__c;

                        disputeItems[i]['Claim_breakdown_other_AGLL__c_length']=false;
                        disputeItems[i]['Supporting_clause_other_agll__c_length']=false;
                        disputeItems[i]['Supporting_evidence_for_other_agll__c_length']=false;

                     }
                  }
                  if(flag == false){
                     disputeItems.splice(i, 1);
                     i--;
                  }
            }
            this.disputeItems = disputeItems;
            console.log("disputeItems bsjdhcbjsdhbc=> " + JSON.stringify(this.disputeItems));

            fetchErrorLabel().then(result =>{
               console.log('fetchErrorLabel result => ' + result);
               let userErr = '';
               for(var i=0; i<result.length; i++){
                  console.log("line-->9  " +result[i].MasterLabel );
                  console.log("line-->9  " +result[i].Error_Message__c );
                  if(result[i].MasterLabel === 'Evidence Gathering AG/LL'){
                     userErr = result[i].Error_Message__c; // All fields are mandatory
                     this.allFieldsRequiredErrorMsg = userErr;
                  }
               }
            })
            .catch(error => {
               console.log('fetchErrorLabel error => ' + error);
            })
         }
      }).catch(error => {
         console.log('getclaimdetailsforevidence error => ' + JSON.stringify(error), error);
      })

      console.log("disputeItems => " + JSON.stringify(this.disputeItems));
   }

   renderedCallback(){
      if(this.ClaimsDetails.Consent_box_AGLL__c && !this.isBankDetailsEmpty){
         this.template.querySelector('.consentbox').classList.add('blue_theme');
         this.template.querySelector('.consentbox').classList.remove('disable_ew_btn');
      }else{
         this.template.querySelector('.consentbox').classList.remove('blue_theme');
         this.template.querySelector('.consentbox').classList.add('disable_ew_btn');
      }
   }

   clickYes(event) {  
      let selectRecordId = event.target.title;
      if(selectRecordId.includes('Exceedclaim')){
         // component.set("v.ClaimsDetails[0].Claim_exceed__c",'Yes');'
         this.ClaimsDetails['isClaimExceedValue'] = true;
         this.ClaimsDetails['claimExceed'] = true;
         this.template.querySelector('.exceedclaimyes').classList.add('active'); 
         this.template.querySelector('.exceedclaimno').classList.remove('active');
      }
      else if(selectRecordId =='TenantObligations'){
         // component.set("v.ClaimsDetails[0].Tenant_obligations__c",'No');
         this.ClaimsDetails['isTenantObligationsValue'] = true;
         this.ClaimsDetails['TenantObligations'] = true;
         this.ClaimsDetails['TenantObligationsNoWarning'] = false;
         this.template.querySelector('.tenantobligationsyes').classList.add('active'); 
         this.template.querySelector('.tenantobligationsno').classList.remove('active');
      }
      else if(selectRecordId =='inventorycheck'){
         // component.set("v.ClaimsDetails[0].inventorycheck_in_report_AGLL__c",'No');
         this.ClaimsDetails['isInventorycheckValue'] = true;
         this.ClaimsDetails['inventorycheck'] = true;
         this.ClaimsDetails['inventorycheckNoWarning'] = false;
         this.template.querySelector('.inventorycheckyes').classList.add('active'); 
         this.template.querySelector('.inventorycheckno').classList.remove('active');
      }
      else if(selectRecordId =='checkoutReport'){
         // component.set("v.ClaimsDetails[0].check_out_report_AGLL__c",'No');
         this.ClaimsDetails['isCheckoutReportValue'] = true;
         this.ClaimsDetails['checkoutReport'] = true;
         this.ClaimsDetails['checkoutReportNoWarning'] = false;
         this.template.querySelector('.checkoutreportyes').classList.add('active'); 
         this.template.querySelector('.checkoutreportno').classList.remove('active');
      }
      else if(selectRecordId =='rentStatement'){
            // component.set("v.ClaimsDetails[0].Rent_statement_AGLL__c",'No');
         this.ClaimsDetails['isRentStatementValue'] = true;
         this.ClaimsDetails['rentStatement'] = true;
         this.ClaimsDetails['rentStatementNoWarning'] = false;
         this.template.querySelector('.rentstatementyes').classList.add('active'); 
         this.template.querySelector('.rentstatementno').classList.remove('active');
      }
      // alert('TenantObligations => ' +this.ClaimsDetails.TenantObligations);
      // alert('inventorycheck => ' +this.ClaimsDetails.inventorycheck);
      // alert('checkoutReport => ' +this.ClaimsDetails.checkoutReport);
      // alert('rentStatement => ' +this.ClaimsDetails.rentStatement);
   }
  
   clickNo(event) {  
      let selectRecordId = event.target.title;
      if(selectRecordId =='Exceedclaim') {
         // component.set("v.ClaimsDetails[0].Claim_exceed__c",'No');
         this.ClaimsDetails['isClaimExceedValue'] = true;
         this.ClaimsDetails['claimExceed'] = false;
         this.template.querySelector('.exceedclaimyes').classList.remove('active'); 
         this.template.querySelector('.exceedclaimno').classList.add('active');
         setTimeout(() => {
            if(this.ClaimsDetails['claimExceed']){
               console.log('exceedclaimyes => ' +this.template.querySelector('.exceedclaimyes'));
               this.template.querySelector('.exceedclaimyes').classList.add('active'); 
            }
            else if(!this.ClaimsDetails['claimExceed']){
               console.log('exceedclaimno => ' +this.template.querySelector('.exceedclaimno'));
               this.template.querySelector('.exceedclaimno').classList.add('active'); 
            }
      
            if(this.ClaimsDetails['TenantObligations']){
               console.log('tenantobligationsyes => ' +this.template.querySelector('.tenantobligationsyes'));
               this.template.querySelector('.tenantobligationsyes').classList.add('active'); 
            }
            else if(this.ClaimsDetails['TenantObligations'] == false){
               console.log('tenantobligationsno => ' +this.template.querySelector('.tenantobligationsno'));
               this.template.querySelector('.tenantobligationsno').classList.add('active'); 
            }
      
            if(this.ClaimsDetails['inventorycheck']){
               console.log('inventorycheckyes => ' +this.template.querySelector('.inventorycheckyes'));
               this.template.querySelector('.inventorycheckyes').classList.add('active'); 
            }
            else if(this.ClaimsDetails['inventorycheck'] == false){
               console.log('inventorycheckno => ' +this.template.querySelector('.inventorycheckno'));
               this.template.querySelector('.inventorycheckno').classList.add('active'); 
            }
            
            if(this.ClaimsDetails['checkoutReport']){
               console.log('checkoutreportyes => ' +this.template.querySelector('.checkoutreportyes'));
               this.template.querySelector('.checkoutreportyes').classList.add('active'); 
            }
            else if(this.ClaimsDetails['checkoutReport'] == false){
               console.log('checkoutreportno => ' +this.template.querySelector('.checkoutreportno'));
               this.template.querySelector('.checkoutreportno').classList.add('active'); 
            }
            
            if(this.ClaimsDetails['rentStatement']){
               console.log('rentstatementyes => ' +this.template.querySelector('.rentstatementyes'));
               this.template.querySelector('.rentstatementyes').classList.add('active'); 
            }
            else if(this.ClaimsDetails['rentStatement'] == false){
               console.log('rentstatementno => ' +this.template.querySelector('.rentstatementno'));
               this.template.querySelector('.rentstatementno').classList.add('active'); 
            }
         }, 100); 
      }
      else if(selectRecordId =='TenantObligations'){
         // component.set("v.ClaimsDetails[0].Tenant_obligations__c",'No');
         this.ClaimsDetails['isTenantObligationsValue'] = true;
         this.ClaimsDetails['TenantObligations'] = false;
         this.ClaimsDetails['TenantObligationsNoWarning'] = true;
         this.template.querySelector('.tenantobligationsyes').classList.remove('active'); 
         this.template.querySelector('.tenantobligationsno').classList.add('active');

         this.ClaimsDetails.isTenantObligationsEviAttachment = false;
      }
      else if(selectRecordId =='inventorycheck'){
         // component.set("v.ClaimsDetails[0].inventorycheck_in_report_AGLL__c",'No');
         this.ClaimsDetails['isInventorycheckValue'] = true;
         this.ClaimsDetails['inventorycheck'] = false;
         this.ClaimsDetails['inventorycheckNoWarning'] = true;
         this.template.querySelector('.inventorycheckyes').classList.remove('active'); 
         this.template.querySelector('.inventorycheckno').classList.add('active');

         this.ClaimsDetails.isInventorycheckEviAttachmentFound = false;
      }
      else if(selectRecordId =='checkoutReport'){
         // component.set("v.ClaimsDetails[0].check_out_report_AGLL__c",'No');
         this.ClaimsDetails['isCheckoutReportValue'] = true;
         this.ClaimsDetails['checkoutReport'] = false;
         this.ClaimsDetails['checkoutReportNoWarning'] = true;
         this.template.querySelector('.checkoutreportyes').classList.remove('active'); 
         this.template.querySelector('.checkoutreportno').classList.add('active');

         this.ClaimsDetails.isCheckoutReportEviAttachmentFound = false;
      }
      else if(selectRecordId =='rentStatement'){
            // component.set("v.ClaimsDetails[0].Rent_statement_AGLL__c",'No');
         this.ClaimsDetails['isRentStatementValue'] = true;
         this.ClaimsDetails['rentStatement'] = false;
         this.ClaimsDetails['rentStatementNoWarning'] = true;
         this.template.querySelector('.rentstatementyes').classList.remove('active'); 
         this.template.querySelector('.rentstatementno').classList.add('active');

         this.ClaimsDetails.isRentStatementEviAttachmentFound = false;
      }
      // alert('TenantObligations => ' +this.ClaimsDetails.TenantObligations);
      // alert('inventorycheck => ' +this.ClaimsDetails.inventorycheck);
      // alert('checkoutReport => ' +this.ClaimsDetails.checkoutReport);
      // alert('rentStatement => ' +this.ClaimsDetails.rentStatement);
   }

   handlegotoDepositSummary(){
      window.location.href =  EWIVPlus_Link+this.accessCode;

      // let currentURL = window.location.href;
      // console.log('currentURL => ' + currentURL);
      // let homeURL = currentURL.split('/ewinsured/s');
      // console.log('homeURL => ' + homeURL);
      // let redirectToURL = homeURL[0]+'/ewinsured/s/?accessCode='+this.accessCode;
      // console.log('redirectToURL => ' + redirectToURL);
      // window.location.href = redirectToURL; //"https://espdev2-thedisputeservice.cs80.force.com/ewinsured/s/?accessCode="+this.accessCode;
   }

   handleGoBackStep(event){
      let title = event.target.title;
      if(title == 'viewContinue'){
         this.ViewContinue = true;
         this.keyDocuments = false;
      }
      else if(title == 'keyDocument'){
         this.ViewContinue = false;
         this.keyDocuments = true;
         this.showClaimBreakdown = false;
      }
      else if(title == 'claimBreakdown'){
         this.keyDocuments = false;
         this.showClaimBreakdown = true;
         this.showAdditionalComments = false;
      }
      else if(title == 'additionalComments'){
         this.showClaimBreakdown = false;
         this.showAdditionalComments = true;
         this.showReviewsubmission = false;
      }
      console.log('scroll to top');
      const topDiv = this.template.querySelector('[data-id="scroll-to-top"]');
      topDiv.scrollIntoView({ behavior: "smooth", block: "center", inline: "nearest" });
   }

   handleCheckConsent(){
      this.ClaimsDetails.Consent_box_AGLL__c = !this.ClaimsDetails.Consent_box_AGLL__c;
      console.log("ClaimsDetails.Consent_box_AGLL__c => " + this.ClaimsDetails.Consent_box_AGLL__c);
      console.log("this.template.querySelector('.consentbox') => " + this.template.querySelector('.consentbox'));

      if(this.ClaimsDetails.Consent_box_AGLL__c && !this.isBankDetailsEmpty){
         console.log('if');
         this.template.querySelector('.consentbox').classList.add('blue_theme');
         this.template.querySelector('.consentbox').classList.remove('disable_ew_btn');
      }else{
         console.log('else');
         this.template.querySelector('.consentbox').classList.remove('blue_theme');
         this.template.querySelector('.consentbox').classList.add('disable_ew_btn');
      }
   }

   handlegotokeyDocuments(){
      console.log('this.ClaimsDetails.Status => ' + this.ClaimsDetails.Status);
      console.log('this.cp.Type__c => ' + this.cp.Type__c);
      console.log('this.cp.AGLL_Raised_Respond => ' + this.cp.AGLL_Raised_Respond__c);
      if(this.ClaimsDetails.Status == 'Evidence gathering agent/landlord' && this.cp.AGLL_Raised_Respond__c == true
       && (this.cp.Type__c=='Non-Member Landlord' || this.cp.Type__c=='Agent' ||
         this.cp.Type__c=='Independent-Landlord'))
      {
         console.log("ClaimsDetails.Consent_box_AGLL__c => " + this.ClaimsDetails.Consent_box_AGLL__c);
         if(this.ClaimsDetails.Consent_box_AGLL__c && !this.isBankDetailsEmpty){
            updateClaimAGLL({ claimId:this.ClaimsDetails.Id, consentBox:true})
            .then(result=>{
               if(result == 'Case Status Changed'){
                  this.handlegotoDepositSummary();
               }else{
                  console.log('updateClaimAGLL result => ' + result);       
                  this.ViewContinue = false;
                  this.keyDocuments = true;
                  this.showClaimBreakdown = false;
                  setTimeout(() => {
                     if(this.Isclaimamountexceed == true){
                        if(this.ClaimsDetails['claimExceed']){
                           console.log('exceedclaimyes => ' +this.template.querySelector('.exceedclaimyes'));
                           this.template.querySelector('.exceedclaimyes').classList.add('active'); 
                        }else if(this.ClaimsDetails['claimExceed'] == false){
                           console.log('exceedclaimno => ' +this.template.querySelector('.exceedclaimno'));
                           this.template.querySelector('.exceedclaimno').classList.add('active'); 
                        }
                     }
                     if(this.ClaimsDetails['TenantObligations']){
                        console.log('tenantobligationsyes => ' +this.template.querySelector('.tenantobligationsyes'));
                        this.template.querySelector('.tenantobligationsyes').classList.add('active'); 
                     }
                     else if(this.ClaimsDetails['TenantObligations'] == false){
                        console.log('tenantobligationsno => ' +this.template.querySelector('.tenantobligationsno'));
                        this.template.querySelector('.tenantobligationsno').classList.add('active'); 
                     }
               
                     if(this.ClaimsDetails['inventorycheck']){
                        console.log('inventorycheckyes => ' +this.template.querySelector('.inventorycheckyes'));
                        this.template.querySelector('.inventorycheckyes').classList.add('active'); 
                     }
                     else if(this.ClaimsDetails['inventorycheck'] == false){
                        console.log('inventorycheckno => ' +this.template.querySelector('.inventorycheckno'));
                        this.template.querySelector('.inventorycheckno').classList.add('active'); 
                     }
                     
                     if(this.ClaimsDetails['checkoutReport']){
                        console.log('checkoutreportyes => ' +this.template.querySelector('.checkoutreportyes'));
                        this.template.querySelector('.checkoutreportyes').classList.add('active'); 
                     }
                     else if(this.ClaimsDetails['checkoutReport'] == false){
                        console.log('checkoutreportno => ' +this.template.querySelector('.checkoutreportno'));
                        this.template.querySelector('.checkoutreportno').classList.add('active'); 
                     }

                     if(this.isShowPaymentOfRentKey == true){  
                        if(this.ClaimsDetails['rentStatement']){
                           console.log('rentstatementyes => ' +this.template.querySelector('.rentstatementyes'));
                           this.template.querySelector('.rentstatementyes').classList.add('active'); 
                        }
                        else if(this.ClaimsDetails['rentStatement'] == false){
                           console.log('rentstatementno => ' +this.template.querySelector('.rentstatementno'));
                           this.template.querySelector('.rentstatementno').classList.add('active'); 
                        }
                     }
                     console.log('scroll to top');
                     const topDiv = this.template.querySelector('[data-id="scroll-to-top"]');
                     topDiv.scrollIntoView({ behavior: "smooth", block: "center", inline: "nearest" });
                  }, 100);      
               }
            }).catch(error => {
               console.log('updateClaimAGLL error => ' + JSON.stringify(error));
            });
         }
      }
      else{
         this.handlegotoDepositSummary();
      }
   }

   handlegotoshowClaimBreakdown(){
      var isContinue = true;
      var isLengthIssue = false;
      console.log('Isclaimamountexceed => ' + this.Isclaimamountexceed);
      console.log('isClaimExceedValue => ' + this.ClaimsDetails.isClaimExceedValue);
      console.log('claimExceed => ' + this.ClaimsDetails.claimExceed);
      console.log('claimExceedsComment => ' + this.ClaimsDetails.claimExceedsComment);

      if(this.Isclaimamountexceed && !this.ClaimsDetails.isClaimExceedValue){
         isContinue = false; 
      }else if(this.ClaimsDetails.claimExceed && (this.ClaimsDetails.claimExceedsComment == null || this.ClaimsDetails.claimExceedsComment == '' || this.ClaimsDetails.claimExceedsComment == 'undefind')){
         isContinue = false; 
      }else if(this.ClaimsDetails.claimExceedsComment_length){
         isLengthIssue = true;
      }

      if(this.ClaimsDetails.isTenantObligationsValue && this.ClaimsDetails.isInventorycheckValue
         && this.ClaimsDetails.isCheckoutReportValue)
      {
         if(this.ClaimsDetails.TenantObligations){
            const eviAttachment = this.evidenceAttachments.find(evi => evi.Evidence_Categories__c == 'Tenant obligations');
            if(eviAttachment){
               this.ClaimsDetails['isTenantObligationsEviAttachment'] = false;
            }else{
               this.ClaimsDetails['isTenantObligationsEviAttachment'] = true;
               isContinue = false;
            }
         }
         if(this.ClaimsDetails.inventorycheck){
            const eviAttachment = this.evidenceAttachments.find(evi => evi.Evidence_Categories__c == 'Inventorycheck in report');
            if(eviAttachment){
               this.ClaimsDetails['isInventorycheckEviAttachmentFound'] = false;
            }else{
               this.ClaimsDetails['isInventorycheckEviAttachmentFound'] = true;
               isContinue = false;
            }
         }
         if(this.ClaimsDetails.checkoutReport){
            const eviAttachment = this.evidenceAttachments.find(evi => evi.Evidence_Categories__c == 'Check out report');
            if(eviAttachment){
               this.ClaimsDetails['isCheckoutReportEviAttachmentFound'] = false;
            }else{
               this.ClaimsDetails['isCheckoutReportEviAttachmentFound'] = true;
               isContinue = false;
            }
         }

         if(this.isShowPaymentOfRentKey){
            if(this.ClaimsDetails.isRentStatementValue){
               if(this.ClaimsDetails.rentStatement){
                  const eviAttachment = this.evidenceAttachments.find(evi => evi.Evidence_Categories__c == 'Rent statement');
                  if(eviAttachment){
                     this.ClaimsDetails['isRentStatementEviAttachmentFound'] = false;
                  }else{
                     this.ClaimsDetails['isRentStatementEviAttachmentFound'] = true;
                     isContinue = false;
                  }
               }
            }
         }
      }else{
         isContinue = false;   
      }
      
      // alert('handlegotoshowClaimBreakdown isContinue => ' + isContinue);
      if(isContinue == true && isLengthIssue == false){
         this.showKeyDocumentsError = false;
         // alert('this.ClaimsDetails.claimExceedsComment => ' + this.ClaimsDetails.claimExceedsComment)
         updatekeyDocuments({caseRecID: this.ClaimsDetails.Id, 
            tenantObligation: this.ClaimsDetails.TenantObligations?'Yes':'No', 
            exceedclaim: this.ClaimsDetails.claimExceed?'Yes':'No', 
            inventryChekReport: this.ClaimsDetails.inventorycheck?'Yes':'No',
            checkOutReport: this.ClaimsDetails.checkoutReport?'Yes':'No', 
            rentStatement: this.ClaimsDetails.rentStatement?'Yes':'No', 
            claimExceedsComment: this.ClaimsDetails.claimExceedsComment})
         .then(result=>{
            console.log('updatekeyDocuments result => ' + result);
            if(result == 'Case Status Changed'){
               this.handlegotoDepositSummary();
            }
         }).catch(error=>{
            console.log('updatekeyDocuments error => ' + error);
         });
         this.keyDocuments = false;
         this.showClaimBreakdown = true;
         this.showAdditionalComments = false;
         console.log('handlegotoshowClaimBreakdown end ' + this.showClaimBreakdown);

         console.log('scroll to top');
         const topDiv = this.template.querySelector('[data-id="scroll-to-top"]');
         topDiv.scrollIntoView({ behavior: "smooth", block: "center", inline: "nearest" });
      }else if(!isContinue){
         // alert('if isContinue False');
         this.showKeyDocumentsError = true; 
         // alert('if isContinue False END => ' + this.ClaimsDetails.claimExceedsComment);
      }
   }
   handleDisputeItemValueChange(event){
      console.log(event.target.value);
      // this.disputeItems[this.currentItem][event.target.name] = descText;
      console.log("this.disputeItems[this.currentItem][event.target.name]['_length'] => " + this.disputeItems[this.currentItem][event.target.name+'_length'])
      var descText = event.target.value;
      if(descText.length > 2000){
         event.target.value = descText.substring(0, 2000);
         this.disputeItems[this.currentItem][event.target.name] = descText.substring(0, 2000);
         this.disputeItems[this.currentItem][event.target.name+'_length'] = true;
      }else{
         this.disputeItems[this.currentItem][event.target.name] = descText;
         this.disputeItems[this.currentItem][event.target.name+'_length'] = false;
      }
      console.log('this.disputeItems[this.currentItem][event.target.name] => ' + this.disputeItems[this.currentItem][event.target.name])
   }
   goToPreviousItem(event){
      console.log('goToPreviousItem currentItem => ' + this.currentItem);
      if(this.currentItem == 0){
         this.showClaimBreakdown = false;
         this.keyDocuments = true;
         setTimeout(() => {
            if(this.Isclaimamountexceed == true){
               if(this.ClaimsDetails['claimExceed']){
                  console.log('exceedclaimyes => ' +this.template.querySelector('.exceedclaimyes'));
                  this.template.querySelector('.exceedclaimyes').classList.add('active'); 
               }
               else if(this.ClaimsDetails['claimExceed'] == false){
                  console.log('exceedclaimno => ' +this.template.querySelector('.exceedclaimno'));
                  this.template.querySelector('.exceedclaimno').classList.add('active'); 
               }
            }
      
            if(this.ClaimsDetails['TenantObligations']){
               console.log('tenantobligationsyes => ' +this.template.querySelector('.tenantobligationsyes'));
               this.template.querySelector('.tenantobligationsyes').classList.add('active'); 
            }
            else if(this.ClaimsDetails['TenantObligations'] == false){
               console.log('tenantobligationsno => ' +this.template.querySelector('.tenantobligationsno'));
               this.template.querySelector('.tenantobligationsno').classList.add('active'); 
            }
      
            if(this.ClaimsDetails['inventorycheck']){
               console.log('inventorycheckyes => ' +this.template.querySelector('.inventorycheckyes'));
               this.template.querySelector('.inventorycheckyes').classList.add('active'); 
            }
            else if(this.ClaimsDetails['inventorycheck'] == false){
               console.log('inventorycheckno => ' +this.template.querySelector('.inventorycheckno'));
               this.template.querySelector('.inventorycheckno').classList.add('active'); 
            }
            
            if(this.ClaimsDetails['checkoutReport']){
               console.log('checkoutreportyes => ' +this.template.querySelector('.checkoutreportyes'));
               this.template.querySelector('.checkoutreportyes').classList.add('active'); 
            }
            else if(this.ClaimsDetails['checkoutReport'] == false){
               console.log('checkoutreportno => ' +this.template.querySelector('.checkoutreportno'));
               this.template.querySelector('.checkoutreportno').classList.add('active'); 
            }
            
            if(this.isShowPaymentOfRentKey == true){
               if(this.ClaimsDetails['rentStatement']){
                  console.log('rentstatementyes => ' +this.template.querySelector('.rentstatementyes'));
                  this.template.querySelector('.rentstatementyes').classList.add('active'); 
               }
               else if(this.ClaimsDetails['rentStatement'] == false){
                  console.log('rentstatementno => ' +this.template.querySelector('.rentstatementno'));
                  this.template.querySelector('.rentstatementno').classList.add('active'); 
               }
            }
         }, 200); 
      }else{
         this.currentItem--;
         this.disputeItems[this.currentItem].isShow = true;
         this.disputeItems[this.currentItem+1].isShow = false;
      }
      console.log('scroll to top');
      const topDiv = this.template.querySelector('[data-id="scroll-to-top"]');
      topDiv.scrollIntoView({ behavior: "smooth", block: "center", inline: "nearest" });
   }
   goToNextItem(event){
      var isValid = true;
      var isLengthIssue = false;
      let calimItems = [];
      console.log('this.disputeItems[this.currentItem].key => ' + this.disputeItems[this.currentItem].key)
      if(this.disputeItems[this.currentItem].key == 'Cleaning'){
         console.log('this.currentItem => '+this.currentItem)
         console.log(this.disputeItems[this.currentItem].Claim_description_for_cleaning_agll__c);
         if(!this.disputeItems[this.currentItem].Claim_description_for_cleaning_agll__c){
            isValid = false;
         }else if(this.disputeItems[this.currentItem].Claim_description_for_cleaning_agll__c_length){
            isLengthIssue = true;
         }
         console.log(this.disputeItems[this.currentItem].Supporting_clause_cleaning_agll__c);
         if(!this.disputeItems[this.currentItem].Supporting_clause_cleaning_agll__c){
            isValid = false;
         }else if(this.disputeItems[this.currentItem].Supporting_clause_cleaning_agll__c_length){
            isLengthIssue = true;
         }
         console.log(this.disputeItems[this.currentItem].Evidence_at_tenancystart_cleaning_agll__c);
         if(!this.disputeItems[this.currentItem].Evidence_at_tenancystart_cleaning_agll__c){
            isValid = false;
         }else if(this.disputeItems[this.currentItem].Evidence_at_tenancystart_cleaning_agll__c_length){
            isLengthIssue = true;
         }
         console.log(this.disputeItems[this.currentItem].Evidence_at_tenancy_end_for_cleaning_agl__c);
         if(!this.disputeItems[this.currentItem].Evidence_at_tenancy_end_for_cleaning_agl__c){
            isValid = false;
         }else if(this.disputeItems[this.currentItem].Evidence_at_tenancy_end_for_cleaning_agl__c_length){
            isLengthIssue = true;
         }
         console.log(this.disputeItems[this.currentItem].Supporting_evidence_for_cleaning_agll__c);
         if(!this.disputeItems[this.currentItem].Supporting_evidence_for_cleaning_agll__c){
            isValid = false;
         }else if(this.disputeItems[this.currentItem].Supporting_evidence_for_cleaning_agll__c_length){
            isLengthIssue = true;
         }
      }else if(this.disputeItems[this.currentItem].key == 'Damage'){
         if(!this.disputeItems[this.currentItem].Claim_description_for_damage_agll__c){
            isValid = false;
         }else if(this.disputeItems[this.currentItem].Claim_description_for_damage_agll__c_length){
            isLengthIssue = true;
         }
         if(!this.disputeItems[this.currentItem].Supporting_clause_damage_agll__c){
            isValid = false;
         }else if(this.disputeItems[this.currentItem].Supporting_clause_damage_agll__c_length){
            isLengthIssue = true;
         }
         if(!this.disputeItems[this.currentItem].Evidence_at_tenancystart_damage_agll__c){
            isValid = false;
         }else if(this.disputeItems[this.currentItem].Evidence_at_tenancystart_damage_agll__c_length){
            isLengthIssue = true;
         }
         if(!this.disputeItems[this.currentItem].Evidence_at_tenancy_end_for_damage_agll__c){
            isValid = false;
         }else if(this.disputeItems[this.currentItem].Evidence_at_tenancy_end_for_damage_agll__c_length){
            isLengthIssue = true;
         }
         if(!this.disputeItems[this.currentItem].Supporting_evidence_for_damage_agll__c){
            isValid = false;
         }else if(this.disputeItems[this.currentItem].Supporting_evidence_for_damage_agll__c_length){
            isLengthIssue = true;
         }
      }else if(this.disputeItems[this.currentItem].key == 'Redecoration'){
         if(!this.disputeItems[this.currentItem].Claim_description_for_redecoration_agll__c){
            isValid = false;
         }else if(this.disputeItems[this.currentItem].Claim_description_for_redecoration_agll__c_length){
            isLengthIssue = true;
         }
         if(!this.disputeItems[this.currentItem].Supporting_clause_redecoration_agll__c){
            isValid = false;
         }else if(this.disputeItems[this.currentItem].Supporting_clause_redecoration_agll__c_length){
            isLengthIssue = true;
         }
         if(!this.disputeItems[this.currentItem].Evidence_at_tenancystart_redecoration_ag__c){
            isValid = false;
         }else if(this.disputeItems[this.currentItem].Evidence_at_tenancystart_redecoration_ag__c_length){
            isLengthIssue = true;
         }
         if(!this.disputeItems[this.currentItem].Evidence_at_tenancyend_redecoration_agll__c){
            isValid = false;
         }else if(this.disputeItems[this.currentItem].Evidence_at_tenancyend_redecoration_agll__c_length){
            isLengthIssue = true;
         }
         if(!this.disputeItems[this.currentItem].Supporting_evidence_for_redecoration_agl__c){
            isValid = false;
         }else if(this.disputeItems[this.currentItem].Supporting_evidence_for_redecoration_agl__c_length){
            isLengthIssue = true;
         }
      }else if(this.disputeItems[this.currentItem].key == 'Gardening'){
         if(!this.disputeItems[this.currentItem].Claim_description_for_gardening_agll__c){
            isValid = false;
         }else if(this.disputeItems[this.currentItem].Claim_description_for_gardening_agll__c_length){
            isLengthIssue = true;
         }
         if(!this.disputeItems[this.currentItem].Supporting_clause_gardening_agll__c){
            isValid = false;
         }else if(this.disputeItems[this.currentItem].Supporting_clause_gardening_agll__c_length){
            isLengthIssue = true;
         }
         if(!this.disputeItems[this.currentItem].Evidence_at_tenancystart_gardening_agll__c){
            isValid = false;
         }else if(this.disputeItems[this.currentItem].Evidence_at_tenancystart_gardening_agll__c_length){
            isLengthIssue = true;
         }
         if(!this.disputeItems[this.currentItem].Evidence_at_tenancyend_gardening_agll__c){
            isValid = false;
         }else if(this.disputeItems[this.currentItem].Evidence_at_tenancyend_gardening_agll__c_length){
            isLengthIssue = true;
         }
         if(!this.disputeItems[this.currentItem].Supporting_evidence_for_gardening__c){
            isValid = false;
         }else if(this.disputeItems[this.currentItem].Supporting_evidence_for_gardening__c_length){
            isLengthIssue = true;
         }
      }else if(this.disputeItems[this.currentItem].key == 'Rent arrears'){
         if(!this.disputeItems[this.currentItem].Rent_arrears_description_agll__c){
            isValid = false;
         }else if(this.disputeItems[this.currentItem].Rent_arrears_description_agll__c_length){
            isLengthIssue = true;
         }
         if(!this.disputeItems[this.currentItem].Was_the_property_re_let_rent_agll__c){
            isValid = false;
         }else if(this.disputeItems[this.currentItem].Was_the_property_re_let_rent_agll__c_length){
            isLengthIssue = true;
         }
         if(!this.disputeItems[this.currentItem].Supporting_clause_rent_agll__c){
            isValid = false;
         }else if(this.disputeItems[this.currentItem].Supporting_clause_rent_agll__c_length){
            isLengthIssue = true;
         }
         if(!this.disputeItems[this.currentItem].Supporting_evidence_for_rent_agll__c){
            isValid = false;
         }else if(this.disputeItems[this.currentItem].Supporting_evidence_for_rent_agll__c_length){
            isLengthIssue = true;
         }
      }else if(this.disputeItems[this.currentItem].key == 'Other'){
         if(!this.disputeItems[this.currentItem].Claim_breakdown_other_AGLL__c){
            isValid = false;
         }else if(this.disputeItems[this.currentItem].Claim_breakdown_other_AGLL__c_length){
            isLengthIssue = true;
         }
         if(!this.disputeItems[this.currentItem].Supporting_clause_other_agll__c){
            isValid = false;
         }else if(this.disputeItems[this.currentItem].Supporting_clause_other_agll__c_length){
            isLengthIssue = true;
         }
         if(!this.disputeItems[this.currentItem].Supporting_evidence_for_other_agll__c){
            isValid = false;
         }else if(this.disputeItems[this.currentItem].Supporting_evidence_for_other_agll__c_length){
            isLengthIssue = true;
         }
      }
      
      // alert('isValid => ' + isValid);
      if(isValid == true && isLengthIssue == false){
         this.showDisputeItemError = false;
         // alert('if is valid true => ' + isValid);
         for(let i in this.disputeItems){
            let claim={'Id': this.disputeItems[i].Id,
               'Claim_description_for_cleaning_agll__c': this.disputeItems[i].Claim_description_for_cleaning_agll__c,
               'Supporting_clause_cleaning_agll__c': this.disputeItems[i].Supporting_clause_cleaning_agll__c,
               'Evidence_at_tenancystart_cleaning_agll__c': this.disputeItems[i].Evidence_at_tenancystart_cleaning_agll__c,
               'Evidence_at_tenancy_end_for_cleaning_agl__c': this.disputeItems[i].Evidence_at_tenancy_end_for_cleaning_agl__c,
               'Supporting_evidence_for_cleaning_agll__c': this.disputeItems[i].Supporting_evidence_for_cleaning_agll__c,
            
               'Claim_description_for_damage_agll__c': this.disputeItems[i].Claim_description_for_damage_agll__c,
               'Supporting_clause_damage_agll__c': this.disputeItems[i].Supporting_clause_damage_agll__c,
               'Evidence_at_tenancystart_damage_agll__c': this.disputeItems[i].Evidence_at_tenancystart_damage_agll__c,
               'Evidence_at_tenancy_end_for_damage_agll__c': this.disputeItems[i].Evidence_at_tenancy_end_for_damage_agll__c,
               'Supporting_evidence_for_damage_agll__c': this.disputeItems[i].Supporting_evidence_for_damage_agll__c,

               'Claim_description_for_redecoration_agll__c': this.disputeItems[i].Claim_description_for_redecoration_agll__c,
               'Supporting_clause_redecoration_agll__c': this.disputeItems[i].Supporting_clause_redecoration_agll__c,
               'Evidence_at_tenancystart_redecoration_ag__c': this.disputeItems[i].Evidence_at_tenancystart_redecoration_ag__c,
               'Evidence_at_tenancyend_redecoration_agll__c': this.disputeItems[i].Evidence_at_tenancyend_redecoration_agll__c,
               'Supporting_evidence_for_redecoration_agl__c': this.disputeItems[i].Supporting_evidence_for_redecoration_agl__c,

               'Claim_description_for_gardening_agll__c': this.disputeItems[i].Claim_description_for_gardening_agll__c,
               'Supporting_clause_gardening_agll__c': this.disputeItems[i].Supporting_clause_gardening_agll__c,
               'Evidence_at_tenancystart_gardening_agll__c': this.disputeItems[i].Evidence_at_tenancystart_gardening_agll__c,
               'Evidence_at_tenancyend_gardening_agll__c': this.disputeItems[i].Evidence_at_tenancyend_gardening_agll__c,
               'Supporting_evidence_for_gardening__c': this.disputeItems[i].Supporting_evidence_for_gardening__c,

               'Rent_arrears_description_agll__c': this.disputeItems[i].Rent_arrears_description_agll__c,
               'Was_the_property_re_let_rent_agll__c': this.disputeItems[i].Was_the_property_re_let_rent_agll__c,
               'Supporting_clause_rent_agll__c': this.disputeItems[i].Supporting_clause_rent_agll__c,
               'Supporting_evidence_for_rent_agll__c': this.disputeItems[i].Supporting_evidence_for_rent_agll__c,

               'Claim_breakdown_other_AGLL__c': this.disputeItems[i].Claim_breakdown_other_AGLL__c,
               'Supporting_clause_other_agll__c': this.disputeItems[i].Supporting_clause_other_agll__c,
               'Supporting_evidence_for_other_agll__c': this.disputeItems[i].Supporting_evidence_for_other_agll__c
            };
            calimItems.push(claim);
         }
         // alert('JSON.stringify(calimItems) => ' + JSON.stringify(calimItems));
         
         updateClaimBreakdown({disputeItemRec: JSON.stringify(calimItems), caseId: this.ClaimsDetails.Id })
         .then(result =>{
            if(result == 'Case Status Changed'){
               this.handlegotoDepositSummary();
            }
            // alert("updateClaimBreakdown result => " + JSON.stringify(result));
            // alert('updateClaimBreakdown');
         }).catch(error=> {
            // alert('updateClaimBreakdown error => ' + error + JSON.stringify(error));
         });
         var totalItem = this.disputeItems.length;
         // alert('goToNextItem totalItem => ' + totalItem);
         // alert('goToNextItem currentItem => ' + this.currentItem);
         if(this.currentItem == totalItem-1){
            this.showClaimBreakdown = false;
            this.showAdditionalComments = true;
         }else {
            this.disputeItems[this.currentItem].isShow = false;
            this.disputeItems[this.currentItem+1].isShow = true;
            this.currentItem++;
         }
         console.log('scroll to top');
         const topDiv = this.template.querySelector('[data-id="scroll-to-top"]');
         topDiv.scrollIntoView({ behavior: "smooth", block: "center", inline: "nearest" });
      }else if(!isValid){
         // alert('isValid is not true');
         this.showDisputeItemError = true;
      }
   }
   xyznamesmethod(){
      // alert('method called')
   }
   // handlegotoshowClaimBreakdownCleaning(event){
   //    this.keyDocuments = false;
   //    this.showClaimBreakdownCleaning = true;
   //    this.showClaimBreakdownDamage = false;
   // }
   // handlegotoshowClaimBreakdownDamage(event){
   //    this.showClaimBreakdownCleaning = false;
   //    this.showClaimBreakdownDamage = true;
   //    this.showClaimBreakdownRedecoration = false;
   // }
   // handlegotoshowClaimBreakdownRedecoration(event){
   //    this.showClaimBreakdownDamage = false;
   //    this.showClaimBreakdownRedecoration = true;
   //    this.showClaimBreakdownGardening = false;
   // }
   // handlegotoshowClaimBreakdownGardening(event){
   //    this.showClaimBreakdownRedecoration = false;
   //    this.showClaimBreakdownGardening = true;
   //    this.showClaimBreakdownRentArrears = false;
   // }
   // handlegotoshowClaimBreakdownRentArrears(event){
   //    this.showClaimBreakdownGardening = false;
   //    this.showClaimBreakdownRentArrears = true;
   //    this.showClaimBreakdownOther = false;
   // }
   // handlegotoshowClaimBreakdownOther(event){
   //    this.showClaimBreakdownRentArrears = false;
   //    this.showClaimBreakdownOther = true;
   //    this.showAdditionalComments = false;
   // }

   handleClaimExceedCommentValuesChange(event){
      console.log(event.target.value);
      //this.ClaimsDetails[event.target.name] = event.target.value;
      var descText = event.target.value;
      if(descText.length > 30000){
         event.target.value = descText.substring(0, 30000);
         this.ClaimsDetails[event.target.name] = descText.substring(0, 30000);
         this.ClaimsDetails[event.target.name+'_length'] = true;
      }else{
         this.ClaimsDetails[event.target.name] = descText;
         this.ClaimsDetails[event.target.name+'_length'] = false;
      }
   }
   handleAdditionalCommentValuesChange(event){
      console.log(event.target.value);
      //this.ClaimsDetails[event.target.name] = event.target.value;
      var descText = event.target.value;
      if(descText.length > 2000){
         event.target.value = descText.substring(0, 2000);
         this.ClaimsDetails[event.target.name] = descText.substring(0, 2000);
         this.ClaimsDetails[event.target.name+'_length'] = true;
      }else{
         this.ClaimsDetails[event.target.name] = descText;
         this.ClaimsDetails[event.target.name+'_length'] = false;
      }
   }
   handleClaimsDetailsValuesChange(event){
      console.log(event.target.value);
      //this.ClaimsDetails[event.target.name] = event.target.value;
      var descText = event.target.value;
      if(descText.length > 2000){
         event.target.value = descText.substring(0, 2000);
         this.ClaimsDetails[event.target.name] = descText.substring(0, 2000);
         this.ClaimsDetails[event.target.name+'_length'] = true;
      }else{
         this.ClaimsDetails[event.target.name] = descText;
         this.ClaimsDetails[event.target.name+'_length'] = false;
      }
   }
   handlegotoshowReviewsubmission(){
      // alert('this.ClaimsDetails.Additional_comments_AGLL__c => ' + this.ClaimsDetails.Additional_comments_AGLL__c);
      if(!this.ClaimsDetails.Additional_comments_AGLL__c_length){
         updateAdditionalComments({ caseId:this.ClaimsDetails.Id, additionalComment:this.ClaimsDetails.Additional_comments_AGLL__c})
         .then(result=>{
            console.log('result => ' + result);
            if(result == 'Case Status Changed'){
               this.handlegotoDepositSummary();
            }
         }).catch(error=>{
            console.log('error => ' + error);
         });
         if(this.ClaimsDetails.Status == 'Evidence gathering agent/landlord'){
            // alert('if true' + this.ClaimsDetails.respondDate);
            this.showAdditionalComments = false;
            this.showReviewsubmission = true;

            console.log('scroll to top');
            const topDiv = this.template.querySelector('[data-id="scroll-to-top"]');
            topDiv.scrollIntoView({ behavior: "smooth", block: "center", inline: "nearest" });
         }else{
            // alert('else => ' + this.accessCode);
            this.handlegotoDepositSummary();
         }
      }
   }

   handleChangeEviAttachmentList(event){
         console.log( 'Value from Child LWC is ' + JSON.stringify(event.detail) );
         var attachmensts = [];
         if(event.detail.type == 'upload'){
            // alert("upload file type" + attachmensts.length);
            let aviAttachment = event.detail.evidanceAttachment;
            attachmensts = [...this.evidenceAttachments, aviAttachment];
            //attachmensts.push(aviAttachment);
            
            // alert("push attachment" + attachmensts.length);
            this.evidenceAttachments = attachmensts;
            // alert("Add again attachemnt");
         }else if(event.detail.type == 'delete'){
            console.log('event.detail.deletedAttachment.Id => ' + event.detail.deletedAttachment.Id);
            for(let index in this.evidenceAttachments){
               console.log('this.evidenceAttachments[index].Id => ' + this.evidenceAttachments[index].Id);
               
               if(this.evidenceAttachments[index].Id != event.detail.deletedAttachment.Id){
                  attachmensts.push(this.evidenceAttachments[index]);
               }
            }
            this.evidenceAttachments = attachmensts;
         }else if(event.detail.type == 'Case Status Changed'){
            this.handlegotoDepositSummary();
         }
         console.log('this.evidenceAttachments after => '+ JSON.stringify(this.evidenceAttachments));

   }

   handlegotoshowCancelDispute(){
      // alert('handlegotoshowCancelDispute');
      if(this.ClaimsDetails.Status == 'Evidence gathering agent/landlord'){
         // alert('handlegotoshowCancelDispute start');
         if(this.ViewContinue){
            this.cancelFromPage = 'ViewContinue';
            this.ViewContinue = false;
         }
         else if(this.keyDocuments){
            this.cancelFromPage = 'keyDocuments';
            this.keyDocuments = false;
         }
         else if(this.showClaimBreakdown){
            this.cancelFromPage = 'showClaimBreakdown';
            this.showClaimBreakdown = false;
         }
         else if(this.showAdditionalComments){
            this.cancelFromPage = 'showAdditionalComments';
            this.showAdditionalComments = false;
         }
         else if(this.showReviewsubmission){
            this.cancelFromPage = 'showReviewsubmission';
            this.showReviewsubmission = false;
         }
         this.showCancelDispute = true;
         // alert('handlegotoshowCancelDispute end');
         console.log('scroll to top');
         const topDiv = this.template.querySelector('[data-id="scroll-to-top"]');
         topDiv.scrollIntoView({ behavior: "smooth", block: "center", inline: "nearest" });
      }
   }
   handleBackFromCancelDispute(){
      this.showCancelDispute = false;
      
      if(this.cancelFromPage == 'ViewContinue'){
         this.ViewContinue = true;
      }
      else if(this.cancelFromPage == 'keyDocuments'){
         this.keyDocuments = true;
      }
      else if(this.cancelFromPage == 'showClaimBreakdown'){
         this.showClaimBreakdown = true;
      }
      else if(this.cancelFromPage == 'showAdditionalComments'){
         this.showAdditionalComments = true;
      }
      else if(this.cancelFromPage == 'showReviewsubmission'){
         this.showReviewsubmission = true;
      }
      console.log('scroll to top');
      const topDiv = this.template.querySelector('[data-id="scroll-to-top"]');
      topDiv.scrollIntoView({ behavior: "smooth", block: "center", inline: "nearest" });
   }
   handleConfirmCancelDispute(){
      if(this.isHoldingDisputedFunds){
         cancelclaimHoldingDisputedAmount({caseid: this.ClaimsDetails.Id, disptAmount: this.ClaimsDetails.Amounttopaid})
         .then(result=>{
            console.log('cancelclaim result => ' + result);
            this.handlegotoDepositSummary();
         }).catch(error=>{
            console.log('cancelclaim error => ' + JSON.stringify(error));
         });
      }else{
         cancelclaimNotHoldingDisputedAmount({caseid: this.ClaimsDetails.Id, disptAmount: this.ClaimsDetails.Amounttopaid})
         .then(result=>{
            console.log('cancelclaim result => ' + result);
            this.handlegotoDepositSummary();
         }).catch(error=>{
            console.log('cancelclaim error => ' + JSON.stringify(error));
         });
      }
   }

   hideBootstrapErrors(event) {
      var button_Name = event.target.name;
      console.log('hideBootstrapErrors button_Name => '+button_Name);
      switch (button_Name) {
         case "TenantObligationsNo":
          //  this.ClaimsDetails.isTenantObligationsValue = false;
            this.ClaimsDetails.TenantObligationsNoWarning = false;
            break;
         case "inventorycheckNo":
          //  this.ClaimsDetails.isInventorycheckValue = false;
            this.ClaimsDetails.inventorycheckNoWarning = false;
            break;
         case "checkoutReportNo":
          //  this.ClaimsDetails.isCheckoutReportValue = false;
            this.ClaimsDetails['checkoutReportNoWarning'] = false;
            break;
         case "rentStatementNo":
          //  this.ClaimsDetails.isRentStatementValue = false;
            this.ClaimsDetails['rentStatementNoWarning'] = false;
            break;

          case "isTenantObligationsEviAttachment":
          this.ClaimsDetails.isTenantObligationsEviAttachment = false;
          break;
          case "isInventorycheckEviAttachmentFound":
          this.ClaimsDetails.isInventorycheckEviAttachmentFound = false;
          break;
          case "isCheckoutReportEviAttachmentFound":
          this.ClaimsDetails.isCheckoutReportEviAttachmentFound = false;
          break;
          case "isRentStatementEviAttachmentFound":
          this.ClaimsDetails.isRentStatementEviAttachmentFound = false;
          break;
            case "bankSuccessMessage":
            this.bankSuccessMessage = false;
            break;
            case "nameOnAccountBlankError":
            this.nameOnAccountBlankError = false;
            break;
            case "nameOnAccountSpecialCharError":
            this.nameOnAccountSpecialCharError = false;
            break; 
            case "accountNumberLengthError":
            this.accountNumberLengthError = false;
            break;  
            case "accountNumberBlankError":
            this.accountNumberBlankError = false;
            break;   
            case "invalidAccountNumberError":
            this.invalidAccountNumberError = false;
            break;  
            case "sortCodeBlankError":
            this.sortCodeBlankError = false;
            break;   
            case "bankOfAmericaSortCode":
            this.bankOfAmericaSortCode = false;
            break;  
            case "Sortcodelengtherror":
            this.Sortcodelengtherror = false;
            break;   
            case "invalidSortCodeError":
            this.invalidSortCodeError = false;
            break; 
            case "bankErrorMessage":
            this.bankErrorMessage = false;
            break; 
      }
   }

   getHelpArticleDocument(){
      //alert("call get guide doc");
      // getHelpArticleDocument().then(result=>{
      //    console.log('result => ' + result)
      //    var res = result;
      //    console.log("Guidance document Id => " + res);
         window.open('https://ewinsureddev.blob.core.windows.net/ewinsureddev/5003G000008RH95QAG-1670487092870-TDS%20Help%20Article_v2.pdf?sp=rw&st=2022-04-05T08:51:01Z&se=2032-04-05T16:51:01Z&spr=https&sv=2020-08-04&sr=c&sig=vbBtrfu%2BbFNQQp1SY8AZ3kTf2z9MKp%2F3Hnia3FLKKCg%3D', 
                    '_blank');
      //    // window.open("/servlet/servlet.FileDownload?file="+res); 
      // }).catch(error=>{
      //    console.log('error => ' + error);
      // });
   }

   
}