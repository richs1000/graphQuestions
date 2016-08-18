// create a data model that exposes parameters to smart sparrow
// dataModel = {
//   mastery: 'false',
// };
var model = new pipit.CapiAdapter.CapiModel({
    mastery: false,
    numerator: 3,
    denominator: 5,
    weighted: true,
    directed: true
});

//Tells pipit to expose the following attributes
pipit.CapiAdapter.expose('mastery', model);
pipit.CapiAdapter.expose('numerator', model);
pipit.CapiAdapter.expose('denominator', model);
pipit.CapiAdapter.expose('weighted', model);
pipit.CapiAdapter.expose('directed', model);

// Tells pipit that the sim model is ready
pipit.Controller.notifyOnReady();

var node = document.getElementById('my-thing');
var app = Elm.GraphQuestions.embed(node);

app.ports.updateMastery.subscribe(function(mastery) {
    alert ("mastery = " + mastery);
    //app.ports.suggestions.send(suggestions);
    model.set('mastery', mastery);
});

$(document).ready(function() {
	// let smart sparrow know that the sim is ready to accept values
	//pipit.Controller.notifyOnReady();
  // app.ports.ssData.send( {num : 3, den : 5, weighted : true, directed : false });
  model.numerator = model.get('numerator');
  model.denominator = model.set('denominator');
  app.ports.ssData.send( model );
});
