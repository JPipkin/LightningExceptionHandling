({
	something : function(component) {
		var action = component.get('c.doIt');

		action.setParams({
			'lla' : JSON.stringify(component.get('v.deviceinfo'))
		})
		action.setCallback(this,function(result){
			if(!component.successfulResponse(result)){
				console.log('error');
				return;
			}
			component.set('v.deviceinfo',result.getReturnValue());
			console.log(result.getReturnValue());
		});

		$A.enqueueAction(action);
	}
})