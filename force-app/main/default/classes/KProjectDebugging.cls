public with sharing class KProjectDebugging {
    public static void printDebug(String name, Object element){
        try{
            Boolean print = Settings_K_Project__c.getValues('Debugging').Value__c.toLowerCase() == 'true' ? true : false;
            if(print){
                System.debug('KProjectDebugging - ' + name + ' : ' + JSON.serialize(element));
            } 
        }catch(Exception e){
            System.debug('Exception: ' + e.getMessage());
        }
    }
}