pragma solidity 0.5.0;

import "./data_assurance.sol";

contract Evaluation_contrat is Data {
 
    //fonction d'évaluation du contrat
    function evaluation() public{
        uint256 tj;
        uint256 th;
        uint256 tm;
        uint256 tm2;
        uint256 ts;
        uint256 tj2;
        require(msg.sender == assureur || msg.sender == assure, "Seul l'assureur ou le client peuvent évaluer le contrat");
        (tj,th,tm,ts) = view_info_System(0);
        (tj2,th,tm2,ts) = view_info_System(date_der_eval);
        
        require(tm - tm2 > 5 || date_der_eval == 0,"delai entre deux evaluation et de 5 minutess");
        if(date_der_eval > 0){
            NB_mois_assure += 12;
        }
        
        //calcul du bonus
        (tj2,th,tm2,ts) = view_info_System(Date_dernier_malus);
        if(tm - tm2 > 5){
            if(bonus_malus > 50){
                if(bonus_malus < 55){
                    bonus_malus = 50;
                }
                else{
                    bonus_malus -= 5;
                }
            }
        }
        if(tm - tm2 > 15 && bonus_malus > 100){
            bonus_malus = 100;
        }
        
        /*require(tj - tj2 > 365);
        NB_mois_assure += 12;
        (tj2,th,tm,ts) = view_info_System(Date_dernier_malus);
        if(tj - tj2 > 365){
            bonus_malus -= 5;
        }
        if(tj - tj2 > 1095 && bonus_malus > 100){
            bonus_malus = 100;
        }*/
        
        
        //calcul prix du nouveau contrat
        
        if(bonus_malus < 100){
            mensuel = tarif_ref-(tarif_ref-((tarif_ref*bonus_malus)/100));
        }
        else if(bonus_malus > 100){
            mensuel = tarif_ref+((tarif_ref*(bonus_malus-100))/100);
        }
        if (bonus_malus == 100){
            mensuel = tarif_ref;
        }
        
        if(NB_mois_assure > 11 && NB_mois_assure < 24){
            mensuel = mensuel+(mensuel/2);
        }
        else if(NB_mois_assure > 0 && NB_mois_assure < 11){
            mensuel *= 2;
        }
        
        
        date_der_eval = block.timestamp;
    }
    
    //fonction permettant de calculer la date
    function view_info_System(uint tmp) internal view returns (
                                            uint temps_system_jour,
                                            uint temps_system_heure,
                                            uint temps_system_minute,
                                            uint temps_system_seconde){
        uint t = 0;
        if(tmp != 0){
            t = tmp;
        }
        else{
            t = (block.timestamp);
        }
        uint tj = t/(86400);
        uint th = (t - (tj*86400)) /(3600);
        uint tm = (t -( (tj*86400) +  (th * 3600) )) / 60;
        uint ts = t -( (tj*86400) +  (th * 3600) + (tm * 60) );
        

        
        return (tj,th,tm,ts);
    }
    
}