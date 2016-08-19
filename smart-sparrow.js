// create a data model that exposes parameters to smart sparrow
// dataModel = {
//   mastery: 'false',
// };
var model = new pipit.CapiAdapter.CapiModel({
    mastery: false,
    numerator: 30,
    denominator: 50,
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
    model.set('mastery', mastery);
    pipit.Controller.triggerCheck();
});

model.on('change:numerator', function(){
    // var v = model.get('numerator')
    // alert ("numerator = " + model.numerator + " " + v );
    app.ports.ssData.send( model );
  });

$(document).ready(function() {
});
