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
 
public class DeviceCapture {

	public String userAgent;

	public DeviceCapture(){
		setUserAgent();
	}

    /**
     * gets user-agent from page headers
     */
	private void setUserAgent() {
        if(Apexpages.currentPage() != null && Apexpages.currentPage().getHeaders() != null){
            userAgent = Apexpages.currentPage().getHeaders().get('USER-AGENT');
            userAgent = userAgent ==  null ? '' : userAgent;
        }
    }

	public Boolean isMobileTouch {
        get {
            if(userAgent == null) return false;
            return ((userAgent.contains('SalesforceMobileSDK/') && userAgent.contains('touch/')) || userAgent.contains('SalesforceTouchContainer/2.0'));
        }
    }

    
    /**
     * Returns True if any version of Internet Explorer is detected.
     */
    public Boolean isIE {
        get {
            return (userAgent != null && userAgent.contains('MSIE '));
        }
    }

    /**
     * Returns True if Internet Explorer 9 is detected.
     */
    public Boolean isIE9 {
        get {
            return (userAgent != null && userAgent.contains('MSIE 9.0'));
        }
    }

    /**
     * Returns True if Internet Explorer 8 is detected.
     */
    public Boolean isIE8 {
        get {
            return (userAgent != null && userAgent.contains('MSIE 8.0'));
        }
    }

    /**
     * Returns True if Internet Explorer 7 is detected.
     */
    public Boolean isIE7 {
        get {
            return (userAgent != null && userAgent.contains('MSIE 7.0'));
        }
    }

    public Boolean isChrome {
        get{
            return (userAgent != null && userAgent.contains('Chrome/'));
        }
    }

    public Boolean isFF {
        get{
            return (userAgent != null && userAgent.contains('Firefox/'));
        }
    }

    public Boolean isOPR {
        get{
            return (userAgent != null && userAgent.contains('OPR/'));
        }
    }

    public Boolean isSafari {
        get{
            return (userAgent != null && userAgent.contains('Safari/'));
        }
    }


    /**
     * OS
     */
    public Boolean isOSX{
        get{
            return (userAgent != null && userAgent.contains('OS X'));
        }
    }

    public Boolean isWindows{
        get{
            return (userAgent != null && userAgent.contains('Windows'));
        }
    }
    
    public Boolean isIOS {
        get {
            return (userAgent != null && (userAgent.contains('iPhone OS') ||
                    userAgent.contains('iPad OS')) && userAgent.contains('SalesforceTouchContainer/2.0'));
        }
    }

    public Boolean isIPhone {
        get {
            return (userAgent != null && userAgent.contains('(iPhone)'));
        }
    }

    public Boolean isIPad {
        get {
            return (userAgent != null && userAgent.contains('(iPad)'));
        }
    }

    public String getOS(){
    	return (isOSX ? 'Macintosh' : (isWindows ? 'Windows' : 'Unknown'));
    }

    public String getBrowser(){
    	String s;
    	if(isIE) s = 'Internet Explorer';
    	else if(isChrome) s = 'Chrome';
    	else if(isFF) s = 'Firefox';
    	else if(isSafari) s = 'Safari';
    	else s = 'Unknown';
    	if(isOPR) s = 'Opera';
    	return s;
    }
    
    public String getDevice(){
    	if(isMobileTouch){
    		if(isIPhone) return 'iPhone';
    		if(isIPad) return 'iPad';
    		else return 'Other mobile device';
    	}	
    	else{
    		return 'Laptop/Desktop';
    	}
    }
}