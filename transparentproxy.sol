// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

contract TransparentProxy {
    


    bytes32 private constant _IMPLEMENTATION_SLOT =
        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    bytes32 private constant _ADMIN_SLOT =
        0xb53127684a568b3173ae13b9f8a6016e019a9c8f64f10d9a79d4c24321f3c7a2;


    // Modifier to restrict access to admin-only functions.
    modifier ifAdmin() {
        require(msg.sender == _getAdmin(), "TransparentProxy: caller is not admin");
        _;
    }


    constructor(address _implementation, bytes memory _data) payable {
        _setAdmin(msg.sender);
        _setImplementation(_implementation);
        if (_data.length > 0) {
            // Delegatecall to initialize the logic contract.
            (bool success, ) = _implementation.delegatecall(_data);
            require(success, "Initialization failed");
        }
    }

    // Admin functions

    function upgradeTo(address newImplementation) external ifAdmin {
        require(newImplementation != address(0), "New implementation is zero address");
        _setImplementation(newImplementation);
    }

    function changeAdmin(address newAdmin) external ifAdmin {
        require(newAdmin != address(0), "New admin is zero address");
        _setAdmin(newAdmin);
    }

    function admin() external view ifAdmin returns  (address) {
        return _getAdmin();
    }


    function implementation() external view ifAdmin returns (address) {
        return _getImplementation();
    }


    fallback() external payable {
        _fallback();
    }

    receive() external payable {
        _fallback();
    }

    function _delegate(address impl) internal {
        assembly {
      
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(0, 0, size)
            switch result
            case 0 { revert(0, size) }
            default { return(0, size) }
        }
    }


     
    function _fallback() internal {
        if (msg.sender == _getAdmin()) {
            revert("TransparentProxy: admin cannot fallback to proxy target");
        }
        _delegate(_getImplementation());
    }

    

    function _getImplementation() internal view returns (address impl) {
        bytes32 slot = _IMPLEMENTATION_SLOT;
        assembly { impl := sload(slot) }
    }

    function _setImplementation(address newImplementation) internal {
        bytes32 slot = _IMPLEMENTATION_SLOT;
        assembly { sstore(slot, newImplementation) }
    }

    function _getAdmin() internal view returns (address adm) {
        bytes32 slot = _ADMIN_SLOT;
        assembly { adm := sload(slot) }
    }

    function _setAdmin(address newAdmin) internal {
        bytes32 slot = _ADMIN_SLOT;
        assembly { sstore(slot, newAdmin) }
    }
}