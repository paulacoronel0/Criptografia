// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import "./ActuacionBase.sol";

contract Ordenanza is ActuacionBase{

    struct DatosOrdenanza {
        uint256  numOrdenanza;   // timestamp Unix en segundos
    }

    // ESTADO

    mapping(string => DatosOrdenanza) internal datosExtra;

    // EVENTOS ESPECIFICOS:
    
    event OrdenanzaAgregada(string id, uint256 numOrdenanza, string vigencia);
    event VigenciaActualizada(string id, string vigenciaNueva, string dato);

    // FUNCIONES:

    /* AGREGAR ENTRADA: Solicite un costo en Ethereums (ETH) al cliente, por ejemplo 500 wei de ETH,
        para agregar una entrada nueva, que será registrada en la blockchain.
        Si el cliente quiere agregar la entrada sin brindar este costo, entonces la operación debe ser
        rechazada. Además, considere que si la entrada ya fue agregada, entonces la operación debe ser
        rechazada. 
    */

    // memory: hace que sea temporal en el metodo

    function agregarOrdenanza(  
        string memory _id, 
        uint256 _dniAutor,
        uint256 _numOrdenanza, 
        string memory _nombreAutor,
        string memory _vigencia) public payable {
            require(keccak256(bytes(_vigencia)) == keccak256(bytes("Vigente"))   ||
                    keccak256(bytes(_vigencia)) == keccak256(bytes("Modificada")) ||
                    keccak256(bytes(_vigencia)) == keccak256(bytes("Derogada")),
                    "Vigencia invalida: use Vigente, Modificada o Derogada"
            );
            _inicializarActuacion(_id, _dniAutor, _nombreAutor, _vigencia);
            emit OrdenanzaAgregada(_id, _numOrdenanza, _vigencia);
        }

    // VER ENTRADA: Retorne la entrada que el usuario indica

    function consultarOrdenanza(string memory _id)
        public
        view
        returns (
            string   memory id,
            uint256  fechaCreacion,   // timestamp Unix en segundos
            uint256  dniAutor,
            string   memory nombreAutor,
            string   memory vigencia,
            uint256  numOrdenanza
    
        )
    {
        ActuacionBase.Actuacion memory actuacion = _consultarActuacion(_id);
        DatosOrdenanza storage o = datosExtra[_id];
        return (
            actuacion.id,
            actuacion.fechaCreacion,
            actuacion.dniAutor,
            actuacion.nombreAutor,
            actuacion.estado,
            o.numOrdenanza
        );
    }
    
    /*  MODIFICAR ENTRADA: Tome un identificador y un dato concreto y modifique una entrada existente.
        Esta operación solo debe estar disponible para el cliente y/o el responsable de inicializar el
        contrato. Si la entrada a modificar no existe, la operación debe ser rechazada.*/

    function modificarVigencia(
        string memory _id, 
        string memory _vigencia,
        string memory _dato) 
        public returns (bool success)
    {
        require(keccak256(bytes(_vigencia)) == keccak256(bytes("Vigente"))   ||
                keccak256(bytes(_vigencia)) == keccak256(bytes("Modificada")) ||
                keccak256(bytes(_vigencia)) == keccak256(bytes("Derogada")),
                "Vigencia invalida: use Vigente, Modificada o Derogada"
        );
        _modificarEntrada(_id, _vigencia, _dato);
        emit VigenciaActualizada(_id, _vigencia, _dato);
        return true;
    }

    /*  ELIMINAR ENTRADA: Marque una entrada como eliminada.
        Esta operación solo debe estar disponible para el cliente y/o el responsable de inicializar el
        contrato.
    */

    function eliminar(string memory _id, string memory _vigencia) public {
        require(keccak256(bytes(_vigencia)) == keccak256(bytes("Derogada")),
                "Vigencia invalida: use Vigente, Modificada o Derogada"
        );
        _eliminarActuacion(_id, _vigencia);
    }

}