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
* THIS IS JUST AN EXAMPLE....
 */
 
public with sharing class ControllerForLightning {

	@AuraEnabled
	public static LightningLogAgent doIt(String lla){
		Log.log('lla\n',lla);
		LightningLogAgent ret = LightningLogAgent.deserialize(lla);
		Savepoint sp = Database.setSavePoint();
		try{
			
			Log.log('query for account');
			Account a = [Select Id,Industry from Account LIMIT 1];
			Log.log('account\n',a);
			a.Name = 'Test 1234';
			update a;
		}
		catch(Exception e){
			Database.rollback(sp);
			ret.auraerror = e.getMessage();
			Log.notify(e, 'General', ret, Log.ErrorType.ERROR);
		}
		return ret;
	}

	@AuraEnabled
	public static Something doItAgain(){
		Something st = new Something();
		Savepoint sp = Database.setSavePoint();
		try{
			
			Log.log('query for account');
			Account a = [Select Id,Industry from Account LIMIT 1];
			Log.log('account\n',a);
			a.Name = 'Test 1234';
			update a;
		}
		catch(Exception e){
			Database.rollback(sp);
			st.auraerror = e.getMessage();
			Log.notify(e, 'General', null , Log.ErrorType.ERROR);
		}
		st.done = true;
		return st;
	}

	public class Something{
		@AuraEnabled public Boolean done;
		@AuraEnabled public String auraerror;
	}

	public class ControllerForLightningException extends Exception{}
}