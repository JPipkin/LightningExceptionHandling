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
	 * @return            [DeviceInformation]
	 */
	@AuraEnabled
	public static DeviceInformation getDeviceInformation(String userAgent, String devicetype, Boolean notify){
		DeviceInformation agent = new DeviceInformation();
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
				Log.notify(e, 'General', agent);
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

	/**
	 * stores debug statement and prints to debug log
	 * @param msg [debug statement]
	 */
	public static void log(String msg){
		add(new LogEntry(msg));
	}

	/**
	 * stores debug log and prints to the debug log
	 * @param msg [debug statement string]
	 * @param o   [debug statement object to serialize]
	 */
	public static void log(String msg, Object o){
		add(new LogEntry(msg,o));
	}

	/**
	 * inits data
	 * @param msg [debug statement]
	 */
	static void add(LogEntry le){
		if(entries == null) entries = new List<LogEntry>();
		System.debug(le.msg);
		entries.add(le);
	}

	public static void notify(Exception e, String appName){
		notify(e, appName, null);
	}

	/**
	 * sends email on error to email addresses defined in given app's custom metadta settings
	 * @param e       [exception]
	 * @param appName [name of application]
	 * @param lla     [DeviceInformation wrapper]
	 */
	public static void notify(Object obj, String appName, DeviceInformation lla){
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setSubject('Exception handled on ' + appName);
		Log_Notification_Settings__mdt[] settings = [Select Email_On_Error__c from Log_Notification_Settings__mdt where MasterLabel=:appName];
		if(settings.isEmpty()) return;
		if(settings[0].Email_On_Error__c == null) return;
		List<String> toAddresses = settings[0].Email_On_Error__c.split(',');
		mail.setToAddresses(toAddresses);

		if(obj instanceof Database.SaveResult[]){
			List<Database.SaveResult> lstSR = (new List<Database.SaveResult>());
			for(Database.SaveResult sr : (Database.SaveResult[])obj){
				if(!sr.isSuccess()){
					lstSR.add(sr);
				}
			}
			if(lstSR.isEmpty()) return;
			obj = lstSR;
		}
		else if(obj instanceof Database.UpsertResult[]){
			List<Database.UpsertResult> lstUR = (new List<Database.UpsertResult>());
			for(Database.UpsertResult sr : (Database.UpsertResult[])obj){
				if(!sr.isSuccess()){
					lstUR.add(sr);
				}
			}
			if(lstUR.isEmpty()) return;
			obj = lstUR;
		}
		mail.setPlainTextBody(buildBody(obj,lla));
		Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
	}
	
	public static void notify(String appName, String emailbody, String subject){
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setSubject(subject);
		Log_Notification_Settings__mdt[] settings = [Select Email_On_Error__c from Log_Notification_Settings__mdt where MasterLabel=:appName];
		if(settings.isEmpty()) return;
		if(settings[0].Email_On_Error__c == null) return;
		List<String> toAddresses = settings[0].Email_On_Error__c.split(',');
		mail.setToAddresses(toAddresses);
		mail.setPlainTextBody(emailbody);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
	}

	/**
	 * build email body
	 * @param  e [Exception]
	 * @return   [plain text email body]
	 */
	static String buildBody(Object eo, DeviceInformation lla){
		// get info from exception object
		String emailBody = '******* Exception Details *******\n';
		if(eo instanceof Exception){
			Exception e = (Exception) eo;
			emailBody += 'Type: ' + e.getTypeName() + '\n';
			emailBody += 'Message: ' + e.getMessage() + '\n';
			emailBody += 'Stack Trace: ' + e.getStackTraceString() + '\n';
			emailBody += 'Line Number: ' + e.getLineNumber() + '\n';
		}
		else if(eo instanceof Database.SaveResult[]){
			for(Database.SaveResult sr :(Database.SaveResult[]) eo){
				emailbody += 'ERROR ON RECORD:\n';
				emailBody += 'Record Id: ' + sr.getId() + '\n';
				emailbody += 'Errors:\n';
				for(Database.Error de : sr.getErrors()){
					emailbody += '- ' + de.getMessage() + ' [' + String.join(de.getFields(),', ') + ']\n';
				}
				emailBody += '\n';
			}
		}
		else if(eo instanceof Database.UpsertResult[]){
			for(Database.UpsertResult sr :(Database.UpsertResult[]) eo){
				emailbody += 'ERROR ON RECORD:\n';
				emailBody += 'Record Id: ' + sr.getId() + '\n';
				emailbody += 'Errors:\n';
				for(Database.Error de : sr.getErrors()){
					emailbody += '- ' + de.getMessage() + ' [' + String.join(de.getFields(),', ') + ']\n';
				}
				emailBody += '\n';
			}
		}
		else{
			emailbody += JSON.serializePretty(eo) + '\n';
		}
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