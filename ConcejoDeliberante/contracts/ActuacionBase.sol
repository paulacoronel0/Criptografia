// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract ActuacionBase {

    struct Cambio {
        uint256 timestamp;
        uint8 estado;
        bytes32 hash;
        address modificadoPor;
    }

    struct Actuacion {
        uint256 fechaCreacion;   // 
        uint256 dniAutor;
        bool    existe;          // bandera de existencia (patrón Solidity)
        Cambio[] historial;       // trazabilidad de cambios
    }

    // string

    address public propietario;           // quien desplegó el contrato
    uint256 public constant COSTO = 500;  // wei requeridos para agregar

    mapping(uint256 => Actuacion) internal actuaciones;
    uint256[] internal ids;                // para poder enumerar, almacenas los ids

    // EVENTOS:
    
    event ActuacionAgregada(uint256 id, uint256 fechaCreacion, uint256 dniAutor, uint8 estado, bytes32 hash);
    event ActuacionModificada(uint256 id, uint8 estado, bytes32 hash);
    event ActuacionEliminada(uint256 id, uint8 estado); 

    // MODIFICADORES:

    // CONSTRUSCTOR

    constructor() {
        propietario = msg.sender;
    }

    // FUNCIONES:

    /* AGREGAR ENTRADA: Solicite un costo en Ethereums (ETH) al cliente, por ejemplo 500 wei de ETH,
        para agregar una entrada nueva, que será registrada en la blockchain.
        Si el cliente quiere agregar la entrada sin brindar este costo, entonces la operación debe ser
        rechazada. Además, considere que si la entrada ya fue agregada, entonces la operación debe ser
        rechazada. 
    */

    // memory: hace que sea temporal en el metodo

    function _inicializarActuacion(
        uint256 _id,
        uint256 _dniAutor,
        uint8 _estadoNuevo,
        bytes32 _hash,
        uint256 _fechaCreacion) public payable{
        
        require(!actuaciones[_id].existe, "La actuacion ya existe");
        require(msg.value >= 500, "No se ha pagado la tarifa de registro");
        
        Actuacion storage a = actuaciones[_id];
        a.existe        = true;
        a.dniAutor      = _dniAutor;
        a.fechaCreacion = _fechaCreacion;

        a.historial.push(Cambio({
            timestamp:      block.timestamp,
            modificadoPor:  msg.sender,
            hash:  _hash,
            estado: _estadoNuevo
        }));

        ids.push(_id);

        emit ActuacionAgregada(_id, _fechaCreacion, _dniAutor, _estadoNuevo, _hash);
    }

    // VER ENTRADA: Retorne la entrada que el usuario indica

    function _consultarActuacion(uint256 _id)
        public
        view
        returns (Actuacion memory)
    {
        require(actuaciones[_id].existe, "La actuacion no existe");
        return actuaciones[_id];  // ver si muestra bien los cambios
    }
    
    /*  MODIFICAR ENTRADA: Tome un identificador y un dato concreto y modifique una entrada existente.
        Esta operación solo debe estar disponible para el cliente y/o el responsable de inicializar el
        contrato. Si la entrada a modificar no existe, la operación debe ser rechazada.*/

    function _modificarActuacion(uint256 _id, uint8 _estadoNuevo, bytes32 _hashNuevo)
        public
        returns (bool success)
    {
        require(actuaciones[_id].existe, "La actuacion no existe");
        require(msg.sender == propietario, "No es el propietario");

        actuaciones[_id].historial.push(Cambio({
            timestamp:     block.timestamp,
            modificadoPor: msg.sender,
            hash: _hashNuevo,
            estado:        _estadoNuevo
        }));

        emit ActuacionModificada(_id, _estadoNuevo, _hashNuevo);
        return true;
    }

    /*  ELIMINAR ENTRADA: Marque una entrada como eliminada.
        Esta operación solo debe estar disponible para el cliente y/o el responsable de inicializar el
        contrato.
    */

    
    function _eliminarActuacion (uint256 _id, uint8 _estadoNuevo) public {
        require(actuaciones[_id].existe, "La actuacion no existe");
        require(msg.sender == propietario, "No es el propietario");
        actuaciones[_id].historial.push(Cambio({
            timestamp:     block.timestamp,
            modificadoPor: msg.sender,
            hash: bytes32(0),   // sin documento nuevo, solo marca el cierre
            estado:        _estadoNuevo
        }));

        emit ActuacionEliminada(_id, _estadoNuevo);
    }

}