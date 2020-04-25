public with sharing class ControllerForPlanandREPCount {
    
    public integer getplancount(){
        return TrueCostUtilities.countALLtheplans();
        
    }
    
    public integer getREPCount(){
        return TrueCostUtilities.countALLtheREPs();
    }
 }