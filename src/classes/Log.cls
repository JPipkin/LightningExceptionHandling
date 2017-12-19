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

public class Log {

	/**
	 * get device information based on user-agent
	 * @param  userAgent  [user-agent]
	 * @param  devicetype [mobile/tablet/desktop]
	 * @param  notify     [send error email on error]
	 * @return            [LightningLogAgent]
	 */
	@AuraEnabled
	public static LightningLogAgent getDeviceInformation(String userAgent, String devicetype, Boolean notify){
		LightningLogAgent agent = new LightningLogAgent();
		try{
			Log.log('userAgent = ' + userAgent);
			if(userAgent == null || userAgent == ''){
				return agent;
			}
			DeviceCapture detect = new DeviceCapture();
			detect.userAgent = userAgent;
			agent.devicetype = devicetype;
			agent.os = detect.getOS();
			agent.mobiletouch = detect.isMobileTouch;
			agent.browser = detect.getBrowser();
			Log.log('detection:\n', agent);
		}
		catch(Exception e){
			agent.auraerror = e.getMessage();
			if(notify){
				Log.notify(e, 'General', agent, ErrorType.ERROR);
			}
		}
		return agent;
	}



    @TestVisible static List<LogEntry> entries = new List<LogEntry>();
	static User ru {
		get{
			if(ru == null){
				Set<String> userFields = Schema.SObjectType.User.fields.getMap().keySet();
				ru = Database.query('Select Profile.Name,' + String.join(new List<String>(userFields),',') + 
					' from User where Id =\''+UserInfo.getUserId()+'\'');
			}
			return ru;
		}
		private set;
	}

	public ENUM ErrorType {WARN, ERROR}

	/**
	 * stores debug statement and prints to debug log
	 * @param msg [debug statement]
	 */
	public static void log(String msg){
		LogEntry le = new LogEntry(msg);
		start(le.msg);
		entries.add(le);
	}

	/**
	 * stores debug log and prints to the debug log
	 * @param msg [debug statement string]
	 * @param o   [debug statement object to serialize]
	 */
	public static void log(String msg, Object o){
		LogEntry le = new LogEntry(msg,o);
		start(le.msg);
		entries.add(le);
	}

	/**
	 * inits data
	 * @param msg [debug statement]
	 */
	static void start(String msg){
		if(entries == null) entries = new List<LogEntry>();
		System.debug(msg);
	}

	public static void notify(Exception e, String appName, ErrorType et){
		notify(e, appName, null, et);
	}

	/**
	 * sends email on error to email addresses defined in given app's custom metadta settings
	 * @param e       [exception]
	 * @param appName [name of application]
	 */
	public static void notify(Exception e, String appName, LightningLogAgent lla, ErrorType et){
		Log.log('in notify: ' + et.name());
		if(et == ErrorType.WARN) return;
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setPlainTextBody(buildBody(e,lla));
		mail.setSubject('Exception handled on ' + appName);
		Log_Notification_Settings__mdt settings = [Select Email_On_Error__c from Log_Notification_Settings__mdt where MasterLabel=:appName];
		List<String> toAddresses = settings.Email_On_Error__c.split(',');
		mail.setToAddresses(toAddresses);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
	}

	/**
	 * build email body
	 * @param  e [Exception]
	 * @return   [plain text email body]
	 */
	static String buildBody(Exception e, LightningLogAgent lla){
		// get info from exception object
		String emailBody = '******* Exception Details *******\n';
		emailBody += 'Type: ' + e.getTypeName() + '\n';
		emailBody += 'Message: ' + e.getMessage() + '\n';
		emailBody += 'Stack Trace: ' + e.getStackTraceString() + '\n';
		emailBody += 'Line Number: ' + e.getLineNumber() + '\n';
		emailBody += '\n\n';

		// get items from LogEntry list
		emailBody += '******* Breadcrumbs *******\n';
		for(LogEntry le :entries){
			emailBody += '=>>>  ' + le.msg + '\n';
		}
		emailBody += '\n\n';

		// get running user details
		emailBody += '******* User Details *******\n';
		emailBody += 'Name: ' + ru.FirstName + ' ' + ru.LastName + '\n';
		emailBody += 'Email: ' + ru.Email + '\n';
		emailBody += 'Id: ' + ru.Id + '\n';
		emailBody += 'Profile: ' + ru.Profile.Name + '\n';
		emailBody += 'Title: ' + ru.Title + '\n';
		emailBody += '\n\n';
		
        DeviceCapture l = new DeviceCapture();
        if(lla != null){
        	emailBody += '******* Other Details *******\n';
			emailBody += 'Browser: ' + lla.browser + '\n';
			emailBody += 'Operating System: ' + lla.os + '\n';
			emailBody += 'Device: ' + lla.devicetype + '\n';
			emailBody += 'Current Page: ' + URL.getCurrentRequestUrl().getPath() + '\n';
        }
        else if(l.userAgent != ''){
			// other various helpful information
			emailBody += '******* Other Details *******\n';
			emailBody += 'Browser: ' + l.getBrowser() + '\n';
			emailBody += 'Operating System: ' + l.getOS() + '\n';
			emailBody += 'Device: ' + l.getDevice() + '\n';
			emailBody += 'Current Page: ' + URL.getCurrentRequestUrl().getPath() + '\n';
		}

		if(ApexPages.currentPage() != null && ApexPages.currentPage().getHeaders() != null){
			emailBody += 'Page Headers: ' + JSON.serializePretty(ApexPages.currentPage().getHeaders()) + '\n';
		}
		return emailBody;
	}

	/**
	 * wrapper class for debug statements
	 */
	public class LogEntry {
		public String msg;

		public LogEntry(String m){
			this.msg = m;
		}

		public LogEntry(String m, Object o){
			this.msg = m + ' ';
			try{
				this.msg += JSON.serializePretty(o).unescapeEcmaScript();
			}
			// if object is not serializable, parse to string instead
			catch(System.JSONException e){
				this.msg += STring.valueOf(e);
			}
		}
	}
    
	
}