global class ScheduleHandlerStarter {

	webservice String parameter { get; set; }

	public ScheduleHandlerStarter() {
		this.parameter = 'value';
	}

	webservice static String serviceName(){
		ScheduleHandler.StartScheduler(0);
		ScheduleHandlerSlow.StartScheduler(0);
		return 'started';
	}
}