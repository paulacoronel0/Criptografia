// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import "./ActuacionBase.sol";

contract Ordenanza is ActuacionBase{

    struct DatosOrdenanza {
        uint256  numOrdenanza;   // timestamp Unix en segundos
    }

    // ESTADO

    mapping(uint256 => DatosOrdenanza) internal datosExtra;

    // EVENTOS ESPECIFICOS:
    
    event OrdenanzaAgregada(uint256 id, uint256 numOrdenanza, uint8 vigencia, bytes32 hash);
    event VigenciaActualizada(uint256 id, uint8 vigenciaNueva, bytes32 hash);

    // FUNCIONES:

    /* AGREGAR ENTRADA: Solicite un costo en Ethereums (ETH) al cliente, por ejemplo 500 wei de ETH,
        para agregar una entrada nueva, que será registrada en la blockchain.
        Si el cliente quiere agregar la entrada sin brindar este costo, entonces la operación debe ser
        rechazada. Además, considere que si la entrada ya fue agregada, entonces la operación debe ser
        rechazada. 
    */

    // memory: hace que sea temporal en el metodo

    function agregarOrdenanza(  
        uint256 _id,
        uint256 _dniAutor,
        bytes32 _hash,
        uint256 _fechaCreacion,
        uint256 _numOrdenanza, 
        uint8   _vigencia) public payable {
            require(msg.value >= COSTO, "No se ha pagado la tarifa de registro");
            require(keccak256(abi.encodePacked(_vigencia)) == keccak256(abi.encodePacked(uint8(0))),
                "Vigencia invalida: use (0) para Vigente"
            );
            _inicializarActuacion(_id, _dniAutor, _vigencia, _hash, _fechaCreacion);
            datosExtra[_id].numOrdenanza = _numOrdenanza;
            emit OrdenanzaAgregada(_id, _numOrdenanza, _vigencia, _hash);
        }

    // VER ENTRADA: Retorne la entrada que el usuario indica

    function consultarOrdenanza(uint256 _id)
        public
        view
        returns (
            uint256  fechaCreacion,   // timestamp Unix en segundos
            uint256  dniAutor,
            uint8   vigencia,
            uint256  numOrdenanza,
            bytes32 hash
    
        )
    {
        ActuacionBase.Actuacion memory actuacion = _consultarActuacion(_id);
        DatosOrdenanza storage o = datosExtra[_id];
        return (
            actuacion.fechaCreacion,
            actuacion.dniAutor,
            actuacion.historial[actuacion.historial.length - 1].estado,
            o.numOrdenanza,
            actuacion.historial[actuacion.historial.length - 1].hash
        );
    }
    
    /*  MODIFICAR ENTRADA: Tome un identificador y un dato concreto y modifique una entrada existente.
        Esta operación solo debe estar disponible para el cliente y/o el responsable de inicializar el
        contrato. Si la entrada a modificar no existe, la operación debe ser rechazada.*/

    function modificarVigencia(
        uint256 _id, 
        uint8 _vigencia,
        bytes32 _hash) 
        public returns (bool success)
    {
        require(keccak256(abi.encodePacked(_vigencia)) == keccak256(abi.encodePacked(uint8(1))),
            "Vigencia invalida: use (1) para Modificada "
        );
        _modificarActuacion(_id, _vigencia, _hash);
        emit VigenciaActualizada(_id, _vigencia, _hash);
        return true;
    }

    /*  ELIMINAR ENTRADA: Marque una entrada como eliminada.
        Esta operación solo debe estar disponible para el cliente y/o el responsable de inicializar el
        contrato.
    */

    function eliminar(uint256 _id, uint8 _vigencia) public {
        require(
                keccak256(abi.encodePacked(_vigencia)) == keccak256(abi.encodePacked(uint8(2))),
                "Vigencia invalida: use (2) para Derogada"
            );
        _eliminarActuacion(_id, _vigencia);
    }
}