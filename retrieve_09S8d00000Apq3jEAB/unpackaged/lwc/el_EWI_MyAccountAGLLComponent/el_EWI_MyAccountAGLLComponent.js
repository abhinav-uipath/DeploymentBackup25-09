import { LightningElement ,track,wire,api} from 'lwc';
import EWITheme from '@salesforce/resourceUrl/EWITheme';
import {getPicklistValues, getObjectInfo} from 'lightning/uiObjectInfoApi';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import SALUTATION_FIELD from '@salesforce/schema/Contact.Salutation';
import getPersonDetails from '@salesforce/apex/el_EWI_MyAccountClass.getPersonDetails';
import updateDetails from '@salesforce/apex/el_EWI_MyAccountClass.updateDetails';
import updateBankDetails from '@salesforce/apex/el_EWI_MyAccountClass.updateBankDetails';
import EWIVPlus_Link from '@salesforce/label/c.EWIVPlus_Link';

export default class El_EWI_MyAccountTenantComponent extends LightningElement {

ew_arrow_dropleft = EWITheme + '/assets/img/ew-arrow-dropleft.png';

@track accesscode;
@track getContactRecord;
@track detail;
@track personRecord;
@track cp;
@track phoneCodes;
@track countrycode = [];
@track Salutation;
@track Phone;
@track Email;
@track CompanyName;
@track AlternateEmail;
@track MailingStreet;
@track MailingCity;
@track MailingState;
@track MailingCountry;
@track MailingPostalCode;
@track MailingAddress;
@track Sortcodelengtherror=false;
@track invalidSortCodeError = false;
@track sortCodeBlankError = false;
@track bankOfAmericaSortCode = false;
@track nameOnAccountBlankError = false;
@track nameOnAccountNumericError = false;
@track bankaccountnamelengtherror = false;
@track nameOnAccountSpecialCharError = false;
@track accountNumberBlankError = false;
@track invalidAccountNumberError = false;
@track bankSuccessMessage =false;
@track bankErrorMessage = false;
@track firstNameError =false;
@track contactSuccessMessage=false;
@track SurNameError =false;
@track validAddressWithPostcodeError=false;
@track titleError =false;
@track successMsg =false;
@track errorMsg =false;
@track PhonelengthError =false;
@track mobileError =false;
@track EmailError = false;
@track emailRegexError=false;
@track accountNumberLengthError=false;
@track NonmemberLL =false;
@track showPopup=false;
@track primaryAddress = {AddressLine:'', Street:'', Town:'', County:'', Postcode:'', Country:'', localAuthorityArea:''};
@track showDetails = true;

branchIds;
salutationPicklist = [];
showButtons = false;
flag = true;
doInitLoad = false;

hideBootstrapErrors(event) {
  var button_Name = event.target.name;
  console.log('hideBootstrapErrors button_Name => '+button_Name);
  switch (button_Name) {
      case "successMsg":
      this.successMsg = false;
      break;
      case "accountNumberLengthError":
      this.accountNumberLengthError = false;
      break;
      case "emailRegexError":
      this.emailRegexError=false;
      break;
      case "ErrorMessage":
      this.errorMsg = false;
      break;
      case "title":
      this.titleError =false;
      break;
      case "firstNameError":
      this.firstNameError =false;
      break;
      case "validAddressWithPostcodeError":
      this.validAddressWithPostcodeError=false;
      break;    
      case "Sortcodelengtherror":
      this.Sortcodelengtherror = false;
      break;
      case "contactSuccessMessage":
      this.contactSuccessMessage=false;
      break; 
      case "SurNameError":
      this.SurNameError =false;
      break;
      case "EmailError":
      this.EmailError=false;
      break;
      case "mobileNumber":
      this.mobileError =false;
      break;
      case "Phonelength":
      this.PhonelengthError =false;
      break;
      case "phoneNotValid":
      this.MessagePhone= false;
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
      case "bankaccountnamelengtherror":
      this.bankaccountnamelengtherror = false;
      break;
      case "nameOnAccountSpecialCharError":
      this.nameOnAccountSpecialCharError = false;
      break;
      case "accountNumberBlankError":
      this.accountNumberBlankError = false;
      break;
      case "invalidAccountNumberError":
      this.invalidAccountNumberError = false;
      break;
      case "bankSuccessMessage":
      this.bankSuccessMessage = false;
      break;
      case "bankErrorMessage":
      this.bankErrorMessage = false;
      break;
      
  }
}

// For handling event from child component(address finder) component for onselectingaddress event i.e. selecting automatically
selectingAddressHandler(event) {
  //alert('in address');
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
      this.cp.City__c = this.primaryAddress.Town;
    } else if(returnedData.fieldName.includes("County")) {
      this.primaryAddress = {...this.primaryAddress, "County":returnedData.value}
      this.MailingState =  this.primaryAddress.County;
      this.cp.State__c = this.primaryAddress.County;
    } else if(returnedData.fieldName.includes("Postcode")) {
      this.primaryAddress = {...this.primaryAddress, "PostCode":returnedData.value}
      this.MailingPostalCode = this.primaryAddress.Postcode;
      this.cp.Postal_Code__c = this.primaryAddress.Postcode;
    } else if(returnedData.fieldName.includes("Country")) {
      this.primaryAddress = {...this.primaryAddress, "Country":returnedData.value}
      this.MailingCountry= this.primaryAddress.Country;
      this.cp.Country__c = this.primaryAddress.Country;
    } else if(returnedData.fieldName.includes("Street")) {
      this.primaryAddress = {...this.primaryAddress, "Street":returnedData.value}
      this.MailingStreet = String(this.primaryAddress.Street);
      this.cp.Street__c = this.primaryAddress.Street;
    }
  }
}

titleInpChange(event){
  event.preventDefault();
  this.cp.Salutation__c  = event.target.value;
  console.log("changes title =-> " + this.cp.Salutation__c );
 /* let cont = JSON.parse(this.getContactRecord);
  cont.Salutation = event.target.value;
  this.getContactRecord = JSON.stringify(cont);*/
  for(let ind in this.salutationPicklist){
    if(this.Salutation == this.salutationPicklist[ind].key)
      this.salutationPicklist[ind].value = true;

    console.log("this.salutationPicklist onChange => " + this.salutationPicklist[ind].key +' : '+ this.salutationPicklist[ind].value);
  }
}

fnameInpChange(event){
  event.preventDefault();
  this.cp.First_Name__c =event.target.value;
  console.log('this.cp.First_Name__c =>'+this.cp.First_Name__c );
}

lnameInpChange(event){
  event.preventDefault();
  this.cp.Last_Name__c = event.target.value;
  console.log(' this.cp.Last_Name__c =>'+ this.cp.Last_Name__c);
}

phoneCodeInpChange(event){
  event.preventDefault();
  this.cp.Phone_Code__c = event.target.value;
  console.log("phone code =-> " + this.cp.Phone_Code__c);
  for(let ind in this.countrycode){
    if(this.cp.Phone_Code__c == this.countrycode[ind].key)
      this.countrycode[ind].value = true;

    console.log("this.countrycode onChange => " + this.countrycode[ind].key +' : '+ this.countrycode[ind].value);
  }
}

phoneInpChange(event){
  event.preventDefault();
  this.cp.Phone__c= event.target.value;
  console.log('this  phone::'+this.cp.Phone__c);
}

alternateemailInpChange(event){
  event.preventDefault();
  this.cp.Other_Emails__c= event.target.value;
  console.log('this.other email::'+this.cp.Other_Emails__c);
}

handlebankAccountNumberChange(event){
  this.cp.Bank_Account_Number__c =event.target.value;
}
handlesortcodeChange(event){
  this.cp.Bank_Sort_Code__c =event.target.value;
}
handlebankAccountNamechange(event){
  this.cp.Bank_Account_Holder_Name__c=event.target.value;
 // this.bankRecord.Name = event.target.value;
}

closeModal(event){
  this.showPopup=false;
 // this.bankRecord.Name = event.target.value;
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
          console.log('this.result'+ result);
          this.handleDoInit(result);
        }).catch(error => {
            console.log(" getContactDetail error : ", error)
        });
      }

       /*if(data){
            console.log("salutationPicklist data => " + data.values);
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

handleContactUpdate(){
  console.log('handleContactUpdate');
  var isValid = false;
  if(this.handleValidations()){

  this.contactSuccessMessage = false;
  isValid = true;
  let result = {};
  //result.con = this.personRecord;
  result.caseParticipants = this.cp;
  updateDetails({ strResult : JSON.stringify(result)})

  .then(result=>{

    this.contactSuccessMessage = true;
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


  handleEdit(){
    this.showButtons = true;
    this.flag = false;
  }

  handleBankUpdate(){
  
    if(this.detail.isSecondaryAgent && !this.detail.isBankDetailsEmpty && !this.showPopup){
        this.showPopup = true;
        return;
    }
    var isValid = false;
    this.invalidSortCodeError = false; 
    this.invalidAccountNumberError = false;
    this.bankSuccessMessage = false;
    this.showPopup=false;

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
      console.log('casePar.Sort_Code__c ' +  casePar.Bank_Sort_Code__c);
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
        console.log('line--> 608 ' + accountnummberalphaCharacter.test(casePar.Bank_Sort_Code__c));
      if(!Numberonlycheck.test(casePar.Bank_Sort_Code__c)){
        console.log('line--> 624 ' + Numberonlycheck.test(casePar.Bank_Sort_Code__c));
        isValid = false;
        this.invalidSortCodeError = true;
        this.sortCodeBlankError = false;
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
     //if(pattermatch.test(this.bankAccountNumber)){
      var passBankAccNumber =  casePar.Bank_Account_Number__c;
    if(pattermatch.test(casePar.Bank_Account_Number__c)){
      console.log('test');
      this.invalidAccountNumberError = true;
    }
    else if(/(000)/g.test(casePar.Bank_Account_Number__c)){ 
      passBankAccNumber='11111111';
      console.log('test000');
      this.invalidAccountNumberError = true;
     // isValid = false;
    }
   
    return isValid;
    
  }

  handleGoBack (){
    window.location.href =  EWIVPlus_Link+this.accesscode;

    // let currentURL = window.location.href;
    //     console.log('currentURL => ' + currentURL);
    //     let homeURL = currentURL.split('/ewinsured/s');
    //     console.log('homeURL => ' + homeURL);
    //     let redirectToURL = homeURL[0]+'/ewinsured/s/?accessCode='+this.accesscode;
    //     console.log('redirectToURL => ' + redirectToURL);
    //     window.location.href = redirectToURL;
  }



  handleValidations(){
    console.log('handleValidations');
    var isValid = true;
    // let con = this.personRecord;
    // console.log('handleValidations con => ' + JSON.stringify(con));
    let casePar = this.cp;
    console.log('handleValidations casePar => ' + JSON.stringify(casePar));
    const emailRegex=/^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;

    this.firstNameError =false;
    this.SurNameError =false;
    this.emailRegexError=false;
    this.validAddressWithPostcodeError=false;
    this.EmailError =false;

    if(casePar.First_Name__c  =="" || casePar.First_Name__c  ==undefined || casePar.First_Name__c  ==null){
        this.firstNameError =true;
        isValid =false;
    }
    if(casePar.Last_Name__c  =="" || casePar.Last_Name__c  ==undefined || casePar.Last_Name__c  ==null){
      this.SurNameError =true;
      isValid =false;
    }

    console.log('casePar.Other_Emails__c => ' + casePar.Other_Emails__c);

   /* if (casePar.Other_Emails__c==null || casePar.Other_Emails__c=='' || casePar.Other_Emails__c ==undefined) {
      console.log('this.email::'+casePar.Other_Emails__c);
      this.EmailError =true;
      isValid =false;
    }*/
    if (casePar.Other_Emails__c!=null && casePar.Other_Emails__c!='' && casePar.Other_Emails__c !=undefined){
    if(!casePar.Other_Emails__c.match(emailRegex)){
      console.log('this.emailmatch::'+casePar.Other_Emails__c);
      this.emailRegexError=true;
      isValid = false;
    }
  }

    console.log('casePar.phone::'+casePar.Phone__c);
    console.log('casePar.Phone_Code__c '+casePar.Phone_Code__c );
    // if (casePar.Phone__c==null || casePar.Phone__c=='' || casePar.Phone__c ==undefined) {
    //   console.log('casePar.phone::'+casePar.Phone__c);
    //   this.mobileError =true;
    //   this.PhonelengthError = false;   
    //   isValid =false;
    //   }
    //   else { 
    if (casePar.Phone__c!=null && casePar.Phone__c!='' && casePar.Phone__c !=undefined) {
      if(casePar.Phone_Code__c == '+44' && (casePar.Phone__c.length != 11 || !casePar.Phone__c.startsWith("07") ) ){
        console.log("phone code is +44");
        this.mobileError= false;  
        this.PhonelengthError = true;
        isValid = false;
      }else{
        this.mobileError= false;
        this.PhonelengthError = false;
      }
    }

    // if((this.MailingStreet == undefined || this.MailingStreet == "" || this.MailingStreet == null) ||
    //         (this.MailingCity == undefined || this.MailingCity == "" || this.MailingCity == null) ||
    //         // (this.MailingState == undefined || this.MailingState == "" || this.MailingState == null) &&
    //         (this.MailingCountry == undefined || this.MailingCountry == "" || this.MailingCountry == null) ||
    //         (this.MailingPostalCode == undefined || this.MailingPostalCode == "" || this.MailingPostalCode == null)){
    //       this.validAddressWithPostcodeError=true;
    //       isValid = false;
    //     }
       

    return isValid;
  }
  handleDoInit(result){
    if(result.caseParticipants == null){     
      this.showDetails=false;
      return;
    }
    this.showDetails = true;
    this.getContactRecord = JSON.stringify(result);
    this.detail =result;
    console.log("success result 126: ", result);
    //Country codes
    let options = [];
    for (var key in result.countryCodes) {
        options.push({ key: result.countryCodes[key], value: false});
    }
    this.countrycode = options;

    let salList = result.salutationPicklist;
    for(let val in salList){
      this.salutationPicklist.push({key: salList[val], value: false});
    }

    let contResult =  result ;
    this.personRecord = result.con;
    this.cp = result.caseParticipants;
    this.NonmemberLL=false;
   
    if(result.account.RecordType.Name=='EWI_NonMemberLandlord'){
      this.NonmemberLL=true;
    }
    else{
      this.NonmemberLL=false;  
     }

    this.Salutation ='--None--';  
    if(result.caseParticipants.Salutation__c){
      this.Salutation = result.caseParticipants.Salutation__c;
    }
    if(this.Salutation != undefined && this.Salutation != '' && this.Salutation != null){
      for(let ind in this.salutationPicklist){
        if(this.Salutation == this.salutationPicklist[ind].key)
          this.salutationPicklist[ind].value = true;

        console.log("this.salutationPicklist getContactDetail => " + this.salutationPicklist[ind].key +' : '+ this.salutationPicklist[ind].value);
      }
    }else{
      this.salutationPicklist[0].value = true;
    }

      this.Phone = contResult.caseParticipants.Phone__c;
      
      this.phoneCodes = '+44';
      if(contResult.caseParticipants.Phone_Code__c){
        this.phoneCodes = contResult.caseParticipants.Phone_Code__c;
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

      this.AlternateEmail = contResult.caseParticipants.Other_Emails__c;
      this.MailingStreet = this.capitalizeWord(contResult.caseParticipants.Street__c);
      this.MailingCity = this.capitalizeWord(contResult.caseParticipants.City__c);
      this.MailingState = contResult.caseParticipants.State__c;
      this.MailingCountry = this.capitalizeWord(contResult.caseParticipants.Country__c);
      this.MailingPostalCode = this.getUppercaseWord(contResult.caseParticipants.Postal_Code__c);
      var propadd;
      if(!contResult.caseParticipants.State__c){
        //propadd = this.capitalizeWord(contResult.caseParticipants.Street__c)+ " , " + this.capitalizeWord(contResult.caseParticipants.City__c) +  " , " + this.capitalizeWord(contResult.caseParticipants.Country__c) + " , " + this.getUppercaseWord(contResult.caseParticipants.Postal_Code__c);
        propadd= this.MailingStreet.trim() + ", " + this.MailingCity.trim() + ", " + this.MailingCountry.trim() + ", " + this.MailingPostalCode.trim();
        console.log('propadd=> '+propadd);
        for(let char of propadd){
          console.log(char);
        }
        propadd = propadd.replace(", , , ,", ", ");
        propadd = propadd.replace(", , ,", ", ");
        propadd = propadd.replace(", ,", ", ");
        propadd = propadd.trim();
        if(propadd[0]==','){
        propadd = propadd.replace(",","");
        }
        this.MailingAddress=propadd;
      }
      else{
        propadd = this.capitalizeWord(contResult.caseParticipants.Street__c) + ", " + this.capitalizeWord(contResult.caseParticipants.City__c) + ", " + this.capitalizeWord(contResult.caseParticipants.State__c) + ", " + this.capitalizeWord(contResult.caseParticipants.Country__c) + ", " + this.getUppercaseWord(contResult.caseParticipants.Postal_Code__c);
        console.log('propadd=> '+propadd);
        for(let char of propadd){
          console.log(char);
        }
        propadd = propadd.replace(", , , , ,", ", ");
        propadd = propadd.replace(", , , ,", ", ");
        propadd = propadd.replace(", , ,", ", ");
        propadd = propadd.replace(", ,", ", ");
        propadd = propadd.trim();
        if(propadd[0]==','){
        propadd = propadd.replace(",","");
        }
        this.MailingAddress=propadd;
        //this.MailingAddress = this.capitalizeWord(contResult.caseParticipants.Street__c) + " , " + this.capitalizeWord(contResult.caseParticipants.City__c) + " , " + this.capitalizeWord(contResult.caseParticipants.State__c) + " , " + this.capitalizeWord(contResult.caseParticipants.Country__c) + " , " + this.getUppercaseWord(contResult.caseParticipants.Postal_Code__c); 
      }
      this.CompanyName = contResult.account.Company_Name__c;
      this.Type= contResult.account.Type__c; 
  }
  getUppercaseWord(element){
    if(element == '' || element == null || element==undefined){ return ''; }
    return element.toUpperCase();
  }

}