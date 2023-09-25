import { LightningElement,track,wire,api} from 'lwc';
import EWITheme from '@salesforce/resourceUrl/EWITheme';
import {getPicklistValues, getObjectInfo} from 'lightning/uiObjectInfoApi';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import SALUTATION_FIELD from '@salesforce/schema/Contact.Salutation';
import getPersonDetails from '@salesforce/apex/el_EWI_MyAccountClass.getPersonDetails';
import updateDetails from '@salesforce/apex/el_EWI_MyAccountClass.updateDetails';
import updateBankDetails from '@salesforce/apex/el_EWI_MyAccountClass.updateBankDetails';
import updateInterBankDetails from '@salesforce/apex/el_EWI_MyAccountClass.updateInterBankDetails';
import EWIVPlus_Link from '@salesforce/label/c.EWIVPlus_Link';

export default class El_EWI_MyAccountTenantComponent extends LightningElement {

ew_arrow_dropleft = EWITheme + '/assets/img/ew-arrow-dropleft.png';
@track accesscode;
@track getContactRecord;
@track message;
@track personRecord;
@track cp;
@track phoneCodes;
@track countrycode = [];
@track Salutation;
@track Phone;
@track Email;
@track MailingStreet;
@track MailingCity;
@track MailingState;
@track MailingCountry;
@track MailingPostalCode;
@track MailingAddress;
@track bankAccountName;
@track bankAccountNumber;
@track bankName;
@track Sortcodelengtherror=false;
@track invalidSortCodeError = false;
@track invalidIBANError = false;
@track sortCodeBlankError = false;
@track bankOfAmericaSortCode = false;
@track nameOnAccountBlankError = false;
@track nameOnAccountNumericError = false;
@track nameOnAccountSpecialCharError = false;
@track accountNumberBlankError = false;
@track accountNumberLengthError=false;
@track invalidAccountNumberError = false;
@track bankSuccessMessage =false;
@track bankErrorMessage = false;
@track EmailError = false;
@track validAddressWithPostcodeError=false;
@track nameOnInterAccBlankError = false;
@track nameOnInterAccNumericError = false;

@track inteBankAccountError = false;
@track interIBANISBlankError=false;
@track ibanspecialcharactererror = false;
@track lenghtOfIBan=false;
@track interSuccessMessage=false;
@track PhoneError=false;
@track phoneCodeValueError=false;
@track contactSuccessMessage=false;
@track emailRegexError= false;
@track beneficiaryHomeRequird = false;
@track primaryAddress = {AddressLine:'', Street:'', Town:'', County:'', Postcode:'', Country:'', localAuthorityArea:''};
@track showDetails = true;

salutationPicklist = [];
showButtons = false;
flag = true;
doInitLoad = false;

hideBootstrapErrors(event){
   var button_Name = event.currentTarget.name;
  console.log('hideBootstrapErrors button_Name => '+button_Name);

switch (button_Name) {
case "EmailError":
  this.EmailError=false;
  break;
case "emailRegexError":
  this.emailRegexError=false;
  break;
case "PhoneError":
  this.PhoneError = false;
  break;  
case "phoneCodeValueError":
  this.phoneCodeValueError=false;
  break;   
case "validAddressWithPostcodeError":
  this.validAddressWithPostcodeError=false;
  break;    
case "contactSuccessMessage":
  this.contactSuccessMessage=false;
  break;  
case "SuccessMessage":
  this.successMsg = false;
  break;
case "ErrorMessage":
  this.errorMsg = false;
  break;
case "Sortcodelengtherror":
  this.Sortcodelengtherror = false;
  break;
case "invalidSortCodeError":
  this.invalidSortCodeError = false;
  break;
case "sortCodeBlankError":
  this.sortCodeBlankError = false;
  break;
case "bankOfAmericaSortCode":
  this.bankOfAmericaSortCode = false;
  break;    
case "nameOnAccountBlankError":
  this.nameOnAccountBlankError = false;
  break;  
  case "nameOnAccountNumericError":
  this.nameOnAccountNumericError = false;
  break; 
case  "accountNumberNotBlank" :
  this.accountNumberNotBlank = false; 
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
case "invalidIBANError":
  this.invalidIBANError = false;
  break;
case "ibanspecialcharactererror":
  this.ibanspecialcharactererror = false;
  break;
case "successMessage":
  this.successMessage=false;
  break;  
case "blankSortCodeError" :
  this.blankSortCodeError = false;
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
  case "nameOnInterAccNumericError":
  this.nameOnInterAccNumericError=false;
  break;
case "interIBANISBlankError":
  this.interIBANISBlankError=false;
  break;   
case "beneficiaryHomeRequird":
  this.beneficiaryHomeRequird= false;
  break;  
case "bankSuccessMessage":
  this.bankSuccessMessage = false;
  break;
case "bankErrorMessage":
  this.bankErrorMessage = false;
  break;    
case "lenghtOfIBan":
  this.lenghtOfIBan = false;
  break; 
}
}

phoneCodeInpChange(event){
  event.preventDefault();
  this.cp.Phone_Code__c = event.target.value;
   for(let ind in this.countrycode){
    if(this.cp.Phone_Code__c == this.countrycode[ind].key)
      this.countrycode[ind].value = true;   
  }
}
phoneInpChange(event){
  event.preventDefault();
  this.cp.Phone__c = event.target.value;
}
emailInpChange(event){
  event.preventDefault();
  this.cp.Primary_Email__c=event.target.value;
}

handlebankAccountNumberChange(event){
  this.cp.Bank_Account_Number__c =event.target.value;
  }
handlebankAccountNamechange(event){
  this.cp.Bank_Account_Holder_Name__c=event.target.value;
  //this.cp.Bank_Name__c = event.target.value;
}
handlesortcodeChange(event){
  this.cp.Bank_Sort_Code__c =event.target.value;
}
handleinternationalbankAccountName(event){
  this.cp.International_Bank_Account_Holder_Name__c =event.target.value;
}
handleinternationalIdentificationCode(event){
  this.cp.Bank_Identification_Code__c =event.target.value;
}
handleIBAN(event){
  this.cp.International_Account_Number__c =event.target.value;
}
handleinternationalBankName(event){
  this.cp.International_Bank_Name__c =event.target.value;
}
handleinternationalBenificiaryAddress(event){
  this.cp.Beneficiary_Home_Address__c =event.target.value;
}
handleinternationalbankswiftCode(event){
    this.cp.Swift_Code__c =event.target.value;
}

titleInpChange(event){
  event.preventDefault();
  this.Salutation = event.target.value;
  for(let ind in this.salutationPicklist){
    if(this.Salutation == this.salutationPicklist[ind].key)
      this.salutationPicklist[ind].value = true;
  }
}

// For handling event from child component(address finder) component for onselectingaddress event i.e. selecting automatically
selectingAddressHandler(event) {
  let returnedData = event.detail;
  if(returnedData.addressType=='Address') {
this.primaryAddress = returnedData.addressObj;
this.MailingStreet = this.primaryAddress.AddressLine;
this.MailingCity =   this.primaryAddress.Town;
this.MailingState =  this.primaryAddress.County;
this.MailingCountry= this.primaryAddress.Country;
this.MailingPostalCode = this.primaryAddress.Postcode;

this.cp.Street__c = this.primaryAddress.AddressLine;
this.cp.City__c =   this.primaryAddress.Town;
this.cp.State__c =  this.primaryAddress.County;
this.cp.Country__c= this.primaryAddress.Country;
this.cp.Postal_Code__c = this.primaryAddress.Postcode;

// this.MailingAddress;

  }
  }

  // For handling event from child component(address finder) for 'onfieldchange' event i.e. entering manually
  addressFieldChangeHandler(event) {
    let returnedData = event.detail;
    
    if(returnedData.addressType=='Address') {
      if(returnedData.fieldName.includes("TownCity")) {
        this.primaryAddress = {...this.primaryAddress, "Town":returnedData.value}
        this.MailingCity =   this.primaryAddress.Town;
        this.cp.City__c =   this.primaryAddress.Town;
      }
      else if(returnedData.fieldName.includes("County")) {
        this.primaryAddress = {...this.primaryAddress, "County":returnedData.value}
        this.MailingState =  this.primaryAddress.County;
        this.cp.State__c =  this.primaryAddress.County;
      }
      else if(returnedData.fieldName.includes("Postcode")) {
        this.primaryAddress = {...this.primaryAddress, "PostCode":returnedData.value}
        this.MailingPostalCode = this.primaryAddress.Postcode;
        this.cp.Postal_Code__c = this.primaryAddress.Postcode;
      }
      else if(returnedData.fieldName.includes("Country")) {
        this.primaryAddress = {...this.primaryAddress, "Country":returnedData.value}
        this.MailingCountry= this.primaryAddress.Country;
        this.cp.Country__c= this.primaryAddress.Country;
      }
      else if(returnedData.fieldName.includes("Street")) {
        this.primaryAddress = {...this.primaryAddress, "Street":returnedData.value}
        this.MailingStreet = String(this.primaryAddress.Street);
        this.cp.Street__c = this.primaryAddress.Street;
      }
    }
  }

  handleEdit(){
    this.showButtons = true;
    this.flag = false;
  }

@wire(getObjectInfo, { objectApiName: CONTACT_OBJECT }) contactMetadata;

@wire(getPicklistValues, { recordTypeId: '$contactMetadata.data.defaultRecordTypeId', fieldApiName: SALUTATION_FIELD })
    wiredPicklistValues({error, data}) {
      setTimeout(() => { window.history.forward();  }, 0);

      const queryString = window.location.search;
      const urlParams = new URLSearchParams(queryString);
      const recId = urlParams.get('accessCode');
      this.accesscode = recId;
      if(recId == '' || recId == null){
        this.showDetails = false;
        return;
      }
      console.log('recId => ' + recId);
      if(!this.doInitLoad){
        this.doInitLoad = true;
        getPersonDetails({accessCode : recId}).then(result =>{
            this.handleDoInit(result);
        }).catch(error => {
            console.log(" getContactDetail error : ", error)
        });
      }

        /*if(data){
            console.log("salutationPicklist data => " + JSON.stringify(data.values));
            for(let val in data.values){
              this.salutationPicklist.push({key: data.values[val].value, value: false});
            }
        }else{
            console.log('Get picklist values Error: ' + JSON.stringify(error))
        }*/
    }

    //code for capitalization start
capitalizeWord(element){
  if(element == '' || element == null || element==undefined){ return ''; }
  let str = '';
  let flag = false;
  for(let e=0; e<element.length; e++){
      
      if (element[e].match(/[a-z]/i)) {
          if(flag == false){
            str+=element[e].toUpperCase();
            flag = true;
          }else{
              str+=element[e].toLowerCase();
          }
      }else{
          str+=element[e];
      }
  }
  return str;
}
//code for captalization end

/***Update Contact detail***/
handleContactUpdate(){
  var isValid = false;
  if(this.handleValidations()){

  this.contactSuccessMessage = false;
  isValid = true;
  let result = {};
  result.con = this.personRecord;
  result.caseParticipants = this.cp;
  console.log("updateDetails result => " + JSON.stringify(result));

  updateDetails({ strResult : JSON.stringify(result)})

  .then(result=>{

    this.contactSuccessMessage = true;
    console.log('this.contactSuccessMessage');
    this.flag=true;
    eval("$A.get('e.force:refreshView').fire();");
   // this.handleDoInit(result);
    this.template.querySelector(".errorMsgDiv3").scrollIntoView();

    }) .catch(error=>{
      this.error=error.message;
      console.log(this.error);
    });
  }
  if(isValid==false){
    this.template.querySelector(".errorMsgDiv3").scrollIntoView();
  }
  
}

/***Update Bank detail***/
handleBankUpdate(){
  
  var isValid = false;
  this.invalidSortCodeError = false; 
  this.invalidAccountNumberError = false;
  this.bankSuccessMessage = false;

  let result = {};
  result.con = this.personRecord;
  result.caseParticipants = this.cp;
  
  if(this.handleBankValidation()) {
  updateBankDetails({strResult : JSON.stringify(result)})
    .then(result=>{

      var messageValue = result;
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

/***Update International Bank detail***/
handleInternationalBank(){
  var isValid = false;
  let result = {};
  result.con = this.personRecord;
  result.caseParticipants = this.cp;

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


 /**Validation for Contact **/  
 handleValidations(){
  var isValid = true;
  let casePar = this.cp;
  const emailRegex=/^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
  if (casePar.Primary_Email__c == null || casePar.Primary_Email__c=='' || casePar.Primary_Email__c ==undefined ) {
    this.EmailError =true;
    isValid =false;
  }
 else{
  if(!casePar.Primary_Email__c.match(emailRegex)) {
    this.emailRegexError=true;
    isValid = false;
  }

  else{
   // this.EmailError =false;
    this.emailRegexError=false;
  }
 }

  // if( casePar.Phone__c == undefined || casePar.Phone__c == "" || casePar.Phone__c == null){
  //   this.PhoneError= true;
  //   this.phoneCodeValueError = false;
  //   isValid = false;
  // }
      
    if( casePar.Phone__c != undefined && casePar.Phone__c != "" && casePar.Phone__c != null){
      if(casePar.Phone_Code__c == '+44' && (casePar.Phone__c.length != 11 || !casePar.Phone__c.startsWith("07") ) ){
        this.PhoneError= false;  
        this.phoneCodeValueError = true;
        isValid = false;
      }
    }

    // if((this.MailingStreet == undefined || this.MailingStreet == "" || this.MailingStreet == null) ||
    //     (this.MailingCity == undefined || this.MailingCity == "" || this.MailingCity == null) ||
    //     // (this.MailingState == undefined || this.MailingState == "" || this.MailingState == null) &&
    //     (this.MailingCountry == undefined || this.MailingCountry == "" || this.MailingCountry == null) ||
    //     (this.MailingPostalCode == undefined || this.MailingPostalCode == "" || this.MailingPostalCode == null)){
    //   this.validAddressWithPostcodeError=true;
    //   isValid = false;
    // }
    // else{
    //   this.validAddressWithPostcodeError=false;  
    // }
    return isValid;
}
  handleBankValidation(){
    var isValid = true;
    let casePar = this.cp;
    var accountnummberalphaCharacter = /[A-Za-z]/;
    var Numberonlycheck = /^\d+$/;
    this.bankSuccessMessage = false;
    this.sortCodeBlankError = false;
    this.bankErrorMessage = false;
    this.invalidSortCodeError = false; 
    this.bankOfAmericaSortCode =false;
    this.nameOnAccountBlankError = false;
    this.nameOnAccountNumericError = false;
    this.nameOnAccountSpecialCharError = false;
    this.accountNumberBlankError = false;
    this.invalidAccountNumberError = false;
    this.Sortcodelengtherror = false;
    this.accountNumberLengthError=false; 

    if (casePar.Bank_Account_Holder_Name__c == undefined ||casePar.Bank_Account_Holder_Name__c == "" ||casePar.Bank_Account_Holder_Name__c == null) {
      console.log("bankAccountNames is blank");
      isValid = false;
      this.nameOnAccountBlankError = true;
      this.bankSuccessMessage = false;
    }
    if (casePar.Bank_Account_Holder_Name__c && !isNaN(casePar.Bank_Account_Holder_Name__c)) {
      
      isValid = false;
      this.nameOnAccountNumericError = true;
      this.bankSuccessMessage = false;
    }

    if(casePar.Bank_Sort_Code__c == undefined || casePar.Bank_Sort_Code__c == "" || casePar.Bank_Sort_Code__c == null) {
      console.log('lbankDetail.Sort_Code__c ' +  casePar.Bank_Sort_Code__c);
      isValid = false;
      this.sortCodeBlankError = true;
      this.bankSuccessMessage = false;
      // this.bankOfAmericaSortCode = false;
      }

      
    if(casePar.Bank_Sort_Code__c){
      if(casePar.Bank_Sort_Code__c.length <6 ||  casePar.Bank_Sort_Code__c.length>6){
        this.Sortcodelengtherror = true;
        isValid = false;
      }
      }

      if(casePar.Bank_Sort_Code__c == '234079'){
        isValid = false;
        this.bankOfAmericaSortCode = true;
        this.sortCodeBlankError = false;
      }

    if(casePar.Bank_Sort_Code__c){
        console.log('line--> 608 ' + accountnummberalphaCharacter.test(casePar.Sort_Code__c));
      if(!Numberonlycheck.test(casePar.Bank_Sort_Code__c)){
        isValid = false;
        this.invalidSortCodeError = true;
        this.sortCodeBlankError = false;
      }

      if(casePar.Bank_Sort_Code__c.length <6 ||  casePar.Bank_Sort_Code__c.length>6){
        this.Sortcodelengtherror = true;
        isValid = false;
      }
    }

    if(casePar.Bank_Account_Number__c){
      if((!Numberonlycheck.test(casePar.Bank_Account_Number__c))){
        isValid = false;
        this.invalidAccountNumberError=true;
        this.sortCodeBlankError = false;
        this.bankErrorMessage = false;
      }
    }

    if (casePar.Bank_Account_Number__c == undefined ||casePar.Bank_Account_Number__c == "" ||casePar.Bank_Account_Number__c == null) {
      console.log('accountNumber blank');
      isValid = false;
     this.accountNumberBlankError = true;
   }
  
    if (casePar.Bank_Account_Number__c){
    if (casePar.Bank_Account_Number__c.length<8 || casePar.Bank_Account_Number__c.length >8 ){
      this.accountNumberLengthError=true;
      isValid = false;
    }
   }

  //code for pattern regex
  var pattermatch = /(012|123|234|345|456|567|678|789|111|222|333|444|555|666|777|888|999|987|765|654|543|432|321|210)/g ;
  console.log('pattern='+pattermatch);
  console.log('this.bankAccountNumber='+ casePar.Bank_Account_Number__c);
    //if(pattermatch.test(this.bankAccountNumber)){
      var passBankAccNumber =  casePar.Bank_Account_Number__c;
    if(pattermatch.test(casePar.Bank_Account_Number__c)){
       this.invalidAccountNumberError = true;
    }
    else if(/(000)/g.test(casePar.Bank_Account_Number__c)){ 
      passBankAccNumber='11111111';
      this.invalidAccountNumberError = true;
     // isValid = false;
    }
     return isValid;
    
  }

  handleInterBankValidation(){
    var isValid = true;
    let casePar = this.cp;
    var accountnummberspecialCharacter =  /[ `!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?~]/;;
    this.nameOnInterAccBlankError = false;
    this.nameOnInterAccNumericError = false;
    this.inteBankAccountError = false; 
    this.beneficiaryHomeRequird = false;
    this.ibanspecialcharactererror = false;
    this.lenghtOfIBan=false;
    this.interIBANISBlankError = false;

    if(casePar.International_Bank_Account_Holder_Name__c==undefined || casePar.International_Bank_Account_Holder_Name__c=="" || casePar.International_Bank_Account_Holder_Name__c==null){
      isValid=false;
      this.nameOnInterAccBlankError = true;
    }
    if(casePar.International_Bank_Account_Holder_Name__c && !isNaN(casePar.International_Bank_Account_Holder_Name__c)){
      isValid=false;
      this.nameOnInterAccNumericError = true;
    }

    if(casePar.International_Bank_Name__c==undefined || casePar.International_Bank_Name__c=="" || casePar.International_Bank_Name__c==null){
      isValid=false;
      this.inteBankAccountError = true;             
    }
    
    if(casePar.Beneficiary_Home_Address__c ==undefined || casePar.Beneficiary_Home_Address__c==""|| casePar.Beneficiary_Home_Address__c ==null){
      isValid=false;
      this.beneficiaryHomeRequird = true;
    }
    
    if(casePar.International_Account_Number__c==undefined || casePar.International_Account_Number__c=="" || casePar.International_Account_Number__c ==null){
      isValid= false;
      this.interIBANISBlankError = true;
    }

    if (accountnummberspecialCharacter.test(casePar.International_Account_Number__c))
    {
      // alert('check');
      isValid= false;
      this.ibanspecialcharactererror = true;
    }
  
    if(casePar.International_Account_Number__c){
      if(casePar.International_Account_Number__c.length < 15){
        isValid= false;
        this.lenghtOfIBan=true;
      }
    }
  return isValid;
}

handleGoBack() {
  
  window.location.href =  EWIVPlus_Link+this.accesscode;

  // let currentURL = window.location.href;
  // console.log('currentURL => ' + currentURL);
  // let homeURL = currentURL.split('/ewinsured/s');
  // console.log('homeURL => ' + homeURL);
  // let redirectToURL = homeURL[0]+'/ewinsured/s/?accessCode='+this.accesscode;
  // console.log('redirectToURL => ' + redirectToURL);
  // window.location.href = redirectToURL;
}

  handleDoInit(result){
    if(result.caseParticipants == null){     
      this.showDetails=false;
      return;
    }
    this.showDetails = true;
    this.getContactRecord = JSON.stringify(result);
    this.message=result;
    console.log("success result 126: ", result);
    //Country codes
    let options = [];
    for (var key in result.countryCodes) {
        options.push({ key: result.countryCodes[key], value: false});
    }
    this.countrycode = options;
  
    this.personRecord = result.con;
    this.cp = result.caseParticipants;

    
    let salList = result.salutationPicklist;
    for(let val in salList){
      this.salutationPicklist.push({key: salList[val], value: false});
    }

    this.Salutation ='--None--';
    if(result.con.Salutation){
      this.Salutation = result.con.Salutation;
    }

    if(this.Salutation != undefined && this.Salutation != '' && this.Salutation != null){
      for(let ind in this.salutationPicklist){
        if(this.Salutation == this.salutationPicklist[ind].key)
          this.salutationPicklist[ind].value = true;
      }
    }else{
      this.salutationPicklist[0].value = true;
    }
            
    this.phoneCodes = '+44';
    if(result.caseParticipants.Phone_Code__c){
      this.phoneCodes = result.caseParticipants.Phone_Code__c;
    }
    
    if(this.phoneCodes != undefined && this.phoneCodes != '' && this.phoneCodes != null){
      for(let ind in this.countrycode){
        if(this.phoneCodes == this.countrycode[ind].key){
          this.countrycode[ind].value = true;
          console.log("this.countrycode getContactDetail => " + this.countrycode[ind].key +' : '+ this.countrycode[ind].value);
        }
      }
    }else{
      this.countrycode[0].value = true;
    }
    this.MailingStreet = this.capitalizeWord(result.caseParticipants.Street__c);
    this.MailingCity = this.capitalizeWord(result.caseParticipants.City__c);
    this.MailingState = result.caseParticipants.State__c;
    this.MailingCountry = this.capitalizeWord(result.caseParticipants.Country__c);
    this.MailingPostalCode = this.capitalizeWord(result.caseParticipants.Postal_Code__c);
    if(!result.caseParticipants.State__c){                
      this.MailingAddress = this.capitalizeWord(result.caseParticipants.Street__c) +"\n"+ this.capitalizeWord(result.caseParticipants.City__c) +"\n"+ this.capitalizeWord(result.caseParticipants.Country__c) +"\n"+ this.getUppercaseWord(result.caseParticipants.Postal_Code__c);
      console.log('this.MailingAddress=>'+this.MailingAddress);
    }
    else{
      this.MailingAddress = this.capitalizeWord(result.caseParticipants.Street__c) +"\n"+ this.capitalizeWord(result.caseParticipants.City__c) +"\n"+ this.capitalizeWord(result.caseParticipants.State__c) +"\n"+ this.capitalizeWord(result.caseParticipants.Country__c) +"\n"+ this.getUppercaseWord(result.caseParticipants.Postal_Code__c);
    }
  }
  getUppercaseWord(element){
    if(element == '' || element == null || element==undefined){ return ''; }
    return element.toUpperCase();
  }

}