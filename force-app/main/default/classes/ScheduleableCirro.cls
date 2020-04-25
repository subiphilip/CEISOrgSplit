global class ScheduleableCirro implements Schedulable{
  global void execute (SchedulableContext SC){
       orderapimanager vir = new orderapimanager();
    vir.checkcirrostatus();
  } 
}