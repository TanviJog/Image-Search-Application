public class IS_ImageSourceCallOut{
    Public static List<IS_ImageResponseDTO.IMAGE_RESPONSE> getPhotos(){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://jsonplaceholder.typicode.com/photos');
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        System.debug('IS_ImageSourceCallOut : response:' + response);
        List<IS_ImageResponseDTO.IMAGE_RESPONSE> lstResponse = new List<IS_ImageResponseDTO.IMAGE_RESPONSE>();
        if (response.getStatusCode() == 200){
            String strJson = response.getBody();
            List<Object> lstResults = (List<Object>) JSON.deserializeUntyped(strJson); 
            //System.debug('IS_ImageSourceCallOut : Received photos: ' + lstResults);
            for (Object photo:lstResults){
                //System.debug('IS_ImageSourceCallOut: photo : ' + photo);
                Map<String, Object> mapPhoto = (Map<String, Object>)photo;
                //System.debug('IS_ImageSourceCallOut: mapPhoto: ' + mapPhoto);
                
                IS_ImageResponseDTO.IMAGE_RESPONSE ImgResponse = new IS_ImageResponseDTO.IMAGE_RESPONSE();
                ImgResponse.txtImageTitle = (string)mapPhoto.get('title');
                ImgResponse.txtImageURL = (string)mapPhoto.get('url');
                ImgResponse.intExtSourceID = string.valueof(mapPhoto.get('id'));
                lstResponse.add(ImgResponse);
        }
        System.debug('IS_ImageSourceCallOut: lstResponse: ' + lstResponse);
        }
        return lstResponse;
    }
}