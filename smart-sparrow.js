// create a data model that exposes parameters to smart sparrow
dataModel = {
  mastery: 'false',
};



var node = document.getElementById('my-thing');
var app = Elm.GraphQuestions.embed(node);

app.ports.updateMastery.subscribe(function(mastery) {
    dataModel.mastery = mastery
    alert ("mastery = " + dataModel.mastery);
    //app.ports.suggestions.send(suggestions);
});

$(document).ready(function() {
	// let smart sparrow know that the sim is ready to accept values
	//pipit.Controller.notifyOnReady();
  app.ports.ssData.send( {num : 3, den : 5, weighted : true, directed : false });
});
