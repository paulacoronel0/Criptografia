// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import "./ActuacionBase.sol";

contract Declaracion is ActuacionBase {

    struct DatosDeclaracion {
        uint8   categoria;       // 0=Cultural 1=Educativa 2=Deportiva 3=Social
        bytes32 institucionBen;  
    }

    // ESTADO
    mapping(uint256 => DatosDeclaracion) internal datosExtra;

    // EVENTOS

    event DeclaracionAgregada(
        uint256 id,
        uint256 numDeclaracion,
        uint8   categoria,
        bytes32 institucionBen,
        uint8   estado,
        bytes32 hash
    );

    event DeclaracionModificada(
        uint256 id,
        uint8   estadoNuevo,
        bytes32 hash
    );

    // FUNCIONES

    /* AGREGAR ENTRADA: Solicite un costo en Ethereums (ETH) al cliente, por ejemplo 500 wei de ETH,
        para agregar una entrada nueva, que será registrada en la blockchain.
        Si el cliente quiere agregar la entrada sin brindar este costo, entonces la operación debe ser
        rechazada. Además, considere que si la entrada ya fue agregada, entonces la operación debe ser
        rechazada. 
    */

    function agregarDeclaracion(
        uint256 _id,
        uint256 _dniAutor,
        bytes32 _hash,
        uint256 _fechaCreacion,
        uint8   _categoria,      // 0-3
        bytes32 _institucionBen,
        uint8   _estado
    ) public payable {
        require(_categoria <= 3, "Categoria invalida: 0=Cultural 1=Educativa 2=Deportiva 3=Social");
        require(_estado == 0, "Estado inicial invalido: use 0 para Vigente");

        _inicializarActuacion(_id, _dniAutor, _estado, _hash, _fechaCreacion);

        datosExtra[_id] = DatosDeclaracion({
            categoria:      _categoria,
            institucionBen: _institucionBen
        });

        emit DeclaracionAgregada(_id, _id, _categoria, _institucionBen, _estado, _hash);
    }

    // VER ENTRADA: Retorne la entrada que el usuario indica

    function consultarDeclaracion(uint256 _id)
        public
        view
        returns (
            uint256 fechaCreacion,
            uint256 dniAutor,
            uint8   estado,
            uint8   categoria,
            bytes32 institucionBen,
            bytes32 hash
        )
    {
        ActuacionBase.Actuacion memory actuacion = _consultarActuacion(_id);
        DatosDeclaracion storage d = datosExtra[_id];

        return (
            actuacion.fechaCreacion,
            actuacion.dniAutor,
            actuacion.historial[actuacion.historial.length - 1].estado,
            d.categoria,
            d.institucionBen,
            actuacion.historial[actuacion.historial.length - 1].hash
        );
    }

    /*  MODIFICAR ENTRADA: Tome un identificador y un dato concreto y modifique una entrada existente.
        Esta operación solo debe estar disponible para el cliente y/o el responsable de inicializar el
        contrato. Si la entrada a modificar no existe, la operación debe ser rechazada.*/

    function modificarDeclaracion(
        uint256 _id,
        uint8   _estadoNuevo,
        bytes32 _hash
    ) public returns (bool success) {
        require(_estadoNuevo == 1, "Estado invalido: use 1 para Modificada");
        _modificarActuacion(_id, _estadoNuevo, _hash);
        emit DeclaracionModificada(_id, _estadoNuevo, _hash);
        return true;
    }

    /*  ELIMINAR ENTRADA: Marque una entrada como eliminada.
        Esta operación solo debe estar disponible para el cliente y/o el responsable de inicializar el
        contrato.
    */

    function eliminarDeclaracion(uint256 _id, uint8 _estado) public {
        require(_estado == 2, "Estado invalido: use 2 para Derogada");
        _eliminarActuacion(_id, _estado);
    }
}