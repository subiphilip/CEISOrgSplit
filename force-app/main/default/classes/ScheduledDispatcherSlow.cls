global class ScheduledDispatcherSlow Implements Schedulable{
	public Interface IScheduleDispatched 
    { 
        void execute(SchedulableContext sc); 
    } 
    
    global void execute(SchedulableContext sc) 
    {
        Type targettype = Type.forName('ScheduleHandlerSlow');   
        if(targettype!=null) {
            IScheduleDispatched obj = (IScheduleDispatched)targettype.NewInstance();
            obj.execute(sc);   
        } 
    } 
}