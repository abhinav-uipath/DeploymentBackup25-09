import { LightningElement, track, wire } from 'lwc';
import EWITheme from '@salesforce/resourceUrl/EWITheme';
import getCaseDetails from "@salesforce/apex/eI_EWI_DepositAllocationProposalCls.getCaseandDispiteItemsDetails";
import getCaseParticipantDetails from "@salesforce/apex/eI_EWI_DepositAllocationProposalCls.getCaseParticipantDetails"
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import updateCaseRaisedbyAGLL from "@salesforce/apex/eI_EWI_DepositAllocationProposalCls.updateCaseRaisedbyAGLL";
import getTenantsInformation from "@salesforce/apex/eI_EWI_DepositAllocationProposalCls.getTenantsInformation";
import EWIVPlus_Link from '@salesforce/label/c.EWIVPlus_Link';

export default class EI_EWI_AGLLDepositAllcationProposal extends NavigationMixin(LightningElement) {
    ew_arrow_dropleft = EWITheme + '/assets/img/ew-arrow-dropleft.png';
    pound_icon = EWITheme + '/assets/img/pound_icon.png';
    home_icon = EWITheme + '/assets/img/home_icon.png';
    circle_checked_icon = EWITheme + '/assets/img/circle_checked_icon.png';

    @track caseDetails;
    @track caseParticipantDetails;
    @track accessCode;
    @track formattedEndDate;
    @track depositAmount;
    @track isDepoAllocProposal = false;
    @track isShowThankyouPage = false;
    @track depositAmountReceived = 0.00;
    @track depositAmountClaimed = 0.00;
    @track otherName = '';
    @track claimedItems = [];
    @track summaryDisputeItems = [];
    @track isAmountReceivedYES = false;
    @track isAmountReceivedNO = false;
    @track showIfRecieved0 = false;
    @track showIfRecievedFullAmount = false;
    @track isProposalSummarySubmit = false;
    @track isDepositSummaryReview = false;
    // @track showIfAgreedMoreAmount = false;
    @track showIfClaimedMoreAmount = false;
    @track isDisbaleYESSubmitbtn = false;
    @track isOtherNameRequired = false;
    @track isOtherNameLimitExceed = false;

    @track blankAllocationList = [];
    @track showAddressFlag = false;
    @track showDetails = true;
    @track isSkipSelfResolution = false;
    @track isSelfResSkipCheckbox = false;
    @track isSelfResSkipInput;
    @track showIfTextSizeIsMore = false;
    // get showIfClaimedMoreAmount(){
    //     if(this.caseDetails.Deposit_Account_Number__r.Deposit_Amount__c != (this.depositAmountReceived+this.depositAmountClaimed))
    //         return true;
    //     return false;
    // }

    get isOtherClaimEntered(){
        if(this.claimedItems[5].value > 0 )
            return true;
        return false;
    }

    // get otherNameRequired(){
    //     if(this.otherName == '') 
    //         return true;
    //     return false;
    // }

    restrictDecimal(event) {  
        var t = event.target.value;
        return (t.indexOf(".") >= 0) ? (t.substr(0, t.indexOf(".")) + t.substr(t.indexOf("."), 3)) : t

        // if(t.includes(".")){
        //     var arr = t.split(".");
        //     var lastVal = arr.pop();
        //     var arr2 = lastVal.split('');
        //     if (arr2.length > '1') {
        //         event.preventDefault();
        //     }
        // }
    }

    removeZero(event) {
        var edValue = event.target.value;
        function trimNumber(s) {
            while (s.substring(0,1) == '0' && s.length>=1 && !s.includes(".")) { 
                s = s.substring(1,9999); 
            }
            return s;
        }
        var trimeVal = trimNumber(edValue);
        event.target.value = trimeVal;
        
        if(trimeVal.includes('.')){
            var number = trimeVal.split('.');
            console.log('numbs '+number[1]);
            if(number[1].length>2)
            event.target.value = parseFloat(trimeVal).toFixed(2);
        }else{
            event.target.value = trimeVal;
        }
    }

    restrictNegativeVal(event){
        if(event.target.value < 0){
            event.target.value = 0;
        }
    }
    
    connectedCallback(){
    // @wire(CurrentPageReference)
    // getpageRef(pageRef) {
        // console.log('data => ', JSON.stringify(pageRef));
        // console.log("pageReference state => " + JSON.stringify(pageRef.state));
        // console.log("pageReference state Id => " + pageRef.state.id);
        // let recId = pageRef.state.id;
        // let location = window.location.href;
        // console.log('location => ' + location);
        setTimeout(() => { window.history.forward();  }, 0);

        const queryString = window.location.search;
        console.log('queryString => ' + queryString);
        const urlParams = new URLSearchParams(queryString);
        console.log('urlParams => ' + urlParams);
        const caseId = urlParams.get('caseId');
        console.log('caseId => ' + caseId);
        const accessCode = urlParams.get('accessCode');
        this.accessCode = accessCode;
        if(accessCode == '' || accessCode == null){
            this.showDetails = false;
            return;
          }
        console.log('accessCode => ' + accessCode);

        // getCaseDetails({recordId : caseId}).then(result =>{
        //     console.log("success resultghgjhgjhg : ", result);
        //     this.caseDetails = result;
        //     this.isDepoAllocProposal = true;
        //     var endDate = new Date( this.caseDetails.Deposit_Account_Number__r.End_Date__c);
        //     if(isNaN(endDate)){
        //         this.dateValue='';
        //     } 
        //     else if(endDate!= null || endDate!= undefined|| endDate!= ''){
        //         var checkdate = endDate.getDate().toString().padStart(2, "0");;
        //         var checkmonth = (endDate.getMonth()+1).toString().padStart(2, "0");
        //         var checkyear = endDate.getFullYear();
        //         var newDate = checkdate +'/'+ checkmonth+'/'+checkyear;
        //         console.log('this.newDate => '+ endDate );
        //         this.formattedEndDate = newDate;
        //         console.log('formattedEndDate => '+this.formattedEndDate);     
        //     }  
        // }).catch(error => {
        //     console.log("error : ", error)
        // });

            getCaseParticipantDetails({accessCode : this.accessCode}).then(result1 => {
                if(result1 == null){     
                    return;
                  }
                this.showDetails = true;
                console.log("getCaseParticipantDetails success result 1: ", result1);
                this.caseParticipantDetails = result1;
                this.caseDetails = result1.Case__r;
                this.depositAmount = (result1.Case__r.Deposit_Account_Number__r.Deposit_Amount__c).toFixed(2);
                this.isDepoAllocProposal = true;
                
                var endDate = new Date( this.caseDetails.Deposit_Account_Number__r.End_Date__c);
                if(isNaN(endDate)){
                    this.dateValue='';
                } 
                else if(endDate!= null || endDate!= undefined|| endDate!= ''){
                    var checkdate = endDate.getDate().toString().padStart(2, "0");;
                    var checkmonth = (endDate.getMonth()+1).toString().padStart(2, "0");
                    var checkyear = endDate.getFullYear();
                    var newDate = checkdate +'/'+ checkmonth+'/'+checkyear;
                    this.formattedEndDate = newDate;
                    console.log('endDate => '+ endDate );
                    console.log('formattedEndDate => '+this.formattedEndDate);     
                    console.log('depositAmount => '+this.depositAmount); 
                } 
                this.claimedItems.push({value:0, key:'Cleaning'});
                this.claimedItems.push({value:0, key:'Damage'});
                this.claimedItems.push({value:0, key:'Redecoration'});
                this.claimedItems.push({value:0, key:'Gardening'});
                this.claimedItems.push({value:0, key:'Rent arrears'});
                this.claimedItems.push({value:0, key:'Other'});
                
                console.log('this.claimedItems => ' + JSON.stringify(this.claimedItems));

                console.log("deposit Id => " + this.caseParticipantDetails.Case__r.Deposit_Account_Number__c);
                getTenantsInformation({caseId : this.caseParticipantDetails.Case__c}).then(result => {
                    console.log("getTenantsInformation result : ", result);
                    if(result.length > 0){
                        this.blankAllocationList = result;
                        this.tenantName = result[0].Account__r.Name;
                        this.showAddressFlag = true;
                    }
                }).catch(error => {
                    console.log("getTenantsInformation error : ", error);
                });

            }).catch(error => {
                console.log("getCaseParticipantDetails error 1: ", error);
            });
    }

    handleGoBack(event) {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'home'
            },
            state:{
                accessCode: this.accessCode
            }
        });
    }

    handleSkipSelfResolution(event){
        // alert(event.target.value);
        let chedckedVal = !this.isSelfResSkipCheckbox;
        console.log('chedckedVal => ' + chedckedVal);

        this.isSkipSelfResolution = chedckedVal;
        console.log('this.isSkipSelfResolution => ' + this.isSkipSelfResolution);

        this.isSelfResSkipCheckbox = chedckedVal;
        console.log('this.isSelfResSkipCheckbox => ' + this.isSelfResSkipCheckbox);
    }

    handleSelfResSkipInput(event){
        this.isSelfResSkipInput = (event.target.value);
    }

    handleDepositAmountReceivedChange(event){
        let val = this.restrictDecimal(event);
        event.target.value = val;
        this.depositAmountReceived = (event.target.value);
    }

    handleAmountReceivedYES(){
        this.isAmountReceivedYES = true;
        this.isAmountReceivedNO = false;
        this.template.querySelector('.amt-recv-yes-btn').classList.add('bg-color-blue'); 
        this.template.querySelector('.amt-recv-no-btn').classList.remove('bg-color-blue');
    }

    handleAmountReceivedNO(){
        this.depositAmountReceived = 0.00;
        this.depositAmountClaimed = 0.00;
        this.isAmountReceivedNO = true;
        this.isAmountReceivedYES = false;
        for(let ind in this.claimedItems ){
            this.claimedItems[ind].value = 0.00;
        }
        this.otherName = '';
        this.template.querySelector('.amt-recv-no-btn').classList.add('bg-color-blue'); 
        this.template.querySelector('.amt-recv-yes-btn').classList.remove('bg-color-blue');
    }

    handleCalculateClaimAmount(event){
        let val = this.restrictDecimal(event);
        event.target.value = val;

        let index = event.target.title;
        let claimItemValue = event.target.value;
        this.claimedItems[index].value = claimItemValue;
        
        // console.log(" on change claimedItems=> " + JSON.stringify(this.claimedItems));
        this.depositAmountClaimed = 0;
        
        for(let ind in this.claimedItems ){
            console.log(" on change claimedItem => " + this.claimedItems[ind].value);
            if(this.claimedItems[ind].value > 0){
                this.depositAmountClaimed = (parseFloat(this.depositAmountClaimed) + parseFloat(this.claimedItems[ind].value)).toFixed(2);
            }
        }
        console.log("this.depositAmountClaimed => " + this.depositAmountClaimed);
        this.isOtherNameRequired = false;
    }

    handleOtherName(event){
        var othertext = event.target.value;
        if(othertext.length > 300){
            event.target.value = othertext.substring(0, 300);
            this.isOtherNameLimitExceed = true;
        }else{
            this.otherName = othertext;
            this.isOtherNameLimitExceed = false;
        }
    }

    handleClaimContinue(event){
        event.preventDefault();
        if(this.depositAmountReceived > 0){
            this.depositAmountReceived = (parseFloat(this.depositAmountReceived)).toFixed(2);
        }else{
            this.depositAmountReceived = (parseFloat(0)).toFixed(2);
        }
        if(this.depositAmountClaimed > 0){
            this.depositAmountClaimed = (parseFloat(this.depositAmountClaimed)).toFixed(2);
        }else{
            this.depositAmountClaimed = (parseFloat(0)).toFixed(2);
        }
       
        // for(let ind in this.claimedItems ){
        //     this.claimedItems[ind].value = (parseFloat(this.claimedItems[ind].value)).toFixed(2);
        // }
        
        this.summaryDisputeItems=[];
        console.log("handleClaimContinue => " + this.claimedItems);
        for(let ind in this.claimedItems ){
            console.log('claimedItems['+ind+'].value => ' + this.claimedItems[ind].value);
            if( this.claimedItems[ind].value > 0){
                this.summaryDisputeItems.push({value:(parseFloat(this.claimedItems[ind].value)).toFixed(2), key:this.claimedItems[ind].key});
            }
        }

        let isValid = true;

        if((( parseFloat(this.depositAmountClaimed) + parseFloat(this.depositAmountReceived) ).toFixed(2)) != (parseFloat(this.caseDetails.Deposit_Account_Number__r.Deposit_Amount__c).toFixed(2))){
            this.showIfClaimedMoreAmount = true;
            isValid = false;
        }else{
            this.showIfClaimedMoreAmount = false;
        }
       
        console.log("Line 322--->"+this.isSelfResSkipInput);
       
        if(this.isSkipSelfResolution == true && (this.isSelfResSkipInput == undefined||this.isSelfResSkipInput == null  || this.isSelfResSkipInput == '' ||this.isSelfResSkipInput.length < 150 ||this.isSelfResSkipInput.length > 1000)){
            this.showIfTextSizeIsMore = true;
            isValid = false;
            this.template.querySelector(".errorMsgDiv").scrollIntoView();
            
        }else{
            this.showIfTextSizeIsMore = false;
        }
    
       
        
        if(this.isOtherClaimEntered && this.otherName == ''){
            this.isOtherNameRequired = true;
            isValid = false;
        }else{
            this.isOtherNameRequired = false;
        }
       
        // if(this.isOtherNameLimitExceed){
        //     isValid = false;
        // }

        if(isValid){
            this.showIfClaimedMoreAmount = false;
            this.isOtherNameRequired = false;
            this.isOtherNameLimitExceed = false;
            this.isDepoAllocProposal = false;
            this.isDepositSummaryReview = true;
            this.showIfTextSizeIsMore = false;
        }
        
    }
    
    handleSummaryReviewGoBack(event){
        this.isDepoAllocProposal = true;
        this.isDepositSummaryReview = false;

        setTimeout(() => {
            //alert("this.template.querySelector('.amt-recv-yes-btn') => " + this.template.querySelector('.amt-recv-yes-btn'))
            this.template.querySelector('.amt-recv-yes-btn').classList.add('bg-color-blue'); 
            this.template.querySelector('.amt-recv-no-btn').classList.remove('bg-color-blue');
        }, 100);     
    }

    handleSubmitProposal(event){
        event.preventDefault();
        this.isDisbaleYESSubmitbtn = true;
        this.template.querySelector('.submit-btn').classList.remove('bg-color-blue');
        this.template.querySelector('.submit-btn').classList.add('disable_ew_btn');
        console.log("this.claimedItems => " + JSON.stringify(this.claimedItems));
        var objectofMap = {};
        for(let ind in this.claimedItems){
            if(this.claimedItems[ind].value > 0){
                objectofMap[this.claimedItems[ind].key] = this.claimedItems[ind].value;
            }
            console.log("key => " + this.claimedItems[ind].key);
            console.log("value => " + this.claimedItems[ind].value);
            console.log("objectofMap => " + JSON.stringify(objectofMap));
        }
        var objectofMapstr = JSON.stringify(objectofMap);

        updateCaseRaisedbyAGLL({caseId: this.caseDetails.Id, amountToTenant: this.depositAmountReceived, initiatedBy: this.caseParticipantDetails.Type__c, 
            caseParId: this.caseParticipantDetails.Id,
            claimedItems: objectofMapstr, otherReason: this.otherName, ewiSkipSelfResCheckbox: this.isSelfResSkipCheckbox,ewiSkipSelfResInput: this.isSelfResSkipInput }).then(result => {
            console.log("updateCaseRaisedbyAGLL result => " + result);
            if(result == 'Agll Responded'){
                //window.location.reload();
                this.handleDepositSummaryReview();
            }else if(result == 'Successfully updated'){
                this.isShowThankyouPage = true;
                this[NavigationMixin.Navigate]({
                    type: 'comm__namedPage',
                    attributes: {
                        pageName: 'ewithankyou'
                    },
                    state:{
                        accessCode: this.accessCode,
                        thanksfor: 'raisedbyagll'
                    }
                });
                this.isDepoAllocProposal = false;
                this.isDepositSummaryReview = false;
            }
        }).catch(error => {
            console.log("updateCaseRaisedbyAGLL error => ", error);
        });
    }

    handleDepositSummaryReview(){
        window.location.href =  EWIVPlus_Link+this.accessCode;
        
        // let currentURL = window.location.href;
        // console.log('currentURL => ' + currentURL);
        // let homeURL = currentURL.split('/ewinsured/s');
        // console.log('homeURL => ' + homeURL);
        // let redirectToURL = homeURL[0]+'/ewinsured/s/?accessCode='+this.accessCode;
        // console.log('redirectToURL => ' + redirectToURL);
        // window.location.href = redirectToURL; //"https://espdev2-thedisputeservice.cs80.force.com/ewinsured/s/?accessCode="+this.accessCode;
                                //https://devuat-thedisputeservice.cs87.force.com/ewinsured/s/?accessCode=agent123 
      
        // this[NavigationMixin.Navigate]({
        //     type: 'comm__namedPage',
        //     attributes: {
        //         pageName: 'home'
        //     },
        //     state:{
        //         accessCode: this.accessCode
        //     }
        // });
    }

    handleHideForwardingAddress(event){
        this.showAddressFlag = false
    }
}