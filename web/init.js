var account;
var Vente_Materiel_address;
const new_contract = document.querySelector('.new_contract');
const go = document.querySelector('.go');
const accident = document.querySelector('.accident');
const lire = document.querySelector('.lire');
const eval = document.querySelector('.evaluer');


var add = document.getElementById("add");
var na = document.getElementById("na");
var nv = document.getElementById("nv");
var npr = document.getElementById("npr");
var nma = document.getElementById("nma");
var ne = document.getElementById("ne");
var ncb = document.getElementById("ncb");

var type = document.getElementById("type");

var intervalId = null;
var etat = 0;
var test = 0;
function startApp() {
    getAccount();
    console.log("compte : "+account);
}

new_contract.addEventListener('click', () => {
    new_Contract();
});

go.addEventListener('click', () => {
    VM = new web3js.eth.Contract(ABI, add.value);
    affiche_Etat();
});

accident.addEventListener('click', () => {
    send_accident();
});
/*lire.addEventListener('click', () => {
    affiche_Etat();
});*/
eval.addEventListener('click', () => {
    send_eval();
});

async function new_Contract(){
    getAccount();
     console.log("valeurs : "+nma.value+" "+npr.value);
    accounts = await ethereum.enable();
    add.value = "Déploiement en cours";
    const deployedContract = await new web3js.eth.Contract(abi_source)
	  .deploy({
	      data: compile,
	      arguments: [na.value, nv.value, nma.value, npr.value,  ne.value, ncb.value]
	  })
	  .send({
	      from: accounts[0]
	  });

    console.log(
	`Contract deployed at address: ${deployedContract.options.address}`
    );
    add.value = deployedContract.options.address;

    VM = new web3js.eth.Contract(ABI, add.value);
}


async function getAccount() {
    const accounts = await ethereum.enable();
    account = accounts[0];
    //affiche_Etat();
}


window.addEventListener('load', function() {
    if (typeof ethereum !== 'undefined') {
	ethereum.enable()
	    .catch(console.error)
	web3js = new Web3(window['ethereum']);
    }
    else {
	alert("Vous devez installer metamask et vous connecter au réseau ropsten : https://metamask.io/")
    }

    startApp()

});

function send_accident() {
    getAccount();
    $("#txStatus").text("Informations accident en cours d'envoi ...");
    
    VM.methods.accident(type.value)
        .send({ from: account })
	.on("receipt", function(receipt) {
	    $("#txStatus").text("Information accident anvoyé avec succès!");
	    //affiche_Etat();
	    $("#Etat_contrat").append("Accident déclaré à responsabilité : "+type.value);
        })
        .on("error", function(error) {
	    $("#txStatus").text(error);
        });
    
    
}

function affiche_Etat() {
    getAccount();
    //$("#Etat_contrat").empty();
    VM.methods.lire_contrat().call({ from: account }).then((result) => {

	var date = new Date(result.date_der_eva * 1000);
	var months = ['Jan','Fev','Mar','Avr','Mai','Juin','Juil','Aou','Sep','Oct','Nov','Dec'];
	var year = date.getFullYear();
	var month = months[date.getMonth()];
	var dat = date.getDate();
	var minutes = "0" + date.getMinutes();
	// Seconds part from the timestamp
	var seconds = "0" + date.getSeconds();
	var formattedTime = dat+'/'+month+'/'+year+"  "+date.getHours() + ':' + minutes.substr(-2) + ':' + seconds.substr(-2);
	var formattedTime2 ="0";
	if(result.Date_dernier_malu != 0){
	    date = new Date(result.Date_dernier_malu * 1000);
	    minutes = "0" + date.getMinutes();
	    year = date.getFullYear();
	    month = months[date.getMonth()];
	    dat = date.getDate();
	    seconds = "0" + date.getSeconds(); 
	    var formattedTime2 = dat+'/'+month+'/'+year+"  "+date.getHours() + ':' + minutes.substr(-2) + ':' + seconds.substr(-2);
	}

	$("#Etat_contrat").append("<br/><h2>Contrat révision "+etat+"</h2><div class='DefVente'> \
              <ul> \
                <li>Prix de référence: "+result.tarif_re+"</li> \
                <li>Nombre de mois d'assurance : "+result.NB_mois_assur+"</li> \
                <li>Date du dernier malus : "+formattedTime2+"</li> \
<li>Mensualitée : "+result.mensue+"</li> \
<li>Dernière évaluation du contrat : "+formattedTime+"</li> \
<li>Bonus malus : "+result.bonus_malu+"</li> \
              </ul>\
 </div> ");
	etat++;
    }).catch(function(err){
	console.log('err...\n'+err);
    });   
}

function send_eval() {
    getAccount();
    $("#txStatus").text("Evaluation du contrat en cours d'envoi ...");
    
    VM.methods.evaluation()
        .send({ from: account })
	.on("receipt", function(receipt) {
	    $("#txstatus").text("Evaluation du contrat envoyé avec succès!");
	    if(test == 0){
		setInterval("send_eval()", 360000);
		test = 1;
	    }
	    affiche_Etat();
        })
        .on("error", function(error) {
	    $("#txStatus").text(error);
        });
    
    setTimeout('send_eval',360000);
}
