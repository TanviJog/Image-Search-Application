Global class imageSearchEngine{
    @auraEnabled
    public static List<Photograph__c> getAllPhotographs(){
        return [Select id,Name,Ext_Source_ID__c,Photo_URL__c,Image_Title__c from Photograph__c limit 50000];        
    }
    
    @auraEnabled
    public static List<Photograph__c> getSearchedPhotographs(string searchCriteria){ 
        return searchImage(searchCriteria);       
    }
    
    @auraEnabled
    public static string sendResultsEmail(string txtEmailAddress,List<Photograph__c> lstSearchResult){
        string strEmailOperationStatus = '';
        string strEmailBody = '';
        List<string> lstEmailAddress = new List<string>();
        lstEmailAddress.add(txtEmailAddress);
        system.debug('imageSearchEngine: lstEmailAddress: ' + lstEmailAddress);
        system.debug('imageSearchEngine: txtEmailAddress: ' + txtEmailAddress);
        if(lstSearchResult.size()>0){
            try{
            strEmailBody = 'Image search results are as below:'+ '<br/><br/>';
            for(Photograph__c img : lstSearchResult){
                String pic ='<img style="width: 5%;" alt="Photo" title="Photo" src="'+img.Photo_URL__c+'" />';
                strEmailBody += '<br/>' + img.Image_Title__c + ': ' + '<br/>' + pic + '<br/>';
            }
            strEmailBody += '<br/><br/>' + 'Thanks & Regards,' + '<br/>' + 'Team Photo Gallery';
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setToAddresses(lstEmailAddress);
            message.setSaveAsActivity(false);
            message.setSubject('Image Search Results');
            message.setHtmlBody(strEmailBody);
            message.setSenderDisplayName('Photo Gallery');
            Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
    
            if (results[0].success) {
                System.debug('Result: ' + results[0]);
                strEmailOperationStatus = 'Email sent successfully!';
            } else {
                System.debug('Error message: ' + results[0].errors[0].message);
                strEmailOperationStatus = 'Oops there is an issue sending email. Please use valid email address.';
            }
            }catch(Exception ex){
                strEmailOperationStatus = 'Error:' + ex.getMessage();
            }
        }else{
            strEmailOperationStatus = 'No image search results available to email';
        }
        
        return strEmailOperationStatus;        
    }
    
    public static List<Photograph__c> searchImage(string searchFilter){
        string soslQuery = '';
        List<Photograph__c> lstPhotographs = new List<Photograph__c>();
        
        if(searchFilter!='' || searchFilter!=null){
            searchFilter = '{"' + searchFilter + '}';
            soslQuery = 'Find ' + searchFilter + ' in all fields returning Photograph__c (id, Name, Image_Title__c, Image__c, Photo_URL__c)';
        }        
        system.debug('imageSearchEngine: soslQuery: ' + soslQuery );
        
        if(soslQuery!=''){
            List<List<sObject>> searchResult = search.query(soslQuery);
            if(searchResult.size()>0){
                if(searchResult[0].size()>0){
                    lstPhotographs = searchResult[0];
                }
            }
        }
        system.debug('imageSearchEngine: lstPhotographs: ' + lstPhotographs);
        return lstPhotographs;
    }
}