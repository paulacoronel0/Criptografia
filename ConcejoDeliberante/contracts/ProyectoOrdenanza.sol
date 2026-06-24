// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import "./ActuacionBase.sol";

contract ProyectoOrdenza is ActuacionBase{

    struct DatosProyectoOrdenanza {
        uint256  numExpediente;   // timestamp Unix en segundos
    }

    // ESTADO

    mapping(uint256 => DatosProyectoOrdenanza) internal datosExtra;

    // EVENTOS ESPECIFICOS:
    
    event OrdenanzaAgregada(uint256 id, uint256 numExpediente, uint8 resultado, bytes32 hash);
    event ResultadoActualizado(uint256 id, uint8 resultadoNueva, bytes32 hash);

    // FUNCIONES:

    /* AGREGAR ENTRADA: Solicite un costo en Ethereums (ETH) al cliente, por ejemplo 500 wei de ETH,
        para agregar una entrada nueva, que será registrada en la blockchain.
        Si el cliente quiere agregar la entrada sin brindar este costo, entonces la operación debe ser
        rechazada. Además, considere que si la entrada ya fue agregada, entonces la operación debe ser
        rechazada. 
    */

    // memory: hace que sea temporal en el metodo

    function agregarProyectoOrdenanza(  
        uint256 _id,
        uint256 _dniAutor,
        bytes32 _hash,
        uint256 _fechaCreacion,
        uint256 _numExpediente, 
        uint8   _resultado) public payable {
            require(keccak256(abi.encodePacked(_resultado)) == keccak256(abi.encodePacked(uint8(0))) ||
                keccak256(abi.encodePacked(_resultado)) == keccak256(abi.encodePacked(uint8(1))) ||
                keccak256(abi.encodePacked(_resultado)) == keccak256(abi.encodePacked(uint8(2))),
                "resultado invalida: use (0) para Aprobada, (1) para Archivada o (2) para Rechazada"
            );
            _inicializarActuacion(_id, _dniAutor, _resultado, _hash, _fechaCreacion);
            emit OrdenanzaAgregada(_id, _numExpediente, _resultado, _hash);
        }

    // VER ENTRADA: Retorne la entrada que el usuario indica

    function consultarProyectoOrdenanza(uint256 _id)
        public
        view
        returns (
            uint256  fechaCreacion,   // timestamp Unix en segundos
            uint256  dniAutor,
            uint8   resultado,
            uint256  numExpediente,
            bytes32 hash
    
        )
    {
        ActuacionBase.Actuacion memory actuacion = _consultarActuacion(_id);
        DatosProyectoOrdenanza storage o = datosExtra[_id];
        return (
            actuacion.fechaCreacion,
            actuacion.dniAutor,
            actuacion.historial[actuacion.historial.length - 1].estado,
            o.numExpediente,
            actuacion.historial[actuacion.historial.length - 1].hash
        );
    }
    
    /*  MODIFICAR ENTRADA: Tome un identificador y un dato concreto y modifique una entrada existente.
        Esta operación solo debe estar disponible para el cliente y/o el responsable de inicializar el
        contrato. Si la entrada a modificar no existe, la operación debe ser rechazada.*/

    function modificarResultado(
        uint256 _id, 
        uint8 _resultado,
        bytes32 _hash) 
        public returns (bool success)
    {
        require(keccak256(abi.encodePacked(_resultado)) == keccak256(abi.encodePacked(uint8(0))) ||
                keccak256(abi.encodePacked(_resultado)) == keccak256(abi.encodePacked(uint8(1))) ||
                keccak256(abi.encodePacked(_resultado)) == keccak256(abi.encodePacked(uint8(2))),
            "resultado invalida: use (0) para Aprobada, (1) para Archivada o (2) para Rechazada"
        );
        _modificarActuacion(_id, _resultado, _hash);
        emit ResultadoActualizado(_id, _resultado, _hash);
        return true;
    }

    /*  ELIMINAR ENTRADA: Marque una entrada como eliminada.
        Esta operación solo debe estar disponible para el cliente y/o el responsable de inicializar el
        contrato.
    */

    function eliminar(uint256 _id, uint8 _resultado) public {
        require(keccak256(abi.encodePacked(_resultado)) == keccak256(abi.encodePacked(uint8(0))) ||
                keccak256(abi.encodePacked(_resultado)) == keccak256(abi.encodePacked(uint8(1))) ||
                keccak256(abi.encodePacked(_resultado)) == keccak256(abi.encodePacked(uint8(2))),
            "resultado invalida: use (0) para Aprobada, (1) para Archivada o (2) para Rechazada"
        );
        _eliminarActuacion(_id, _resultado);
    }
}