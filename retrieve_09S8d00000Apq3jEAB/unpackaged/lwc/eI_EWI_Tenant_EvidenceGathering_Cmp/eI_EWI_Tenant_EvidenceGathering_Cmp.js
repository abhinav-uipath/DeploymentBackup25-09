import { LightningElement, track, wire, api } from 'lwc';
import EWITheme from '@salesforce/resourceUrl/EWITheme';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import getclaimdetailsInTenantEvidence from '@salesforce/apex/EI_EWI_TenantEvidenceGatheringClass.getclaimdetailsInTenantEvidence';
import updateClaimItemTT from '@salesforce/apex/EI_EWI_TenantEvidenceGatheringClass.updateClaimItemTT';
import updateClaimTT from '@salesforce/apex/EI_EWI_TenantEvidenceGatheringClass.updateClaimTT';
import updateAdditionalCommentsTT from '@salesforce/apex/EI_EWI_TenantEvidenceGatheringClass.updateAdditionalCommentsTT';
import cancelclaimHoldingDisputedAmount from '@salesforce/apex/EI_EWI_TenantEvidenceGatheringClass.cancelclaimHoldingDisputedAmount';
import cancelclaimNotHoldingDisputedAmount from '@salesforce/apex/EI_EWI_TenantEvidenceGatheringClass.cancelclaimNotHoldingDisputedAmount';
import getHelpArticleDocument from '@salesforce/apex/EI_EWI_TenantEvidenceGatheringClass.getHelpArticleDocument';
import fetchErrorLabel from '@salesforce/apex/EI_EWI_AGLLEvidenceGathering.fetchErrorLabel';
import updateBankDetails from '@salesforce/apex/el_EWI_MyAccountClass.updateBankDetails';
import updateInterBankDetails from '@salesforce/apex/el_EWI_MyAccountClass.updateInterBankDetails';
import EWIVPlus_Link from '@salesforce/label/c.EWIVPlus_Link';
import isSubmitEdiEvidenceAllowed from '@salesforce/apex/EI_EWI_TenantEvidenceGatheringClass.isSubmitEdiEvidenceAllowed';

export default class EI_EWI_Tenant_EvidenceGathering_Cmp extends LightningElement {

    ew_arrow_dropleft = EWITheme + '/assets/img/ew-arrow-dropleft.png';
    md_arrow_dropleft = EWITheme + '/assets/img/md-arrow-dropleft.png';
    warning_icon = EWITheme + '/assets/img/warning_icon.png';
    feather_download = EWITheme + '/assets/img/feather-download.svg';
    question_circle = EWITheme + '/assets/img/question-circle.png';
 
    pound_icon = EWITheme + '/assets/img/pound_icon.png';


   @track response = '';
   @track accessCode;
   @track ClaimsDetails = [];
   @track evidenceAttachments = [];
   @track disputeItems = [];
   @track AGLLandTTCalaimDetails = [];
   @track currentItem = 0;
   @track ViewContinue = true;
   @track keyDocuments = false;
   @track showClaimBreakdown = false;
   @track showAllClaimAgreed = false;
   @track showAdditionalComments = false;
   @track showReviewsubmission = false;
   @track showCancelDispute = false;
   @track cancelFromPage = '';
   @track isHoldingDisputedFunds = false;
   @track isBreakdownContbtnDisable = false;
   @track allFieldsRequiredErrorMsg;
   @track isBankMemberNotes = false;
   @track isBankDetailsEmpty = false;
   @track bankHolderName;
   @track bankName;
   @track bankSortCode;
   @track bankAccountNo;
   @track nameOnAccountInter;
   @track bankNameInter;
   @track BIC;
   @track swiftCodeInter;
   @track IBAN;
   @track beneficiaryHomeInter;
   @track isShowPaymentOfRentKey;
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
   @track lenghtOfIBan=false;
   @track ibanspecialcharactererror = false;
   @track invalidIBANError = false;
   @track interIBANISBlankError=false;
   @track beneficiaryHomeRequird = false;
   @track nameOnInterAccBlankError = false;
   @track interSuccessMessage=false;
   @track inteBankAccountError = false;
   @track accountNumberLengthError=false;
   @track cp;
   @track showDetails=true;
   detail;
   

   hideBootstrapErrors(event) {
      var button_Name = event.target.name;
      console.log('hideBootstrapErrors button_Name => '+button_Name);
      switch (button_Name) {
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
            case "inteBankAccountError" :
            this.inteBankAccountError=false;
            break;
            case "interSuccessMessage":
            this.interSuccessMessage=false;
            break;
            case "nameOnInterAccBlankError":
            this.nameOnInterAccBlankError=false;
            break;
            case "beneficiaryHomeRequird":
            this.beneficiaryHomeRequird= false;
            break; 
            case "interIBANISBlankError":
            this.interIBANISBlankError=false;
            break;
            case "invalidIBANError":
            this.invalidIBANError = false;
            break;
            case "ibanspecialcharactererror":
            this.ibanspecialcharactererror = false;
            break;
            case "lenghtOfIBan":
            this.lenghtOfIBan = false;
            break; 
      }
   }

   handlebankAccountNumberChange(event){
      this.bankAccountNo =event.target.value;
    }
    handlesortcodeChange(event){
      this.bankSortCode =event.target.value;
      this.cp.Bank_Sort_Code__c = event.target.value;
    }
    handlebankAccountNamechange(event){
      this.bankHolderName=event.target.value;
      this.cp.Bank_Account_Holder_Name__c = event.target.value;
    }
    handleinternationalbankAccountName(event){   
      this.nameOnAccountInter = event.target.value;
      this.cp.International_Bank_Account_Holder_Name__c =event.target.value;
    }
    handleinternationalIdentificationCode(event){
      this.BIC = event.target.value;
      this.cp.Bank_Identification_Code__c =event.target.value;
    }
    handleIBAN(event){
      this.IBAN = event.target.value;
      this.cp.International_Account_Number__c =event.target.value;
    }
    handleinternationalBankName(event){
      this.bankNameInter = event.target.value; 
      this.cp.International_Bank_Name__c =event.target.value;
    }
    handleinternationalBenificiaryAddress(event){
      this.beneficiaryHomeInter = event.target.value;
      this.cp.Beneficiary_Home_Address__c =event.target.value;
    }
    handleinternationalbankswiftCode(event){
      this.swiftCodeInter = event.target.value;
        this.cp.Swift_Code__c =event.target.value;
    }

    handleBankUpdate(){
      var isValid = false;
      this.invalidSortCodeError = false; 
      this.invalidAccountNumberError = false;
      this.bankSuccessMessage = false;
      this.showPopup=false;
  
      let result = {};
      result.caseParticipants = this.cp;
      result.caseParticipants.Bank_Account_Number__c = this.bankAccountNo;
      result.caseParticipants.Bank_Sort_Code__c = this.bankSortCode;
      result.caseParticipants.Bank_Account_Holder_Name__c =this.bankHolderName;

      if(this.handleBankValidation()) {
      updateBankDetails({strResult : JSON.stringify(result)})
        .then(result=>{
    
          var messageValue = result;
          console.log('messageValue='+ JSON.stringify(result));
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

   /***Update International Bank detail***/
   handleInternationalBank(){
      var isValid = false;
      let result = {};
      //result.con = this.personRecord;
      result.caseParticipants = this.cp; 
      console.log('result3333='+JSON.stringify(result.caseParticipants)); 
      result.caseParticipants.International_Bank_Account_Holder_Name__c = this.nameOnAccountInter;
      result.caseParticipants.International_Bank_Name__c = this.bankNameInter;
      result.caseParticipants.Bank_Identification_Code__c = this.BIC;
      result.caseParticipants.Swift_Code__c = this.swiftCodeInter;
      result.caseParticipants.International_Account_Number__c = this.IBAN;
      result.caseParticipants.Beneficiary_Home_Address__c = this.beneficiaryHomeInter;
      this.interSuccessMessage = false;
      this.invalidIBANError = false;
   
      if(this.handleInterBankValidation()) {
         updateInterBankDetails({strResult : JSON.stringify(result)})
         .then(result=>{
      
            if(result=="invalidIBAN") {
               this.invalidIBANError = true;
               this.interSuccessMessage = false;
            } else{
               isValid= false;
               this.interSuccessMessage= true;
               this.handleDoInit(result);
            }
            
         })
         .catch(error=>{
         this.error=error.message;
         console.log(this.error);
         });
      }
      else{
         this.template.querySelector(".errorMsgDiv2").scrollIntoView();
      }
   
   }

   handleInterBankValidation(){
      let nameOnAccountInter = this.nameOnAccountInter;
      let bankNameInter = this.bankNameInter;
      let BIC = this.BIC;
      let swiftCodeInter = this.swiftCodeInter;
      let IBAN = this.IBAN;
      let beneficiaryHomeInter = this.beneficiaryHomeInter;
      console.log('beneficiaryHomeInter='+beneficiaryHomeInter);
   // consol.log('IBAN='+IBAN);
   
   // consol.log('nameOnAccountInter='+nameOnAccountInter);


      var isValid = true;
   // let casePar = this.cp;
      var accountnummberspecialCharacter =  /[ `!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?~]/;;
      this.nameOnInterAccBlankError = false;
      this.inteBankAccountError = false; 
      this.beneficiaryHomeRequird = false;
      this.ibanspecialcharactererror = false;
      this.lenghtOfIBan=false;
      this.interIBANISBlankError =false;

      if(nameOnAccountInter ==undefined || nameOnAccountInter =="" || nameOnAccountInter ==null){
      isValid=false;
      this.nameOnInterAccBlankError = true;
      }

      if(bankNameInter ==undefined || bankNameInter =="" || bankNameInter ==null){
      isValid=false;
      this.inteBankAccountError = true;             
      }
      
      if(beneficiaryHomeInter ==undefined || beneficiaryHomeInter ==""|| beneficiaryHomeInter ==null){
      isValid=false;
      this.beneficiaryHomeRequird = true;
      }
      
      if(IBAN ==undefined || IBAN =="" || IBAN ==null){
      isValid= false;
      this.interIBANISBlankError = true;
      }

      if (accountnummberspecialCharacter.test(IBAN))
      {
      // alert('check');
      isValid= false;
      this.ibanspecialcharactererror = true;
      }
   
      if(IBAN){
         if(IBAN.length < 15){
            isValid= false;
            this.lenghtOfIBan=true;
         }
      }
      return isValid;
   }

   handleDoInit(result){
      this.detail = result;
      this.isBankMemberNotes = result.isBankMemberNotes;
      this.isBankDetailsEmpty = result.isBankDetailsEmpty;
      this.cp = result.caseParticipants;
      this.bankHolderName = this.cp.Bank_Account_Holder_Name__c;     
      this.bankName = this.cp.Bank_Name__c;
      this.bankSortCode = this.cp.Bank_Sort_Code__c;
      this.bankAccountNo= this.cp.Bank_Account_Number__c;
      this.nameOnAccountInter = this.cp.International_Bank_Account_Holder_Name__c;
      this.bankNameInter = this.cp.International_Bank_Name__c;
      this.BIC = this.cp.Bank_Identification_Code__c;
      this.swiftCodeInter = this.cp.Swift_Code__c;
      this.IBAN = this.cp.International_Account_Number__c;
      this.beneficiaryHomeInter = this.cp.Beneficiary_Home_Address__c;
      // if(this.isBankDetailsEmpty){
      //    this.template.querySelector('.consentbox').classList.add('disable_ew_btn');
      //    this.template.querySelector('.consentbox').classList.remove('blue_theme');
      // }
   }

   handleShowBankDetails(){
      this.showBankDetails = true;
   }

   // get isBreakdownContbtnDisable(){
   //    console.log('Is_Tenant_Agree__c_value' + this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c_value']);
   //    console.log('Is_Tenant_Agree__c' + this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c']);
   //    console.log('Tenant_Disagree_comment__c' + this.AGLLandTTCalaimDetails[this.currentItem]['Tenant_Disagree_comment__c']);
   //    console.log('Is_Tenant_Upload_Evidence__c_value' + this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Upload_Evidence__c_value']);
   //    console.log('Is_Tenant_Agree__c_value' + this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c_value']);
      
   //    if(!this.AGLLandTTCalaimDetails[this.currentItem].key.includes('AGLL')){
   //       if(!this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c_value'] && 
   //          !this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Upload_Evidence__c_value'])
   //       {
   //          return true;
   //       }
   //       else if(this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c_value'] 
   //          && this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c'])
   //       {
   //          return false;
   //       }
   //       else if(this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c_value'] 
   //          && !this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c'] 
   //          && (this.AGLLandTTCalaimDetails[this.currentItem].Tenant_Disagree_comment__c == ''
   //          || this.AGLLandTTCalaimDetails[this.currentItem].Tenant_Disagree_comment__c == null || this.AGLLandTTCalaimDetails[this.currentItem].Tenant_Disagree_comment__c == undefined))
   //       {
   //          return true;
   //       }
   //       else if(this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c_value'] 
   //          && !this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c'] 
   //          && !this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Upload_Evidence__c_value'])
   //       {
   //          return true;
   //       }
   //       else if(this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c_value'] 
   //          && !this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c'] 
   //          && this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Upload_Evidence__c_value']
   //          && this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Upload_Evidence__c']
   //          && !this.AGLLandTTCalaimDetails[this.currentItem]['evidence'+this.AGLLandTTCalaimDetails[this.currentItem].type])
   //       {
   //          return true;
   //       }
   //       else if(this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c_value'] 
   //          && !this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c'] 
   //          && this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Upload_Evidence__c_value']
   //          && this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Upload_Evidence__c']
   //          && this.AGLLandTTCalaimDetails[this.currentItem]['evidence'+this.AGLLandTTCalaimDetails[this.currentItem].type])
   //       {
   //          return false;
   //       }
   //       else if(this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c_value'] 
   //          && !this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c'] 
   //          && this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Upload_Evidence__c_value']
   //          && !this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Upload_Evidence__c'])
   //       {
   //          return false;
   //       }
   //    }else{
   //       return false;
   //    }
   // }
   preventBack() { 
      console.log('preventBack');
      window.history.forward(); 
   }

   connectedCallback(){
      setTimeout(() => { this.preventBack() }, 0); 
      
      var queryString = window.location.search;
      console.log('queryString => ' + queryString);
      var urlParams = new URLSearchParams(queryString);
      console.log('urlParams => ' + urlParams);
      var caseId = urlParams.get('caseId');
      console.log('caseId => ' + caseId);
      //  const accessCode = 
      this.accessCode = urlParams.get('accessCode');
      if(this.accessCode == null || this.accessCode == undefined || this.accessCode == ''){
         this.showDetails = false;
         return;
      }
      
      getclaimdetailsInTenantEvidence({accessCode:  this.accessCode}).then(result=>{
         if(result==null){
            this.showDetails = false;
            return;
         }
         this.showDetails = true;
         console.log('getclaimdetailsInTenantEvidence result => ' + JSON.stringify(result));
         if(result.claim.Status != 'Evidence gathering tenant'){
            this.handlegotoDepositSummary();
         }    
         else{
            let caseDetails = result.claim;
            let claimItems = result.disputeItems;

            this.handleDoInit(result);
            this.evidenceAttachments = result.evidAttach; //caseDetails.Evidence_Attachments__r;
         
            this.ClaimsDetails['Total_Protected_Amount__c'] = caseDetails.Total_Protected_Amount__c;
            this.isHoldingDisputedFunds = caseDetails.Amount_of_Disputed_Funds_Received__c>0?true:false;
            // this.ClaimsDetails['Total_Agreed_Amount__c'] = (caseDetails.Total_Agreed_by_AG_LL__c-caseDetails.Total_Agreed_by_Tenant__c);
            // this.isHoldingDisputedFunds = this.ClaimsDetails.Total_Agreed_Amount__c==0?false:true;
            this.ClaimsDetails['Status'] = caseDetails.Status;
               
            this.ClaimsDetails['TT_respond_evidence_gathering__c'] = caseDetails.TT_respond_evidence_gathering__c;
            this.ClaimsDetails['totalAgreedByAGLL'] = parseFloat(caseDetails.Total_Agreed_by_AG_LL__c).toFixed(2);
            this.ClaimsDetails['totalAgreedByTT'] = parseFloat(caseDetails.Total_Agreed_by_Tenant__c).toFixed(2);
            this.ClaimsDetails['remainDisputeAmount'] = parseFloat(caseDetails.Total_Agreed_by_AG_LL__c - caseDetails.Total_Agreed_by_Tenant__c).toFixed(2);
            this.ClaimsDetails['Id'] = caseDetails.Id;
            this.ClaimsDetails['Evidence_Attachments__r'] = caseDetails.Evidence_Attachments__r;
            this.ClaimsDetails['Dispute_Responded_By__c'] = caseDetails.Dispute_Responded_By__c;
            this.ClaimsDetails['Additional_comments_AGLL__c'] = caseDetails.Additional_comments_AGLL__c;
            this.ClaimsDetails['Additional_comments_TT__c'] = caseDetails.Additional_comments_TT__c;
            this.ClaimsDetails['Additional_comments_TT__c_length'] = false;

            console.log('63' + caseDetails.Consent_box_TT__c  );
            if(caseDetails.Consent_box_TT__c =='Yes'){
               this.ClaimsDetails['Consent_box_TT__c'] = true;
            }
            else{
               this.ClaimsDetails['Consent_box_TT__c'] = false;
            }
            console.log('70' + this.ClaimsDetails['Consent_box_TT__c']  );
            if(caseDetails.Claim_exceed__c =='Yes' || caseDetails.Claim_exceed__c =='No'){
               if(caseDetails.Claim_exceed__c =='Yes'){
                  this.ClaimsDetails['claimExceed'] = true;
               }
               else if(caseDetails.Claim_exceed__c =='No'){
                  this.ClaimsDetails['claimExceed'] = false;
               }
            }
            this.ClaimsDetails['claimExceedsComment'] = caseDetails.Claim_exceeds_comment_AGLL__c;

            if(caseDetails.Tenant_obligations__c =='Yes' || caseDetails.Tenant_obligations__c =='No'){
               this.ClaimsDetails['isTenantObligationsValue'] = true;
               if(caseDetails.Tenant_obligations__c =='Yes'){
                  this.ClaimsDetails['TenantObligations'] = true;
               }
               else if(caseDetails.Tenant_obligations__c =='No'){
                  this.ClaimsDetails['TenantObligations'] = false;
               }
            }
            if(caseDetails.inventorycheck_in_report_AGLL__c =='Yes' || caseDetails.inventorycheck_in_report_AGLL__c =='No'){
               this.ClaimsDetails['isInventorycheckValue'] = true;
               if(caseDetails.inventorycheck_in_report_AGLL__c =='Yes'){
                  this.ClaimsDetails['inventorycheck'] = true;
               }
               else if(caseDetails.inventorycheck_in_report_AGLL__c =='No'){
                  this.ClaimsDetails['inventorycheck'] = false;
               }
            }
            if(caseDetails.check_out_report_AGLL__c =='Yes' || caseDetails.check_out_report_AGLL__c =='No'){
               this.ClaimsDetails['isCheckoutReportValue'] = true;
               if(caseDetails.check_out_report_AGLL__c =='Yes'){
                  this.ClaimsDetails['checkoutReport'] = true;
               }
               else if(caseDetails.check_out_report_AGLL__c =='No'){
                  this.ClaimsDetails['checkoutReport'] = false;
               }
            }
            if(caseDetails.Rent_statement_AGLL__c =='Yes' || caseDetails.Rent_statement_AGLL__c =='No'){
               this.ClaimsDetails['isRentStatementValue'] = true;
               if(caseDetails.Rent_statement_AGLL__c =='Yes'){
                  this.ClaimsDetails['rentStatement'] = true;
               }
               else if(caseDetails.Rent_statement_AGLL__c =='No'){
                  this.ClaimsDetails['rentStatement'] = false;
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

            if(claimItems){
               const rentItem = claimItems.find(item => item.Type__c == 'Rent');
               if(rentItem){
                  this.isShowPaymentOfRentKey = true;
               }else{
                  this.isShowPaymentOfRentKey = false;
               }
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
                        disputeItems[i]['isOther']= claimItems[j].Type__c == 'Other'?claimItems[j].Agreed_by_AGLL__c.toFixed(2)+'\n'+claimItems[j].Other_Reason__c:'';
                        disputeItems[i]['requestedByAGLL']= claimItems[j].Agreed_by_AGLL__c.toFixed(2);
                        disputeItems[i]['agreedbyTenant']= claimItems[j].Agreed_by_Tenant__c;
                        disputeItems[i]['amountInDispute']= claimItems[j].Agreed_by_AGLL__c - claimItems[j].Agreed_by_Tenant__c;
                        disputeItems[i][claimItems[j].Type__c] =true;
                        disputeItems[i]['isShow']= i==0?true:false;

                        disputeItems[i]['Id']= claimItems[j].Id;

                        disputeItems[i]['Claim_description_for_cleaning_agll__c']= claimItems[j].Claim_description_for_cleaning_agll__c;
                        disputeItems[i]['Supporting_clause_cleaning_agll__c']= claimItems[j].Supporting_clause_cleaning_agll__c;
                        disputeItems[i]['Evidence_at_tenancystart_cleaning_agll__c']= claimItems[j].Evidence_at_tenancystart_cleaning_agll__c;
                        disputeItems[i]['Evidence_at_tenancy_end_for_cleaning_agl__c']= claimItems[j].Evidence_at_tenancy_end_for_cleaning_agl__c;
                        disputeItems[i]['Supporting_evidence_for_cleaning_agll__c']= claimItems[j].Supporting_evidence_for_cleaning_agll__c;

                        disputeItems[i]['Claim_description_for_damage_agll__c']= claimItems[j].Claim_description_for_damage_agll__c;
                        disputeItems[i]['Supporting_clause_damage_agll__c']= claimItems[j].Supporting_clause_damage_agll__c;
                        disputeItems[i]['Evidence_at_tenancystart_damage_agll__c']= claimItems[j].Evidence_at_tenancystart_damage_agll__c;
                        disputeItems[i]['Evidence_at_tenancy_end_for_damage_agll__c']= claimItems[j].Evidence_at_tenancy_end_for_damage_agll__c;
                        disputeItems[i]['Supporting_evidence_for_damage_agll__c']= claimItems[j].Supporting_evidence_for_damage_agll__c;

                        disputeItems[i]['Claim_description_for_redecoration_agll__c']= claimItems[j].Claim_description_for_redecoration_agll__c;
                        disputeItems[i]['Supporting_clause_redecoration_agll__c']= claimItems[j].Supporting_clause_redecoration_agll__c;
                        disputeItems[i]['Evidence_at_tenancystart_redecoration_ag__c']= claimItems[j].Evidence_at_tenancystart_redecoration_ag__c;
                        disputeItems[i]['Evidence_at_tenancyend_redecoration_agll__c']= claimItems[j].Evidence_at_tenancyend_redecoration_agll__c;
                        disputeItems[i]['Supporting_evidence_for_redecoration_agl__c']= claimItems[j].Supporting_evidence_for_redecoration_agl__c;

                        disputeItems[i]['Claim_description_for_gardening_agll__c']= claimItems[j].Claim_description_for_gardening_agll__c;
                        disputeItems[i]['Supporting_clause_gardening_agll__c']= claimItems[j].Supporting_clause_gardening_agll__c;
                        disputeItems[i]['Evidence_at_tenancystart_gardening_agll__c']= claimItems[j].Evidence_at_tenancystart_gardening_agll__c;
                        disputeItems[i]['Evidence_at_tenancyend_gardening_agll__c']= claimItems[j].Evidence_at_tenancyend_gardening_agll__c;
                        disputeItems[i]['Supporting_evidence_for_gardening__c']= claimItems[j].Supporting_evidence_for_gardening__c;

                        disputeItems[i]['Rent_arrears_description_agll__c']= claimItems[j].Rent_arrears_description_agll__c;
                        disputeItems[i]['Was_the_property_re_let_rent_agll__c']= claimItems[j].Was_the_property_re_let_rent_agll__c;
                        disputeItems[i]['Supporting_clause_rent_agll__c']= claimItems[j].Supporting_clause_rent_agll__c;
                        disputeItems[i]['Supporting_evidence_for_rent_agll__c']= claimItems[j].Supporting_evidence_for_rent_agll__c;

                        disputeItems[i]['Claim_breakdown_other_AGLL__c']= claimItems[j].Claim_breakdown_other_AGLL__c;
                        disputeItems[i]['Supporting_clause_other_agll__c']= claimItems[j].Supporting_clause_other_agll__c;
                        disputeItems[i]['Supporting_evidence_for_other_agll__c']= claimItems[j].Supporting_evidence_for_other_agll__c;
                     
                        if(claimItems[j].Is_Tenant_Agree__c=='Yes' || claimItems[j].Is_Tenant_Agree__c=='No'){
                           disputeItems[i]['Is_Tenant_Agree__c_value']= true;
                           disputeItems[i]['Is_Tenant_Agree__c']= claimItems[j].Is_Tenant_Agree__c=='Yes'?true:false;
                        }else{
                           disputeItems[i]['Is_Tenant_Agree__c_value']= false;
                        }
                        disputeItems[i]['Tenant_Disagree_comment__c']= claimItems[j].Tenant_Disagree_comment__c;
                        disputeItems[i]['Tenant_Disagree_comment__c_length']=false;

                        if(claimItems[j].Is_Tenant_Upload_Evidence__c=='Yes' || claimItems[j].Is_Tenant_Upload_Evidence__c=='No'){
                           disputeItems[i]['Is_Tenant_Upload_Evidence__c_value']= true;
                           disputeItems[i]['Is_Tenant_Upload_Evidence__c']= claimItems[j].Is_Tenant_Upload_Evidence__c=='Yes'?true:false;
                           const eviAttachment = this.evidenceAttachments.find(evi => evi.Evidence_Categories__c == claimItems[j].Type__c && evi.User_Type__c == 'Tenant');
                           if(eviAttachment){
                              disputeItems[i]['evidence'+claimItems[j].Type__c] = true;
                           }else{
                              disputeItems[i]['evidence'+claimItems[j].Type__c] = false;
                           }
                        }else{
                           disputeItems[i]['Is_Tenant_Upload_Evidence__c_value']= false;
                        }
                     }
                  }
                  if(flag == false){
                     disputeItems.splice(i, 1);
                     i--;
                  }

            }
            this.disputeItems = disputeItems;

            let AGLLandTTCalaimDetails = [];
            AGLLandTTCalaimDetails.push({key:'CleaningAGLL'});
            AGLLandTTCalaimDetails.push({key:'CleaningTT'});
            AGLLandTTCalaimDetails.push({key:'DamageAGLL'});
            AGLLandTTCalaimDetails.push({key:'DamageTT'});
            AGLLandTTCalaimDetails.push({key:'RedecorationAGLL'});
            AGLLandTTCalaimDetails.push({key:'RedecorationTT'});
            AGLLandTTCalaimDetails.push({key:'GardeningAGLL'});
            AGLLandTTCalaimDetails.push({key:'GardeningTT'});
            AGLLandTTCalaimDetails.push({key:'RentAGLL'});
            AGLLandTTCalaimDetails.push({key:'RentTT'});
            AGLLandTTCalaimDetails.push({key:'OtherAGLL'});
            AGLLandTTCalaimDetails.push({key:'OtherTT'});
            for(let i=0; i<AGLLandTTCalaimDetails.length; i++){
               console.log('AGLLandTTCalaimDetails.length after');
               let flag = false;
               console.log('claimItems.length before');
               
               for(let j=0; j<claimItems.length; j++){
                  console.log('claimItems.length after');
                  if(AGLLandTTCalaimDetails[i].key.includes(claimItems[j].Type__c)){
                     flag = true;
                     AGLLandTTCalaimDetails[i]['isOther']= claimItems[j].Type__c == 'Other'?claimItems[j].Agreed_by_AGLL__c.toFixed(2)+' '+claimItems[j].Other_Reason__c:'';
                     AGLLandTTCalaimDetails[i]['requestedByAGLL']= claimItems[j].Agreed_by_AGLL__c.toFixed(2);
                     AGLLandTTCalaimDetails[i]['agreedbyTenant']= claimItems[j].Agreed_by_Tenant__c;
                     AGLLandTTCalaimDetails[i]['amountInDispute']= claimItems[j].Agreed_by_AGLL__c - claimItems[j].Agreed_by_Tenant__c;
                     AGLLandTTCalaimDetails[i][AGLLandTTCalaimDetails[i].key] =true;
                     AGLLandTTCalaimDetails[i]['isShow']= i==0?true:false;
                     AGLLandTTCalaimDetails[i]['type'] =claimItems[j].Type__c;

                     AGLLandTTCalaimDetails[i]['Id']= claimItems[j].Id;

                     AGLLandTTCalaimDetails[i]['Claim_description_for_cleaning_agll__c']= claimItems[j].Claim_description_for_cleaning_agll__c;
                     AGLLandTTCalaimDetails[i]['Supporting_clause_cleaning_agll__c']= claimItems[j].Supporting_clause_cleaning_agll__c;
                     AGLLandTTCalaimDetails[i]['Evidence_at_tenancystart_cleaning_agll__c']= claimItems[j].Evidence_at_tenancystart_cleaning_agll__c;
                     AGLLandTTCalaimDetails[i]['Evidence_at_tenancy_end_for_cleaning_agl__c']= claimItems[j].Evidence_at_tenancy_end_for_cleaning_agl__c;
                     AGLLandTTCalaimDetails[i]['Supporting_evidence_for_cleaning_agll__c']= claimItems[j].Supporting_evidence_for_cleaning_agll__c;

                     AGLLandTTCalaimDetails[i]['Claim_description_for_damage_agll__c']= claimItems[j].Claim_description_for_damage_agll__c;
                     AGLLandTTCalaimDetails[i]['Supporting_clause_damage_agll__c']= claimItems[j].Supporting_clause_damage_agll__c;
                     AGLLandTTCalaimDetails[i]['Evidence_at_tenancystart_damage_agll__c']= claimItems[j].Evidence_at_tenancystart_damage_agll__c;
                     AGLLandTTCalaimDetails[i]['Evidence_at_tenancy_end_for_damage_agll__c']= claimItems[j].Evidence_at_tenancy_end_for_damage_agll__c;
                     AGLLandTTCalaimDetails[i]['Supporting_evidence_for_damage_agll__c']= claimItems[j].Supporting_evidence_for_damage_agll__c;

                     AGLLandTTCalaimDetails[i]['Claim_description_for_redecoration_agll__c']= claimItems[j].Claim_description_for_redecoration_agll__c;
                     AGLLandTTCalaimDetails[i]['Supporting_clause_redecoration_agll__c']= claimItems[j].Supporting_clause_redecoration_agll__c;
                     AGLLandTTCalaimDetails[i]['Evidence_at_tenancystart_redecoration_ag__c']= claimItems[j].Evidence_at_tenancystart_redecoration_ag__c;
                     AGLLandTTCalaimDetails[i]['Evidence_at_tenancyend_redecoration_agll__c']= claimItems[j].Evidence_at_tenancyend_redecoration_agll__c;
                     AGLLandTTCalaimDetails[i]['Supporting_evidence_for_redecoration_agl__c']= claimItems[j].Supporting_evidence_for_redecoration_agl__c;

                     AGLLandTTCalaimDetails[i]['Claim_description_for_gardening_agll__c']= claimItems[j].Claim_description_for_gardening_agll__c;
                     AGLLandTTCalaimDetails[i]['Supporting_clause_gardening_agll__c']= claimItems[j].Supporting_clause_gardening_agll__c;
                     AGLLandTTCalaimDetails[i]['Evidence_at_tenancystart_gardening_agll__c']= claimItems[j].Evidence_at_tenancystart_gardening_agll__c;
                     AGLLandTTCalaimDetails[i]['Evidence_at_tenancyend_gardening_agll__c']= claimItems[j].Evidence_at_tenancyend_gardening_agll__c;
                     AGLLandTTCalaimDetails[i]['Supporting_evidence_for_gardening__c']= claimItems[j].Supporting_evidence_for_gardening__c;

                     AGLLandTTCalaimDetails[i]['Rent_arrears_description_agll__c']= claimItems[j].Rent_arrears_description_agll__c;
                     AGLLandTTCalaimDetails[i]['Was_the_property_re_let_rent_agll__c']= claimItems[j].Was_the_property_re_let_rent_agll__c;
                     AGLLandTTCalaimDetails[i]['Supporting_clause_rent_agll__c']= claimItems[j].Supporting_clause_rent_agll__c;
                     AGLLandTTCalaimDetails[i]['Supporting_evidence_for_rent_agll__c']= claimItems[j].Supporting_evidence_for_rent_agll__c;

                     AGLLandTTCalaimDetails[i]['Claim_breakdown_other_AGLL__c']= claimItems[j].Claim_breakdown_other_AGLL__c;
                     AGLLandTTCalaimDetails[i]['Supporting_clause_other_agll__c']= claimItems[j].Supporting_clause_other_agll__c;
                     AGLLandTTCalaimDetails[i]['Supporting_evidence_for_other_agll__c']= claimItems[j].Supporting_evidence_for_other_agll__c;
                  
                     if(claimItems[j].Is_Tenant_Agree__c=='Yes' || claimItems[j].Is_Tenant_Agree__c=='No'){
                        AGLLandTTCalaimDetails[i]['Is_Tenant_Agree__c_value']= true;
                        AGLLandTTCalaimDetails[i]['Is_Tenant_Agree__c']= claimItems[j].Is_Tenant_Agree__c=='Yes'?true:false;
                     }else{
                        AGLLandTTCalaimDetails[i]['Is_Tenant_Agree__c_value']= false;
                     }
                     AGLLandTTCalaimDetails[i]['Tenant_Disagree_comment__c']= claimItems[j].Tenant_Disagree_comment__c;
                     AGLLandTTCalaimDetails[i]['Tenant_Disagree_comment__c_length'] = false;

                     if(claimItems[j].Is_Tenant_Upload_Evidence__c=='Yes' || claimItems[j].Is_Tenant_Upload_Evidence__c=='No'){
                        AGLLandTTCalaimDetails[i]['Is_Tenant_Upload_Evidence__c_value']= true;
                        AGLLandTTCalaimDetails[i]['Is_Tenant_Upload_Evidence__c']= claimItems[j].Is_Tenant_Upload_Evidence__c=='Yes'?true:false;
                        const eviAttachment = this.evidenceAttachments.find(evi => evi.Evidence_Categories__c == claimItems[j].Type__c && evi.User_Type__c == 'Tenant');
                        if(eviAttachment){
                           AGLLandTTCalaimDetails[i]['evidence'+claimItems[j].Type__c] = true;
                        }else{
                           AGLLandTTCalaimDetails[i]['evidence'+claimItems[j].Type__c] = false;
                        }
                     }else{
                        AGLLandTTCalaimDetails[i]['Is_Tenant_Upload_Evidence__c_value']= false;
                     }

                     if(AGLLandTTCalaimDetails[i].key.includes('AGLL')){
                        if(AGLLandTTCalaimDetails[i].key.includes('Cleaning') || AGLLandTTCalaimDetails[i].key.includes('Damage') 
                        || AGLLandTTCalaimDetails[i].key.includes('Redecoration') || AGLLandTTCalaimDetails[i].key.includes('Gardening')){
                           AGLLandTTCalaimDetails[i]['AGLL_clean_damag_redecr_garden_greyText'] = true;
                        }
                        else if(AGLLandTTCalaimDetails[i].key.includes('Rent')){
                           AGLLandTTCalaimDetails[i]['AGLL_rent_greyText'] = true;
                        }
                        else if(AGLLandTTCalaimDetails[i].key.includes('Other')){
                           AGLLandTTCalaimDetails[i]['AGLL_other_greyText'] = true;
                        }
                     }else if(AGLLandTTCalaimDetails[i].key.includes('TT')){
                        if(AGLLandTTCalaimDetails[i].key.includes('Cleaning') || AGLLandTTCalaimDetails[i].key.includes('Damage') 
                        || AGLLandTTCalaimDetails[i].key.includes('Redecoration') || AGLLandTTCalaimDetails[i].key.includes('Gardening')
                        || AGLLandTTCalaimDetails[i].key.includes('Other'))
                        {
                           AGLLandTTCalaimDetails[i]['TT_clean_damag_redecr_garden_other_greyText'] = true;
                        }
                        else if(AGLLandTTCalaimDetails[i].key.includes('Rent')){
                           AGLLandTTCalaimDetails[i]['TT_rent_greyText'] = true;
                        }
                     }
                  }
               }
               if(flag == false){
                  AGLLandTTCalaimDetails.splice(i, 1);
                  i--;
               }
            }
            this.AGLLandTTCalaimDetails = AGLLandTTCalaimDetails;
            console.log('this.AGLLandTTCalaimDetails => ' + JSON.stringify(this.AGLLandTTCalaimDetails));

            fetchErrorLabel().then(result =>{
               console.log('fetchErrorLabel result => ' + JSON.stringify(result));
               let userErr = '';
               for(var i=0; i<result.length; i++){
                  console.log("line-->9  " +result[i].MasterLabel );
                  console.log("line-->9  " +result[i].Error_Message__c );
                  if(result[i].MasterLabel === 'Evidence Gathering  Tenant Respond'){
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
      console.log('getclaimdetailsInTenantEvidence error => ' + JSON.stringify(error), error);
      })

   }

   renderedCallback(){
      if(this.ClaimsDetails.Consent_box_TT__c && !this.isBankDetailsEmpty){
         this.template.querySelector('.consentbox').classList.add('blue_theme');
         this.template.querySelector('.consentbox').classList.remove('disable_ew_btn');
      }else{
         this.template.querySelector('.consentbox').classList.remove('blue_theme');
         this.template.querySelector('.consentbox').classList.add('disable_ew_btn');
      }
   }

   // render(){
   //    return claimBreakdownPage;
   // }
   handleDisputeItemValueChange(event){
      console.log(event.target.value);
      console.log('record Id  => ' + event.target.title);
      let selectRecordId = event.target.title;
      for(let i in this.disputeItems){
         if(this.disputeItems[i].Id == selectRecordId){
            let descText = event.target.value;
            if(event.target.name == 'Tenant_Disagree_comment__c'){
               if(descText.length > 30000){
                  event.target.value = descText.substring(0, 30000);
                  this.disputeItems[i][event.target.name+'_length'] = true;
                  this.AGLLandTTCalaimDetails[this.currentItem][event.target.name+'_length'] = true;
               }else{
                  this.disputeItems[i][event.target.name+'_length'] = false;
                  this.AGLLandTTCalaimDetails[this.currentItem][event.target.name+'_length'] = false;
               }
            }
            this.disputeItems[i][event.target.name] = event.target.value;

            console.log('length issue => ' + this.disputeItems[i][event.target.name+'_length']);
            console.log('this.disputeItems[this.currentItem][event.target.name] => ' + this.disputeItems[i][event.target.name])
         }
      }

      this.AGLLandTTCalaimDetails[this.currentItem][event.target.name] = event.target.value;
   }

   clickYes(event) {  
      let selectRecordId = event.target.title;
      let selectBtnName = event.target.name;
      console.log('selectRecordId => ' + selectRecordId);
      console.log('selectBtnName => ' + selectBtnName);
      for(let i in this.disputeItems){
         if(this.disputeItems[i].Id == selectRecordId){
            if(selectBtnName =='isTenantAgree'){
               this.disputeItems[i].Is_Tenant_Agree__c_value = true;
               this.disputeItems[i].Is_Tenant_Agree__c = true;
               this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c_value'] = true;
               this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c'] = true;
               this.template.querySelector('.istenantagreeyes').classList.add('active'); 
               this.template.querySelector('.istenantagreeno').classList.remove('active');
            }
            else if(selectBtnName =='isTTuploadEvid'){
               this.disputeItems[i].Is_Tenant_Upload_Evidence__c_value = true;
               this.disputeItems[i].Is_Tenant_Upload_Evidence__c = true;
               this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Upload_Evidence__c_value'] = true;
               this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Upload_Evidence__c'] = true;
               this.template.querySelector('.isttuploadevidyes').classList.add('active'); 
               this.template.querySelector('.isttuploadevidno').classList.remove('active');
            }
         }
      }
   }
  
   clickNo(event) {  
      let selectRecordId = event.target.title;
      let selectBtnName = event.target.name;
      console.log('selectRecordId => ' + selectRecordId);
      console.log('selectBtnName => ' + selectBtnName);
      for(let i in this.disputeItems){
         if(this.disputeItems[i].Id == selectRecordId){
            if(selectBtnName =='isTenantAgree'){
               this.disputeItems[i].Is_Tenant_Agree__c_value = true;
               this.disputeItems[i].Is_Tenant_Agree__c = false;
               this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c_value'] = true;
               this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c'] = false;
               this.template.querySelector('.istenantagreeyes').classList.remove('active'); 
               this.template.querySelector('.istenantagreeno').classList.add('active');
               
            }
            else if(selectBtnName =='isTTuploadEvid'){
               this.disputeItems[i].Is_Tenant_Upload_Evidence__c_value = true;
               this.disputeItems[i].Is_Tenant_Upload_Evidence__c = false;
               this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Upload_Evidence__c_value'] = true;
               this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Upload_Evidence__c'] = false;
               this.template.querySelector('.isttuploadevidyes').classList.remove('active'); 
               this.template.querySelector('.isttuploadevidno').classList.add('active');

            }
         }   
      }
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

   handleCheckConsent(){
      this.ClaimsDetails.Consent_box_TT__c = !this.ClaimsDetails.Consent_box_TT__c;
      console.log("ClaimsDetails.Consent_box_TT__c => " + this.ClaimsDetails.Consent_box_TT__c);
      console.log("this.template.querySelector('.consentbox') => " + this.template.querySelector('.consentbox'));

      if(this.ClaimsDetails.Consent_box_TT__c && !this.isBankDetailsEmpty){
         this.template.querySelector('.consentbox').classList.add('blue_theme');
         this.template.querySelector('.consentbox').classList.remove('disable_ew_btn');
      }else{
         this.template.querySelector('.consentbox').classList.remove('blue_theme');
         this.template.querySelector('.consentbox').classList.add('disable_ew_btn');
      }
   }

   handleGoBackStep(event){
      let title = event.target.title;
      if(title == 'viewContinue'){
         this.ViewContinue = true;
         this.keyDocuments = false;
      }
      else if(title == 'claimBreakdown'){
         this.keyDocuments = false;
         this.showClaimBreakdown = true;
         this.showAdditionalComments = false;
         setTimeout(() => {
            console.log('isvalue true ' + this.AGLLandTTCalaimDetails[this.currentItem].Is_Tenant_Agree__c_value);
            if(this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c_value']){

               if(this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c']){
                  console.log('istenantagreeyes => ' +this.template.querySelector('.istenantagreeyes'));
                  this.template.querySelector('.istenantagreeyes').classList.add('active'); 
               }
               else if(!this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c']){
                  console.log('istenantagreeno => ' +this.template.querySelector('.istenantagreeno'));
                  this.template.querySelector('.istenantagreeno').classList.add('active'); 
               }
            }

            if(this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Upload_Evidence__c_value']){

               if(this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Upload_Evidence__c']){
                  console.log('isttuploadevidyes => ' +this.template.querySelector('.isttuploadevidyes'));
                  this.template.querySelector('.isttuploadevidyes').classList.add('active'); 
               }
               else if(!this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Upload_Evidence__c']){
                  console.log('isttuploadevidno => ' +this.template.querySelector('.isttuploadevidno'));
                  this.template.querySelector('.isttuploadevidno').classList.add('active'); 
               }
            }
         }, 100); 
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

   handlegotoshowClaimBreakdown(){
      console.log('this.ClaimsDetails.Status => ' + this.ClaimsDetails.Status);
      console.log('this.cp.Type__c => ' + this.cp.Type__c);
      console.log('this.cp.Is_Lead__c => ' + this.cp.Is_Lead__c);
      if(this.ClaimsDetails.Status == 'Evidence gathering tenant' && this.cp.Type__c =='Tenant' && this.cp.Is_Lead__c == true){
         
         console.log("ClaimsDetails.Consent_box_TT__c => " + this.ClaimsDetails.Consent_box_TT__c);
         if(this.ClaimsDetails.Consent_box_TT__c && !this.isBankDetailsEmpty){
            updateClaimTT({ claimId:this.ClaimsDetails.Id, consentBox:true})
            .then(result=>{
               if(result == 'Case Status Changed'){
                  this.handlegotoDepositSummary();
               }
            }).catch(error => {
               console.log('updateClaimTT error => ' + JSON.stringify(error));
            });
            // setTimeout(() => {
            //    if(this.ClaimsDetails['Is_Tenant_Agree__c']){
            //       console.log('istenantagreeyes => ' +this.template.querySelector('.istenantagreeyes'));
            //       this.template.querySelector('.istenantagreeyes').classList.add('active'); 
            //    }
            //    else if(this.ClaimsDetails['Is_Tenant_Agree__c'] == false){
            //       console.log('istenantagreeno => ' +this.template.querySelector('.istenantagreeno'));
            //       this.template.querySelector('.istenantagreeno').classList.add('active'); 
            //    }
            // }, 100); 
            this.ViewContinue = false;
            this.showClaimBreakdown = true;
            this.showAdditionalComments = false;
            console.log('handlegotoshowClaimBreakdown end ' + this.showClaimBreakdown);

            console.log('scroll to top');
            const topDiv = this.template.querySelector('[data-id="scroll-to-top"]');
            topDiv.scrollIntoView({ behavior: "smooth", block: "center", inline: "nearest" });
         }
      }else{
         this.handlegotoDepositSummary();
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
      }else if(event.detail.type == 'Case Status Changed'){
         this.handlegotoDepositSummary();
      }

      const eviAttachment = this.evidenceAttachments.find(evi => 
         evi.Evidence_Categories__c == this.AGLLandTTCalaimDetails[this.currentItem].type && evi.User_Type__c == 'Tenant'
      );
      if(eviAttachment){
         this.AGLLandTTCalaimDetails[this.currentItem]['evidence'+this.AGLLandTTCalaimDetails[this.currentItem].type] = true;
      }else{
         this.AGLLandTTCalaimDetails[this.currentItem]['evidence'+this.AGLLandTTCalaimDetails[this.currentItem].type] = false;
      }
      console.log('this.evidenceAttachments after => '+ JSON.stringify(this.evidenceAttachments));

   }

   goToPreviousItem(event){
      this.isBreakdownContbtnDisable = false;
      console.log('goToPreviousItem currentItem => ' + this.currentItem);
      if(this.currentItem == 0){
         this.showClaimBreakdown = false;
         this.ViewContinue = true;
      }else{
         this.currentItem--;
         this.AGLLandTTCalaimDetails[this.currentItem].isShow = true;
         this.AGLLandTTCalaimDetails[this.currentItem+1].isShow = false;
         setTimeout(() => {
            console.log('isvalue true ' + this.AGLLandTTCalaimDetails[this.currentItem].Is_Tenant_Agree__c_value);

            if(this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c_value']){
               if(this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c']){
                  console.log('exceedclaimyes => ' +this.template.querySelector('.exceedclaimyes'));
                  this.template.querySelector('.istenantagreeyes').classList.add('active'); 
               }
               else if(!this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c']){
                  console.log('exceedclaimno => ' +this.template.querySelector('.exceedclaimno'));
                  this.template.querySelector('.istenantagreeno').classList.add('active'); 
               }
            }

            if(this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Upload_Evidence__c_value']){

               if(this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Upload_Evidence__c']){
                  console.log('isttuploadevidyes => ' +this.template.querySelector('.isttuploadevidyes'));
                  this.template.querySelector('.isttuploadevidyes').classList.add('active'); 
               }
               else if(!this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Upload_Evidence__c']){
                  console.log('isttuploadevidno => ' +this.template.querySelector('.isttuploadevidno'));
                  this.template.querySelector('.isttuploadevidno').classList.add('active'); 
               }
            }
         }, 100); 
      }
      console.log('scroll to top');
      const topDiv = this.template.querySelector('[data-id="scroll-to-top"]');
      topDiv.scrollIntoView({ behavior: "smooth", block: "center", inline: "nearest" });
   }
   goToNextItem(event){
      
      var isValid = true;
      var isLengthIssue = false;
      console.log(this.currentItem +' => ' + this.AGLLandTTCalaimDetails[this.currentItem].Tenant_Disagree_comment__c_length)
      if(!this.AGLLandTTCalaimDetails[this.currentItem].key.includes('AGLL')){
         // if(!this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c_value'] || 
         //    !this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Upload_Evidence__c_value'])
         // {
         //    isValid = false;
         // }else

         if(!this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c_value'])
         {
            isValid = false;
         }
         else if(this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c_value'] 
            && this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c'] 
            && this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Upload_Evidence__c_value']
            && this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Upload_Evidence__c']
            && !this.AGLLandTTCalaimDetails[this.currentItem]['evidence'+this.AGLLandTTCalaimDetails[this.currentItem].type])
         {
            isValid = false;
         }
         else if(this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c_value'] 
            && this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c'] 
            && this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Upload_Evidence__c_value']
            && this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Upload_Evidence__c']
            && this.AGLLandTTCalaimDetails[this.currentItem]['evidence'+this.AGLLandTTCalaimDetails[this.currentItem].type])
         {
            isValid = true;
         }
         else if(this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c_value'] 
            && this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c'])
         {
            isValid = true;
         }
         else if(this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c_value'] 
            && !this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c'] 
            && (this.AGLLandTTCalaimDetails[this.currentItem].Tenant_Disagree_comment__c == ''
            || this.AGLLandTTCalaimDetails[this.currentItem].Tenant_Disagree_comment__c == null || this.AGLLandTTCalaimDetails[this.currentItem].Tenant_Disagree_comment__c == undefined))
         {
            isValid = false;
         }
         else if(this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c_value'] 
            && !this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c'] 
            && !this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Upload_Evidence__c_value'])
         {
            isValid = false;
         }
         else if(this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c_value'] 
            && !this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c'] 
            && this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Upload_Evidence__c_value']
            && this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Upload_Evidence__c']
            && !this.AGLLandTTCalaimDetails[this.currentItem]['evidence'+this.AGLLandTTCalaimDetails[this.currentItem].type])
         {
            isValid = false;
         }
         else if(this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c_value'] 
            && !this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c'] 
            && this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Upload_Evidence__c_value']
            && this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Upload_Evidence__c']
            && this.AGLLandTTCalaimDetails[this.currentItem]['evidence'+this.AGLLandTTCalaimDetails[this.currentItem].type])
         {
            isValid = true;
         }
         else if(this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c_value'] 
            && !this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c'] 
            && this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Upload_Evidence__c_value']
            && !this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Upload_Evidence__c'])
         {
            isValid = true;
         }

         if(this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c_value'] 
            && !this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c'] 
            && this.AGLLandTTCalaimDetails[this.currentItem].Tenant_Disagree_comment__c_length)
         {
            isLengthIssue = true;
         }
      }

      console.log("isValid => " + isValid);
      console.log("isLengthIssue => " + isLengthIssue);
      if(isValid == true && isLengthIssue == false){
         this.isBreakdownContbtnDisable = false;
         
         if(!this.AGLLandTTCalaimDetails[this.currentItem].key.includes('AGLL')){
            let calimItems = [];
            for(let i in this.disputeItems){
               let claim={'Id': this.disputeItems[i].Id,
                  'Is_Tenant_Agree__c': this.disputeItems[i].Is_Tenant_Agree__c_value?this.disputeItems[i].Is_Tenant_Agree__c?'Yes':'No':null,
                  'Tenant_Disagree_comment__c': this.disputeItems[i].Tenant_Disagree_comment__c,
                  'Is_Tenant_Upload_Evidence__c': this.disputeItems[i].Is_Tenant_Upload_Evidence__c_value?this.disputeItems[i].Is_Tenant_Upload_Evidence__c?'Yes':'No':null,

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
            console.log('JSON.stringify(calimItems) => ' + JSON.stringify(calimItems));

            updateClaimItemTT({disputeItemRec: JSON.stringify(calimItems),  claimId: this.ClaimsDetails.Id, isTenantRespond: this.ClaimsDetails.TT_respond_evidence_gathering__c })
            .then(result =>{
               console.log("updateClaimItemTT result => " + result);
               this.response = result;
               console.log('result response => ' + this.response);
               console.log('response 1323=> ' + this.response);
               if(result == 'Case Status Changed'){
                  this.handlegotoDepositSummary();
               }else{
                  var totalItem = this.AGLLandTTCalaimDetails.length;
                  console.log('goToNextItem totalItem => ' + totalItem);
                  console.log('goToNextItem currentItem => ' + this.currentItem);
                  if(this.currentItem == totalItem-1){
                     this.showClaimBreakdown = false;
                     let isAllAgreed = true;
                     for(let i in this.AGLLandTTCalaimDetails){
                        if(!this.AGLLandTTCalaimDetails[i].key.includes('AGLL') && !this.AGLLandTTCalaimDetails[i].Is_Tenant_Agree__c){
                           isAllAgreed = false;
                           break;
                        }
                     }
                     if(isAllAgreed){
                        this.showAllClaimAgreed = true;
                     }else{
                        this.showAdditionalComments = true;
                     }
                  }else {
                     this.AGLLandTTCalaimDetails[this.currentItem].isShow = false;
                     this.AGLLandTTCalaimDetails[this.currentItem+1].isShow = true;
                     this.currentItem++;
                     setTimeout(() => {
                        console.log('isvalue true ' + this.AGLLandTTCalaimDetails[this.currentItem].Is_Tenant_Agree__c_value);
                        if(this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c_value']){
      
                           if(this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c']){
                              console.log('istenantagreeyes => ' +this.template.querySelector('.istenantagreeyes'));
                              this.template.querySelector('.istenantagreeyes').classList.add('active'); 
                           }
                           else if(!this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c']){
                              console.log('istenantagreeno => ' +this.template.querySelector('.istenantagreeno'));
                              this.template.querySelector('.istenantagreeno').classList.add('active'); 
                           }
                        }
      
                        if(this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Upload_Evidence__c_value']){
      
                           if(this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Upload_Evidence__c']){
                              console.log('isttuploadevidyes => ' +this.template.querySelector('.isttuploadevidyes'));
                              this.template.querySelector('.isttuploadevidyes').classList.add('active'); 
                           }
                           else if(!this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Upload_Evidence__c']){
                              console.log('isttuploadevidno => ' +this.template.querySelector('.isttuploadevidno'));
                              this.template.querySelector('.isttuploadevidno').classList.add('active'); 
                           }
                        }
                     }, 100); 
                  }
                  console.log('Is_Tenant_Agree__c_value' + this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c_value']);
                  console.log('Is_Tenant_Upload_Evidence__c_value' + this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Upload_Evidence__c_value']);
      
                  console.log('scroll to top');
                  const topDiv = this.template.querySelector('[data-id="scroll-to-top"]');
                  topDiv.scrollIntoView({ behavior: "smooth", block: "center", inline: "nearest" });
               }
               // console.log("updateClaimItemTT result => " + JSON.stringify(result));
               // alert('updateClaimItemTT');
            }).catch(error=> {
               console.log('updateClaimItemTT error => ' + error + JSON.stringify(error));
            });
         }else{
            var totalItem = this.AGLLandTTCalaimDetails.length;
            console.log('goToNextItem totalItem => ' + totalItem);
            console.log('goToNextItem currentItem => ' + this.currentItem);
            if(this.currentItem == totalItem-1){
               this.showClaimBreakdown = false;
               let isAllAgreed = true;
               for(let i in this.AGLLandTTCalaimDetails){
                  if(!this.AGLLandTTCalaimDetails[i].key.includes('AGLL') && !this.AGLLandTTCalaimDetails[i].Is_Tenant_Agree__c){
                     isAllAgreed = false;
                     break;
                  }
               }
               if(isAllAgreed){
                  this.showAllClaimAgreed = true;
               }else{
                  this.showAdditionalComments = true;
               }
            }else {
               this.AGLLandTTCalaimDetails[this.currentItem].isShow = false;
               this.AGLLandTTCalaimDetails[this.currentItem+1].isShow = true;
               this.currentItem++;
               setTimeout(() => {
                  console.log('isvalue true ' + this.AGLLandTTCalaimDetails[this.currentItem].Is_Tenant_Agree__c_value);
                  if(this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c_value']){

                     if(this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c']){
                        console.log('istenantagreeyes => ' +this.template.querySelector('.istenantagreeyes'));
                        this.template.querySelector('.istenantagreeyes').classList.add('active'); 
                     }
                     else if(!this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c']){
                        console.log('istenantagreeno => ' +this.template.querySelector('.istenantagreeno'));
                        this.template.querySelector('.istenantagreeno').classList.add('active'); 
                     }
                  }

                  if(this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Upload_Evidence__c_value']){

                     if(this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Upload_Evidence__c']){
                        console.log('isttuploadevidyes => ' +this.template.querySelector('.isttuploadevidyes'));
                        this.template.querySelector('.isttuploadevidyes').classList.add('active'); 
                     }
                     else if(!this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Upload_Evidence__c']){
                        console.log('isttuploadevidno => ' +this.template.querySelector('.isttuploadevidno'));
                        this.template.querySelector('.isttuploadevidno').classList.add('active'); 
                     }
                  }
               }, 100); 
            }
            console.log('Is_Tenant_Agree__c_value' + this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c_value']);
            console.log('Is_Tenant_Upload_Evidence__c_value' + this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Upload_Evidence__c_value']);

            console.log('scroll to top');
            const topDiv = this.template.querySelector('[data-id="scroll-to-top"]');
            topDiv.scrollIntoView({ behavior: "smooth", block: "center", inline: "nearest" });
         }
         
      }
      else if(!isValid){
         this.isBreakdownContbtnDisable = true;
      }
   }

   handleAdditionalCommentValuesChange(event){
      console.log(event.target.value);
      //this.ClaimsDetails[event.target.name] = event.target.value;
      var descText = event.target.value;
      if(descText.length > 2000){
         event.target.value = descText.substring(0, 2000);
         this.ClaimsDetails[event.target.name+'_length'] = true;
      }else{
         this.ClaimsDetails[event.target.name] = descText;
         this.ClaimsDetails[event.target.name+'_length'] = false;
      }
   }

   handlegotoshowReviewsubmission(){
      isSubmitEdiEvidenceAllowed({caseId:this.ClaimsDetails.Id}).then(result=>{
         console.log('isSubmitEdiEvidenceAllowed result => ' + result);
         if(result == true){
            if(!this.ClaimsDetails.Additional_comments_TT__c_length){
               updateAdditionalCommentsTT({ caseId:this.ClaimsDetails.Id, additionalComment:this.ClaimsDetails.Additional_comments_TT__c})
               .then(result=>{
                  console.log('updateAdditionalCommentsTT result => ' + result);
                  this.response = result;
                  if(this.response == 'Case Status Changed'){
                     this.handlegotoDepositSummary();
                  }else{
                     // alert('if true' + this.ClaimsDetails.respondDate);
                     this.showAdditionalComments = false;
                     this.showReviewsubmission = true;
         
                     console.log('scroll to top');
                     const topDiv = this.template.querySelector('[data-id="scroll-to-top"]');
                     topDiv.scrollIntoView({ behavior: "smooth", block: "center", inline: "nearest" });
                  }
               }).catch(error=>{
                  console.log('updateAdditionalCommentsTT error => ' + error);
               });
               
            }
         }else{
            this.handlegotoDepositSummary();
         }
      }).catch(error=> {
         console.log('isSubmitEdiEvidenceAllowed error => ' + error);
      })
   }

   handlegotoshowCancelDispute(){
      if(this.ClaimsDetails.Status == 'Evidence gathering tenant'){
         if(this.ViewContinue){
            this.cancelFromPage = 'ViewContinue';
            this.ViewContinue = false;
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

         console.log('scroll to top');
         const topDiv = this.template.querySelector('[data-id="scroll-to-top"]');
         topDiv.scrollIntoView({ behavior: "smooth", block: "center", inline: "nearest" });
      }
   }
   handleBackFromCancelDispute(){
      if(this.showAllClaimAgreed){
         this.showAllClaimAgreed = false;
         this.showClaimBreakdown = true;
         setTimeout(() => {
            console.log('isvalue true ' + this.AGLLandTTCalaimDetails[this.currentItem].Is_Tenant_Agree__c_value);
            if(this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c_value']){

               if(this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c']){
                  console.log('istenantagreeyes => ' +this.template.querySelector('.istenantagreeyes'));
                  this.template.querySelector('.istenantagreeyes').classList.add('active'); 
               }
               else if(!this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c']){
                  console.log('istenantagreeno => ' +this.template.querySelector('.istenantagreeno'));
                  this.template.querySelector('.istenantagreeno').classList.add('active'); 
               }
            }

            if(this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Upload_Evidence__c_value']){

               if(this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Upload_Evidence__c']){
                  console.log('isttuploadevidyes => ' +this.template.querySelector('.isttuploadevidyes'));
                  this.template.querySelector('.isttuploadevidyes').classList.add('active'); 
               }
               else if(!this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Upload_Evidence__c']){
                  console.log('isttuploadevidno => ' +this.template.querySelector('.isttuploadevidno'));
                  this.template.querySelector('.isttuploadevidno').classList.add('active'); 
               }
            }
         }, 100); 
      }
      this.showCancelDispute = false;
      
      if(this.cancelFromPage == 'ViewContinue'){
         this.ViewContinue = true;
      }
      else if(this.cancelFromPage == 'showClaimBreakdown'){
         this.showClaimBreakdown = true;
         setTimeout(() => {
            console.log('isvalue true ' + this.AGLLandTTCalaimDetails[this.currentItem].Is_Tenant_Agree__c_value);
            if(this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c_value']){

               if(this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c']){
                  console.log('istenantagreeyes => ' +this.template.querySelector('.istenantagreeyes'));
                  this.template.querySelector('.istenantagreeyes').classList.add('active'); 
               }
               else if(!this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Agree__c']){
                  console.log('istenantagreeno => ' +this.template.querySelector('.istenantagreeno'));
                  this.template.querySelector('.istenantagreeno').classList.add('active'); 
               }
            }

            if(this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Upload_Evidence__c_value']){

               if(this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Upload_Evidence__c']){
                  console.log('isttuploadevidyes => ' +this.template.querySelector('.isttuploadevidyes'));
                  this.template.querySelector('.isttuploadevidyes').classList.add('active'); 
               }
               else if(!this.AGLLandTTCalaimDetails[this.currentItem]['Is_Tenant_Upload_Evidence__c']){
                  console.log('isttuploadevidno => ' +this.template.querySelector('.isttuploadevidno'));
                  this.template.querySelector('.isttuploadevidno').classList.add('active'); 
               }
            }
         }, 100); 
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
      // alert('handleConfirmCancelDispute start');
      if(this.isHoldingDisputedFunds){
      // alert('handleConfirmCancelDispute isHoldingDisputedFunds => ' + this.isHoldingDisputedFunds);

         cancelclaimHoldingDisputedAmount({caseid: this.ClaimsDetails.Id, disptAmount: this.ClaimsDetails.Total_Protected_Amount__c})
         .then(result=>{
            console.log('cancelclaimHoldingDisputedAmount result => ' + result);
            this.handlegotoDepositSummary();
         }).catch(error=>{
            console.log('cancelclaimHoldingDisputedAmount error => ' + error);
         });
      }else{
         cancelclaimNotHoldingDisputedAmount({caseid: this.ClaimsDetails.Id, disptAmount: this.ClaimsDetails.Total_Protected_Amount__c})
         .then(result=>{
            console.log('cancelclaimNotHoldingDisputedAmount result => ' + result);
            this.handlegotoDepositSummary();
         }).catch(error=>{
            console.log('cancelclaimNotHoldingDisputedAmount error => ' + error);
         });
      }
      // alert('handleConfirmCancelDispute start');

   }

   getHelpArticleDocument(){
      //alert("call get guide doc");
      window.open('https://ewinsureddev.blob.core.windows.net/ewinsureddev/5003G000008RH95QAG-1670487092870-TDS%20Help%20Article_v2.pdf?sp=rw&st=2022-04-05T08:51:01Z&se=2032-04-05T16:51:01Z&spr=https&sv=2020-08-04&sr=c&sig=vbBtrfu%2BbFNQQp1SY8AZ3kTf2z9MKp%2F3Hnia3FLKKCg%3D', 
                    '_blank');
      // getHelpArticleDocument().then(result=>{
      //    console.log('result => ' + result)
      //    var res = result;
      //    console.log("Guidance document Id => " + res);
      //    window.open('https://ewinsureddev.blob.core.windows.net/ewinsureddev/5003G000008RH95QAG-1670487092870-TDS%20Help%20Article_v2.pdf?sp=rw&st=2022-04-05T08:51:01Z&se=2032-04-05T16:51:01Z&spr=https&sv=2020-08-04&sr=c&sig=vbBtrfu%2BbFNQQp1SY8AZ3kTf2z9MKp%2F3Hnia3FLKKCg%3D', 
      //    '_blank');
      //    // window.open("/servlet/servlet.FileDownload?file="+res); 
      // }).catch(error=>{
      //    consol.log('error => ' + error);
      // });
   }
}