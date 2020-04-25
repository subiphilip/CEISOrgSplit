public class controllerForZipCodes{
    
    public string zipcode {get;set;}
    public list<string> tdsplist {Get;set;}
    public list<string> citylist {get;set;}
    
    
    public controllerForZipCodes(){
    	zipcode=apexpages.currentpage().getParameters().get('zip');
        tdsplist=controllerformobilemain.GetTDSPsByZip(zipcode);
        citylist=controllerformobilemain.GetCitiesByZip(zipcode);
    } 

}