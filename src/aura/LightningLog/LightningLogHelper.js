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
({
	/**
	 * gets device type based on $Browser var
	 * @return {[type]} [description]
	 */
	getDeviceType : function(){
		var ff = $A.get('$Browser.formFactor');
		var isAndroid = $A.get('$Browser.isAndroid')
		var isIOS = $A.get('$Browser.isIOS')
		var isIPad = $A.get('$Browser.isIPad')
		var isIPhone = $A.get('$Browser.isIPhone')
		var isWindowsPhone = $A.get('$Browser.isWindowsPhone')

		var result;

		if(ff.toLowerCase() == 'phone'){
			result = 'Phone ';
			if(isIOS) result += '(iPhone)';
			else if(isAndroid) result += '(Andriod)';
			else if(isWindowsPhone) result += '(Windows)';
			else result += '(Unknown)';
		}
		else if(ff.toLowerCase() == 'tablet'){
			result = 'Tablet ';
			if(isIPad) result += '(iPad)';
			else result += '(Android)';
		}
		else{
			// is desktop
			result = ff;
		}
		return result;
	},

	/**
	 * gathers information based on user-agent string
	 * @param  {[type]} component [description]
	 * @return {[type]}           [description]
	 */
	fillDeviceInfo : function(component) {
		var action = component.get('c.getDeviceInformation');
		var dt = this.getDeviceType();
		component.set('v.devicetype',dt);

		action.setParams({
			'userAgent' : navigator.userAgent,
			'devicetype' : dt,
			'notify' : component.get('v.emailOnError')
		})

		action.setCallback(this,function(result){
			if(!this.handleResponse(result)){
				return;
			}
			component.set('v.deviceinfo',result.getReturnValue());
			// console.log(result.getReturnValue());
		});

		$A.enqueueAction(action);
	},

	/**
	 * parses server response to determine if success or fail
	 * @param  {[type]} response [server response]
	 * @return {[type]}          [Pass/Fail]
	 */
	handleResponse : function(response) {
        try
        {
            var state = response.getState();
            if (state !== "SUCCESS") 
            {
                var unknownError = true;
                if(state === 'ERROR')
                {
                    var errors = response.getError();
                    if (errors) 
                    {
                        if (errors[0] && errors[0].message) 
                        {
                            unknownError = false;
                            this.showError(errors[0].message);
                        }
                    }
                }
                if(unknownError)
                {
                    this.showError('Unknown error from Apex class');
                }
                return false;
            }
            else if(response.getReturnValue() != undefined){
            	var r = response.getReturnValue();
            	if(r.hasOwnProperty('auraerror')){
            		this.showError(r.auraerror)
            		return false;
            	}
            }
            return true;
        }
        catch(e)
        {
            this.showError(e.message);
            return false;
        }
    },

    /**
     * fires toast event for errors
     * @param  {[type]} message [error message]
     * @param  {[type]} mode    [toast mode]
     * @return {[type]}         [description]
     */
    showError : function(message, mode){
	    this.showToast('Error',message, mode || 'sticky')
	},

	/**
     * fires toast event for successes
     * @param  {[type]} message [success message]
     * @param  {[type]} mode    [toast mode]
     * @return {[type]}         [description]
     */
	showSuccess : function(message, mode){
	    this.showToast('Success',message, mode)
	},

	/**
     * fires toast events
     * @param  {[type]} message [toast message]
     * @param  {[type]} mode    [toast mode]
     * @return {[type]}         [description]
     */
	showToast : function(ttype, message, mode)
	{
	    var toastEvent = $A.get("e.force:showToast");
	    toastEvent.setParams({
	        "type": ttype,
	        "mode": mode || "dismissible",
	        "message": message
	    });
	    toastEvent.fire();    
	}
	
})