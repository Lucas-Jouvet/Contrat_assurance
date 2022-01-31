pragma solidity 0.5.0;

import "./data_assurance.sol";

contract Calcul_malus_bonus is Data {
    
    //fonction permettant d'enregistrer un nouveau malus
    function accident(string memory responsabilite) public{
        int v = -1;
        if(strCompare(responsabilite,"total") == 0){
            v = 0;
        }
        else if (strCompare(responsabilite,"partiel") == 0){
            v = 1;   
        }
        else if (strCompare(responsabilite,"aucune") == 0){
            v = 2;
        }
        
        require(v > -1, "La responsabilité peut être: total, partiel ou aucune");
        require(msg.sender == assureur, "Seul l'assureur peut appeler cette fonction");
        if(v == 0){
            bonus_malus += 25;
            Date_dernier_malus = block.timestamp;
        }
        else if(v == 1){
            bonus_malus += 13; 
            Date_dernier_malus = block.timestamp;
        }
    }
    
    
    function strCompare(string memory _a, string memory _b) internal pure returns (int) {
        
        bytes memory a = bytes(_a);
        bytes memory b = bytes(_b);
        
        if (b.length == a.length){
            for (uint i = 0; i < b.length; i ++){
                if(a[i] == b[i]){
                }
                else{
                    return 1;
                }
            }
            return 0;
        }
        return 1;
    }
    
}