// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract ActuacionBase {

    struct Cambio {
        uint256 timestamp;
        string estadoAnterior;
        string estadoNuevo;
        address modificadoPor;
        string descripcion;
    }

    struct Actuacion {
        string id;
        uint256 fechaCreacion;   // timestamp Unix en segundos
        uint256 dniAutor;
        string nombreAutor;
        string  estado;          // string actual (el último es el vigente)
        bool    existe;          // bandera de existencia (patrón Solidity)
        Cambio[] historial;       // trazabilidad de cambios
    }

    // string

    address public propietario;           // quien desplegó el contrato
    uint256 public constant COSTO = 500;  // wei requeridos para agregar

    mapping(string => Actuacion) internal actuaciones;
    string[] internal ids;                // para poder enumerar, almacenas los ids

    // EVENTOS:
    
    event ActuacionAgregada(string indexed id, uint256 fechaCreacion, uint256 dniAutor, string nombreAutor, string estado);
    event ActuacionModificada(string indexed id, string nuevoEstado, string descripcion);
    event ActuacionEliminada(string indexed id, string nuevoEstado); 

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
        string memory _id,
        uint256 _dniAutor, 
        string memory _nombreAutor,
        string memory estadoNuevo) public payable{
        
        require(!actuaciones[_id].existe, "La actuacion ya existe");
        require(msg.value >= 500, "No se ha pagado la tarifa de registro");
        
        Actuacion storage a = actuaciones[_id];
        a.existe = true;
        a.dniAutor = _dniAutor;
        a.nombreAutor = _nombreAutor;
        a.fechaCreacion = block.timestamp;
        a.estado = estadoNuevo;
        propietario = msg.sender;
        a.historial.push(Cambio({   timestamp: block.timestamp,
                                    estadoAnterior: estadoNuevo,
                                    estadoNuevo: estadoNuevo,
                                    modificadoPor: msg.sender,
                                    descripcion: "Creacion inicial"
                                }));
        ids.push(_id);

        emit ActuacionAgregada(_id, a.fechaCreacion, a.dniAutor, a.nombreAutor, a.estado);
    }

    // VER ENTRADA: Retorne la entrada que el usuario indica

    function _consultarActuacion(string memory _id)
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

    function _modificarEntrada(string memory _id, string memory _estadoNuevo, string memory _dato)
        public
        returns (bool success)
    {
        require(actuaciones[_id].existe, "La actuacion no existe");
        require(msg.sender == propietario, "No es el propietario");

        Actuacion storage a = actuaciones[_id];
        string memory anterior = a.estado;
        a.estado = _estadoNuevo;

        a.historial.push(Cambio({
            timestamp: block.timestamp,
            estadoAnterior: anterior,
            estadoNuevo: _estadoNuevo,
            modificadoPor: msg.sender,
            descripcion: _dato
        }));

        emit ActuacionModificada(_id, _estadoNuevo, _dato);
        return true;
    }

    /*  ELIMINAR ENTRADA: Marque una entrada como eliminada.
        Esta operación solo debe estar disponible para el cliente y/o el responsable de inicializar el
        contrato.
    */

    
    function _eliminarActuacion (string memory _id, string memory _estadoNuevo) public {
        require(actuaciones[_id].existe, "La actuacion no existe");
        require(msg.sender == propietario, "No es el propietario");
        Actuacion storage a = actuaciones[_id];
        string memory anterior = a.estado;
        a.historial.push(Cambio({
            timestamp: block.timestamp,
            estadoAnterior: anterior,
            estadoNuevo: _estadoNuevo,
            modificadoPor: msg.sender,
            descripcion: "Eliminacion"
        }));

        a.estado = _estadoNuevo;

        emit ActuacionEliminada(_id, _estadoNuevo);
    }

}