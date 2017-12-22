
@isTest
public class ExampleLightningLogCmpControllerTest {
	

	static testMethod void myTest1() {
		DeviceInformation lla = new DeviceInformation();
		lla.devicetype = 'device';
		lla.os = 'os';
		lla.mobiletouch = true;
		lla.browser = 'chrome';

		DeviceInformation di = ExampleLightningLogCmpController.doIt(JSON.serialize(lla));
		System.assert(di.auraerror != null);
		ExampleLightningLogCmpController.Something s = ExampleLightningLogCmpController.doItAgain();
		System.assert(s.auraerror != null);
	}
	
	
}