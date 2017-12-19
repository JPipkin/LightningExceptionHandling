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
public class DeviceCaptureTest {
	
	
    private static testMethod void validateIsIE9() {
        ApexPages.currentPage().getHeaders().put('USER-AGENT', 'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/6.0)');
        DeviceCapture controller = new DeviceCapture();
        System.assertEquals(true, controller.isIE);
        System.assertEquals(true, controller.isIE9);
        System.assertEquals(false, controller.isIE8);
        System.assertEquals(false, controller.isIE7);
    }

    private static testMethod void validateIsIE8() {
        ApexPages.currentPage().getHeaders().put('USER-AGENT', 'Mozilla/5.0 (compatible; MSIE 8.0; Windows NT 6.1; WOW64; Trident/6.0)');
        DeviceCapture controller = new DeviceCapture();
        System.assertEquals(true, controller.isIE);
        System.assertEquals(false, controller.isIE9);
        System.assertEquals(true, controller.isIE8);
        System.assertEquals(false, controller.isIE7);
    }

    private static testMethod void validateIsIE7() {
        ApexPages.currentPage().getHeaders().put('USER-AGENT', 'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.1; WOW64; Trident/6.0; SLCC2; ' +
                '.NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; InfoPath.2; .NET4.0C; .NET4.0E)');

        DeviceCapture controller = new DeviceCapture();
        System.assertEquals(true, controller.isIE);
        System.assertEquals(false, controller.isIE9);
        System.assertEquals(false, controller.isIE8);
        System.assertEquals(true, controller.isIE7);
        System.assert(controller.getDevice() != null);
    }

    private static testMethod void validateIsMobileTouch() {
        ApexPages.currentPage().getHeaders().put('USER-AGENT', 'SalesforceMobileSDK/1.5.2 iPhone OS/6.1.3 (iPad) touch/2.0.0 Hybrid Mozilla/5.0 ' +
                '(iPad; CPU OS 6_1_3 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Mobile/10B329 SalesforceTouchContainer/2.0.0');

        DeviceCapture controller = new DeviceCapture();
        System.assert(controller.isIOS);
        System.assert(!controller.isIPhone);
        System.assert(controller.isIPad);
        System.assert(controller.getDevice() != null);
        System.assertEquals(true, controller.isMobileTouch);

    }
    
    private static testMethod void validateIsOSX() {
        ApexPages.currentPage().getHeaders().put('USER-AGENT', ' Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) '+
        	'AppleWebKit/536.26.14 (KHTML, like Gecko) (Coda, like Safari)');

        DeviceCapture controller = new DeviceCapture();
        System.assert(controller.isOSX);
        System.assertEquals('Macintosh',controller.getOS());
        System.assert(controller.getDevice() != null);
    }

    private static testMethod void validateIsWindows() {
        ApexPages.currentPage().getHeaders().put('USER-AGENT', 'Mozilla/5.0 (Windows NT x.y; Win64; x64; rv:10.0) Gecko/20100101 Firefox/10.0');

        DeviceCapture controller = new DeviceCapture();
        System.assert(controller.isWindows);
        System.assertEquals('Windows',controller.getOS());
        System.assert(controller.getDevice() != null);
    }

    private static testMethod void validateIsChrome() {
        ApexPages.currentPage().getHeaders().put('USER-AGENT', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_3) '+
        	'AppleWebKit/535.10 (KHTML, like Gecko) Chrome/17.0.925.0 QQBrowser/1.0.0.1096 Safari/535.10');

        DeviceCapture controller = new DeviceCapture();
        System.assert(controller.isOSX);
        System.assert(controller.isChrome);
        System.assertEquals('Chrome',controller.getBrowser());
    }

    private static testMethod void validateIsFF() {
        ApexPages.currentPage().getHeaders().put('USER-AGENT', 'Mozilla/5.0 (Windows NT x.y; Win64; x64; rv:10.0) Gecko/20100101 Firefox/10.0');

        DeviceCapture controller = new DeviceCapture();

        System.assert(controller.isWindows);
        System.assert(controller.isFF);
        System.assertEquals('Firefox',controller.getBrowser());
        
    }

    private static testMethod void validateIsOPR() {
        ApexPages.currentPage().getHeaders().put('USER-AGENT', 'Mozilla/5.0 (Windows NT 6.1; WOW64) '+
        	'AppleWebKit/537.36 (KHTML, like Gecko) Chrome/28.0.1500.52 Safari/537.36 OPR/15.0.1147.100');

        DeviceCapture controller = new DeviceCapture();
        System.assert(controller.isWindows);
        System.assert(controller.isOPR);
        System.assertEquals('Opera',controller.getBrowser());
        
    }
	
}