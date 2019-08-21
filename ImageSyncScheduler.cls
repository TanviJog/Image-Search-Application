Global class ImageSyncScheduler implements Schedulable{
    Global void execute(SchedulableContext sc) {
        syncImages();
    }
    
    @future(callout=true)
    public static void syncImages(){
        Map<string,Photograph__c> mapRetrivedData = new Map<string,Photograph__c>();
        Map<string,Photograph__c> mapExistingData = new Map<string,Photograph__c>();
        List<Photograph__c> lstPhotoToDelete = new List<Photograph__c>();
        List<Photograph__c> lstPhotoToCreate = new List<Photograph__c>();
        
        for(IS_ImageResponseDTO.IMAGE_RESPONSE retrivedImage : IS_ImageSourceCallOut.getPhotos()){
            mapRetrivedData.put(retrivedImage.intExtSourceID,new Photograph__c(Ext_Source_ID__c = retrivedImage.intExtSourceID,Image_Title__c = retrivedImage.txtImageTitle,Photo_URL__c = retrivedImage.txtImageURL));//Assuming id of image retrived from http call is unique and non reusable
        }
        system.debug('ImageSyncScheduler: mapRetrivedData: ' + mapRetrivedData);
        //Identify records to delete from Salesforce
        //In the absence of identifier of record changes from source server, cross checking all the existing images upto 50k due to governor limit on SOQL results
        for(Photograph__c existingImage : [Select id,Ext_Source_ID__c from Photograph__c limit 50000]){
            mapExistingData.put(existingImage.Ext_Source_ID__c,existingImage);//Store existing image data
            if(!mapRetrivedData.containsKey(existingImage.Ext_Source_ID__c)){//check if image id of existing photo is not present in retrived data
                lstPhotoToDelete.add(existingImage);   
            }
        }
        system.debug('ImageSyncScheduler: lstPhotoToDelete: ' + lstPhotoToDelete);
        //Identify new records to create on Salesforce
        for(string extId : mapRetrivedData.keyset()){
            if(!mapExistingData.containsKey(extId)){//check if image id of retrived data is not present in existing data
                lstPhotoToCreate.add(mapRetrivedData.get(extId));
            }
        }
        system.debug('ImageSyncScheduler: lstPhotoToCreate: ' + lstPhotoToCreate);
        
        //Update existing record scenario has not been considered due to lack of info on third party record changed 
        //which make difficult to identify records to updated in salesforce. isChanged flag can be helpful if send in response.
                
        database.insert(lstPhotoToCreate,false);
        database.delete(lstPhotoToDelete,false);
    }
}