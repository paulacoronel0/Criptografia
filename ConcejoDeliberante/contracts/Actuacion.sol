// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract ActuacionBase {

    enum Estado { Activa, Modificada, Anulada }

    struct Cambio {
        uint256 timestamp;
        Estado estadoAnterior;
        Estado estadoNuevo;
        address modificadoPor;
        string descripcion;
    }

    struct Actuacion {
        bytes32 id;
        uint256  fechaCreacion;   // timestamp Unix en segundos
        uint256  dniAutor;
        bytes32   nombreAutor;
        Estado estado;          // estado actual (el último es el vigente)
        bool     existe;          // bandera de existencia (patrón Solidity)
        Cambio[] historial;       // trazabilidad de cambios
    }

    // ESTADO

    address public propietario;           // quien desplegó el contrato
    uint256 public constant COSTO = 500;  // wei requeridos para agregar

    mapping(bytes32 => Actuacion) internal actuaciones;
    bytes32[] internal ids;                // para poder enumerar, almacenas los ids

    // EVENTOS:
    
    event ActuacionAgregada(bytes32 indexed id, uint256 fechaCreacion, uint256 dniAutor, bytes32 nombreAutor);
    event ActuacionModificada(bytes32 indexed id, string descripcion);
    event ActuacionEliminada(bytes32 indexed id); 

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
        bytes32 _id,
        uint256 _dniAutor, 
        bytes32 _nombreAutor) public payable{
        
        require(!actuaciones[_id].existe, "La actuacion ya existe");
        require(msg.value >= 500, "No se ha pagado la tarifa de registro");
        
        Actuacion storage a = actuaciones[_id];
        a.existe = true;
        a.dniAutor = _dniAutor;
        a.nombreAutor = _nombreAutor;
        a.fechaCreacion = block.timestamp;
        a.estado = Estado.Activa;
        propietario = msg.sender;
        a.historial.push(Cambio({   timestamp: block.timestamp,
                                    estadoAnterior: Estado.Activa,
                                    estadoNuevo: Estado.Activa,
                                    modificadoPor: msg.sender,
                                    descripcion: "Creacion inicial"
                                }));
        ids.push(_id);

        emit ActuacionAgregada(_id, a.fechaCreacion, a.dniAutor, a.nombreAutor);
    }

    function consultarActuacion(bytes32 _id)
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

    function modificarEntrada(bytes32 _id, string memory _dato)
        public
        returns (bool success)
    {
        require(actuaciones[_id].existe, "La actuacion no existe");
        require(msg.sender == propietario, "No es el propietario");

        Actuacion storage a = actuaciones[_id];
        Estado anterior = a.estado;
        a.estado = Estado.Modificada;

        a.historial.push(Cambio({
            timestamp: block.timestamp,
            estadoAnterior: anterior,
            estadoNuevo: Estado.Modificada,
            modificadoPor: msg.sender,
            descripcion: _dato
        }));

        emit ActuacionModificada(_id, _dato);
        return true;
    }

    /*  ELIMINAR ENTRADA: Marque una entrada como eliminada.
        Esta operación solo debe estar disponible para el cliente y/o el responsable de inicializar el
        contrato.
    */

    
    function _eliminarEntrada (bytes32 _id) internal {
        require(actuaciones[_id].existe, "La actuacion no existe");
        require(msg.sender == propietario, "No es el propietario");
        Actuacion storage a = actuaciones[_id];
        Estado anterior = a.estado;
        a.estado = Estado.Eliminada;

        emit ActuacionEliminada(id);
    }

}