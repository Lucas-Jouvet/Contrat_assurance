pragma solidity 0.5.0;

import "./data_assurance.sol";

contract assurance_principal is Data {
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    event CommitMessage(string message);
    event FunctionUpdate(bytes4 indexed functionId, address indexed oldDelegate, address indexed newDelegate, string functionSignature);

    constructor(address adresse_assureur, address adresse_assure, uint256 mois_assure, uint256 prix, address evaluation, address calcul_malus) public {
        assureur = adresse_assureur;
        assure = adresse_assure;
        tarif_ref = prix;
        NB_mois_assure = mois_assure;
        bonus_malus = 100;
        date_der_eval = 0;
        
        contractOwner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
        address _erc1538Delegate = 0xcC0459454ce853146F2299D3b3916bB1592D1957;
        //Adding ERC1538 updateContract function
        bytes memory signature = "updateContract(address,string,string)";
        bytes4 funcId = bytes4(keccak256(signature));
        delegates[funcId] = _erc1538Delegate;
        funcSignatures.push(signature);
        funcSignatureToIndex[signature] = funcSignatures.length;
        emit FunctionUpdate(funcId, address(0), _erc1538Delegate, string(signature));
        emit CommitMessage("Added ERC1538 updateContract function at contract creation");
        
        signature = "accident(string)";
        funcId = bytes4(keccak256(signature));
        delegates[funcId] = calcul_malus;
        funcSignatures.push(signature);
        funcSignatureToIndex[signature] = funcSignatures.length;
        emit FunctionUpdate(funcId, address(0), calcul_malus, string(signature));
        emit CommitMessage("Added accident");
        
        signature = "evaluation()";
        funcId = bytes4(keccak256(signature));
        delegates[funcId] = evaluation;
        funcSignatures.push(signature);
        funcSignatureToIndex[signature] = funcSignatures.length;
        emit FunctionUpdate(funcId, address(0), evaluation, string(signature));
        emit CommitMessage("Added ERC1538 evaluation");
    }

    function() external payable {
        address delegate = delegates[msg.sig];
        require(delegate != address(0), "Function does not exist.");
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize)
            let result := delegatecall(gas, delegate, ptr, calldatasize, 0, 0)
            let size := returndatasize
            returndatacopy(ptr, 0, size)
            switch result
            case 0 {revert(ptr, size)}
            default {return (ptr, size)}
        }
    }
    
    function lire_contrat() public view returns (uint256 tarif_re,uint256 date_permi, uint256 NB_mois_assur, uint256 Date_dernier_malu,uint256 mensue,uint256 date_der_eva,uint256 bonus_malu){
        require (msg.sender == assureur || msg.sender == assure, "Seul assureur et le client peuvent consulter ces informations");
        return(tarif_ref,date_permis,NB_mois_assure,Date_dernier_malus, mensuel,date_der_eval,bonus_malus);
    }
}