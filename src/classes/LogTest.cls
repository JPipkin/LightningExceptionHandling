/**
* Copyright 2017 OpFocus, Inc
* 
* Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation 
* files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, 
* modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the 
* Software is furnished to do so, subject to the following conditions:
* 
* The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES 
* OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE 
* LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR 
* IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*
*
 */

@isTest
public class LogTest {
	
	static testMethod void positive() {
		Log.log('print str');
		Log.log('print obj',new Account());
		System.assertEquals(2,log.entries.size());

		Log.log('print unserializable object',new SelectOption('Test','Test'));
		System.assertEquals(3,log.entries.size());	
		Integer cnt = 0;
		LightningLogAgent lla = new LightningLogAgent();
		lla.devicetype = 'device';
		lla.os = 'os';
		lla.mobiletouch = true;
		lla.browser = 'chrome';
		for(Log_Notification_Settings__mdt lns :[Select MasterLabel from Log_Notification_Settings__mdt]){
			try{
				throw new LogTestException('Test');
			}
			catch(LogTestException e){
				try{
					log.notify(e,lns.MasterLabel,lla,Log.ErrorType.ERROR);
				}
				catch(System.EmailException ee){
					if(!ee.getMessage().containsIgnoreCase('SINGLE_EMAIL_LIMIT_EXCEEDED')){
						throw ee;
					}
				}
				cnt++;
			}
		}	

		LightningLogAgent lla2 = LightningLogAgent.deserialize(JSON.serialize(lla));
		System.assert(lla.browser == lla2.browser);
		System.assert(lla.os == lla2.os);
		System.assert(lla.mobiletouch == lla2.mobiletouch);
		System.assert(lla.devicetype == lla2.devicetype);
		System.assert(lla.auraerror == lla2.auraerror);
	}

	static testMethod void negative(){
		ApexPages.currentPage().getHeaders().put('USER-AGENT', ' Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) '+
        	'AppleWebKit/536.26.14 (KHTML, like Gecko) (Coda, like Safari)');
		Integer cnt = 0;
		for(Log_Notification_Settings__mdt lns :[Select MasterLabel from Log_Notification_Settings__mdt]){
			try{
				throw new LogTestException('Test');
			}
			catch(LogTestException e){
				try{
					log.notify(e,lns.MasterLabel,Log.ErrorType.ERROR);
				}
				catch(System.EmailException ee){
					if(!ee.getMessage().containsIgnoreCase('SINGLE_EMAIL_LIMIT_EXCEEDED')){
						throw ee;
					}
				}
				cnt++;
			}
		}	
	}

	static testMethod void auraDeviceCapture(){
		String ua = 'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.1; WOW64; Trident/6.0; SLCC2; ' +
                '.NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; InfoPath.2; .NET4.0C; .NET4.0E)';
        System.assert(Log.getDeviceInformation(ua,'DESKTOP',true).auraerror == null);
        System.assert(Log.getDeviceInformation(null,'DESKTOP',true).auraerror == null);
	}

	
	public class LogTestException extends Exception{}
}